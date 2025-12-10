#!/bin/bash
# shellcheck disable=SC2004  # Disable complexity warnings only
#######################################
# Description: Collect AWS resource information and output as CSV files organized
# by category. The script produces per-category CSV files under a resources/
# subdirectory and a combined CSV file (the "combined output") which is
# written to ${OUTPUT_DIR}/resources/${OUTPUT_FILE}.
#
# Key behaviors (current):
# - The script appends the current AWS account ID to the configured
#   OUTPUT_DIR. Example: if OUTPUT_DIR is ./output and account id is 123456789012
#   the actual files are written to ./output/123456789012/resources/
# - The combined CSV path is available as COMBINED_OUTPUT_PATH and points to
#   "${OUTPUT_DIR}/resources/${OUTPUT_FILE}" after OUTPUT_DIR has been normalized.
# - When HTML mode is enabled (with -H/--html), the script copies the
#   template `scripts/terraform/files/aws_get_resources/index.html` to
#   ${OUTPUT_DIR}/index.html and substitutes placeholders including
#   @@INDEX_TITLE@@, @@INDEX_DESCRIPTION@@ and @@OUTPUT_FILE@@ so the
#   download link inside the generated index points at the actual combined CSV.
#
# Usage: ./aws_get_resources.sh [options]
#   options:
#     -h, --help             Display this help message
#     -v, --verbose          Enable verbose output
#     -d, --dry-run          Run in dry-run mode (no changes made)
#     -o, --output FILE      Combined output filename (default: all.csv)
#     -D, --output-dir DIR   Base output directory (default: ./output). The
#                           script will append the AWS account id to this path.
#     -r, --region REGION    AWS region to use (default: $AWS_DEFAULT_REGION or ap-northeast-1)
#     -c, --categories LIST  Comma-separated list of categories to collect (optional)
#     -n, --no-sort          Do not sort category output (preserve grouping)
#     -H, --html             Generate HTML index (files.json + index.html)
#
# Output summary:
# - Per-category CSV files are written under: ${OUTPUT_DIR}/resources/<category>.csv
# - The combined CSV (COMBINED_OUTPUT_PATH) is: ${OUTPUT_DIR}/resources/${OUTPUT_FILE}
# - The generated HTML index (if requested) is: ${OUTPUT_DIR}/index.html
# - A JSON manifest is written to: ${OUTPUT_DIR}/files.json (listing the per-category CSVs)
#
# Notes / conventions:
# - The script is designed to be invoked from CI workflows; callers may override
#   OUTPUT_DIR and OUTPUT_FILE. Some reusable workflows (in this repo) set
#   `output_file` to e.g. "aws_resources.csv" when invoking this script.
# - The CSV format follows RFC 4180 quoting rules; fields that contain commas,
#   quotes or newlines will be quoted.
########################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables and default values
#######################################
VERBOSE=false
export VERBOSE
DRY_RUN=false
OUTPUT_FILE="all.csv"
OUTPUT_DIR="./output"
HTML_MODE=false
# Default HTML index title/description updated to emphasize AWS Resources per environment
INDEX_TITLE="AWS Resources (${ENVIRONMENT:-unknown})"
INDEX_DESCRIPTION="AWS resources list for ${ENVIRONMENT:-environment}"
AWS_REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"
CATEGORIES=""
REGIONS_TO_CHECK=()
SORT_OUTPUT=true

# AWS resource categories list (A-Z order)
AWS_RESOURCE_CATEGORIES=(
    "acm"
    "apigateway"
    "batch"
    #    "bedrock"
    "cloudfront"
    "cloudformation"
    "cognito"
    "cloudwatch_alarms"
    "cloudwatch_logs"
    "dynamodb"
    "ec2"
    "ecr"
    "ecs"
    "efs"
    "elasticache"
    "elb"
    "eventbridge"
    "glue"
    "iam"
    "kinesis"
    "kms"
    "lambda"
    "quicksight"
    "rds"
    "redshift"
    "route53"
    "s3"
    "secretsmanager"
    "sns"
    "sqs"
    "transferfamily"
    "vpc"
    "waf"
)

# Categories that need to maintain grouping structure (no sorting)
NO_SORT_CATEGORIES=(
    "acm"         # Sort by DomainName within function
    "apigateway"  # Maintain API grouping structure
    "ecs"         # Maintain cluster grouping structure
    "elasticache" # Maintain ReplicationGroup grouping structure
    "elb"         # Maintain LoadBalancer grouping structure
    "lambda"      # Maintain environment variables integrity (quoted CSV fields)
    "rds"         # Maintain cluster grouping structure
    "route53"     # Maintain HostedZone grouping structure
    "vpc"         # Maintain VPC grouping structure
)

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Arguments:
#   None
#
# Returns:
#   None (exits with status 0)
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Description: Generate AWS resource inventory in CSV format"
    echo ""
    echo "Options:"
    echo "  -h, --help       Display this help message"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -o, --output     Specify output file path (default: aws_resource_inventory.csv)"
    echo "  -D, --output-dir Specify output directory for CSV files (default: ./output)"
    echo "  -r, --region     AWS region to query (default: \$AWS_DEFAULT_REGION or ap-northeast-1)"
    echo "  -d, --dry-run    Run in dry-run mode (no changes made)"
    echo "  -T, --index-title Specify the HTML index title (overrides default INDEX_TITLE)"
    echo "  -t, --test      Enable test mode (header names as values for automated testing)"
    echo "  -c, --categories Comma-separated list of categories to collect (optional)"
    echo "  -n, --no-sort    Disable sorting for all outputs (preserve original order)"

    echo "  -H, --html       Generate a single interactive HTML page (index.html) in OUTPUT_DIR"
    echo ""
    echo "Available categories:"
    echo "  acm, apigateway, batch, bedrock, cloudformation, cloudfront, cognito, ec2, ecr, ecs,"
    echo "  efs, elasticache, elb, glue, iam, kms, lambda, quicksight, rds, redshift, route53, s3,"
    echo "  secretsmanager, sns, sqs, transferfamily, vpc, waf"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") -v -o my_inventory.csv"
    echo "  $(basename "$0") -r us-east-1 -o us_inventory.csv"

    echo "  $(basename "$0") -c vpc,s3 -o vpc_s3_only.csv"
    echo "  $(basename "$0") -n -o unsorted_inventory.csv"
    echo "  $(basename "$0") -H -T \"My Org Resources\"  # generate HTML with custom title"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables accordingly
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Returns:
#   None (sets globals such as OUTPUT_FILE, OUTPUT_DIR, AWS_REGION, etc.)
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            -v | --verbose)
                VERBOSE=true
                export VERBOSE
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -t | --test)
                # Test mode for header validation (reserved for future use)
                shift
                ;;
            -o | --output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -T | --index-title)
                INDEX_TITLE="$2"
                shift 2
                ;;
            -D | --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -r | --region)
                AWS_REGION="$2"
                shift 2
                ;;
            -c | --categories)
                CATEGORIES="$2"
                shift 2
                ;;
            -n | --no-sort)
                SORT_OUTPUT=false
                shift
                ;;

            -H | --html)
                HTML_MODE=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                error_exit "Unexpected argument: $1"
                ;;
        esac
    done
}

#######################################
# call_collect_aws_resources: Generic function to collect AWS resources across regions
#
# Description:
#   Generic function to collect AWS resources across regions
#
# Arguments:
#   $1 - Resource category name
#
# Global Variables:
#   REGIONS_TO_CHECK - Array of AWS regions to check
#
# Returns:
#   None
#
# Usage:
#   call_collect_aws_resources "ec2"
#
#######################################
function call_collect_aws_resources {
    local category=$1

    log "INFO" "Collecting $category information from AWS..."

    # Get header from the first call
    local collect_function="collect_${category}_inventory"
    if ! declare -f "$collect_function" > /dev/null; then
        log "WARN" "Collection function $collect_function not found for category $category"
        return 1
    fi

    # Get header
    local csv_header
    csv_header=$($collect_function "header")

    local buffer=""
    for region in "${REGIONS_TO_CHECK[@]}"; do
        log "INFO" "Checking $category resources in region: $region"
        buffer+=$($collect_function "$region")
    done
    # Check if this category should maintain grouping structure (no sorting)
    # Check if this category should maintain grouping structure (no sorting)
    local sort_output="true"
    for no_sort_category in "${NO_SORT_CATEGORIES[@]}"; do
        if [[ "$category" == "$no_sort_category" ]]; then
            sort_output="false"
        fi
    done

    output_csv_data "$category" "$csv_header" "$buffer" "$sort_output"
}

#######################################
# collect_acm_inventory: Collect ACM inventory (with categories)
#
# Description:
#   Collects ACM certificates for a given region and formats the data as CSV
#   rows for inclusion in the inventory output. When called with the special
#   argument "header" it returns only the header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted rows to stdout; with "header" prints the header
#
# Usage:
#   collect_acm_inventory "us-east-1"
#######################################
function collect_acm_inventory {
    local region=$1
    # Add Request_Date, Issued_Date, Expiration_Date (English headers) after Type
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Type,RequestDate,IssuedDate,ExpirationDate,Status,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r cert_data; do
        [[ -z "$cert_data" ]] && continue
        local cert_arn cert_name cert_status cert_type cert_domain cert_created
        cert_arn=$(extract_jq_value "$cert_data" '.CertificateArn')
        cert_domain=$(extract_jq_value "$cert_data" '.DomainName')
        cert_status=$(extract_jq_value "$cert_data" '.Status')
        cert_type=$(extract_jq_value "$cert_data" '.Type')
        cert_name="${cert_domain}"

        # Get certificate details for request/issue/expiration dates
        local cert_details cert_arn
        cert_arn=$(extract_jq_value "$cert_data" '.CertificateArn')
        cert_details=$(aws acm describe-certificate --certificate-arn "$cert_arn" --region "$region" 2> /dev/null || echo '{}')
        # Request date (creation), Issued date, Expiration date
        cert_request=$(extract_jq_value "$cert_details" '.Certificate.CreatedAt')
        cert_issued=$(extract_jq_value "$cert_details" '.Certificate.IssuedAt')
        cert_expires=$(extract_jq_value "$cert_details" '.Certificate.NotAfter')
        cert_created="$cert_request"

        buffer+="acm,Certificate,,${cert_name},${region},${cert_arn},${cert_type},${cert_request},${cert_issued},${cert_expires},${cert_status},${cert_created}\n"
    done < <(aws acm list-certificates --region "$region" | jq -c '.CertificateSummaryList | sort_by(.DomainName)[] ')

    echo "$buffer"
}

#######################################
# collect_apigateway_inventory: Collect API Gateway inventory (with categories)
#
# Description:
#   Collects API Gateway (REST & HTTP) inventories for a given region and
#   formats them as CSV rows (including authorizers information). When called
#   with the special argument "header" it returns only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows to stdout; prints header if called with "header"
#
# Usage:
#   collect_apigateway_inventory "us-east-1"
#######################################
function collect_apigateway_inventory {
    local region=$1
    # Add authorizer_type and authorizer_provider_arn columns
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,ProtocolType,WAF,AuthorizerType,AuthorizerProviderARN"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # REST APIs
    while IFS= read -r api_data; do
        [[ -z "$api_data" ]] && continue
        local api_id api_name api_type
        api_id=$(extract_jq_value "$api_data" '.id')
        api_name=$(extract_jq_value "$api_data" '.name')
        api_type="REST"

        # Get WAF association for REST API - directly from stage data
        local stages_data api_waf_arn api_waf_name
        stages_data=$(aws apigateway get-stages --rest-api-id "$api_id" --region "$region" 2> /dev/null || echo '{"item":[]}')
        if [[ "$stages_data" != '{"item":[]}' ]]; then
            api_waf_arn=$(extract_jq_value "$stages_data" '.item[]?.webAclArn')
            # Resolve ARN -> friendly name (fallback to ARN) and normalize for CSV
            api_waf_name=$(get_waf_name "$api_waf_arn" "$region" || echo "$api_waf_arn")
            api_waf_name=$(normalize_csv_value "$api_waf_name")
        else
            api_waf_name=""
        fi
        buffer+="apigateway,RestAPI,,$api_name,${region},$api_id,$api_type,$api_waf_name,,\n"

        # Collect REST API authorizers using aws apigateway get-authorizers
        # Each authorizer is output as a separate row (similar to ELB TargetGroup/Listener pattern)
        local authorizers_json
        authorizers_json=$(aws apigateway get-authorizers --rest-api-id "$api_id" --region "$region" 2> /dev/null || echo '{"items": []}')

        while IFS= read -r auth_item; do
            [[ -z "$auth_item" ]] && continue
            local auth_name auth_type auth_provider_arns_raw auth_provider_arns
            auth_name=$(extract_jq_value "$auth_item" '.name')
            auth_type=$(extract_jq_value "$auth_item" '.type')
            auth_provider_arns_raw=$(echo "$auth_item" | jq -r '.providerARNs[]? // .authorizerUri // ""' 2> /dev/null | paste -sd$'\n' - || echo "")
            auth_provider_arns=$(normalize_csv_value "$auth_provider_arns_raw")

            # Output each authorizer as a separate row
            buffer+="apigateway,,Authorizer,${auth_name},${region},,,,${auth_type},${auth_provider_arns}\n"
        done < <(echo "$authorizers_json" | jq -c '.items[]?' 2> /dev/null || true)
    done < <(aws apigateway get-rest-apis --region "$region" | jq -c '.items[]')

    # HTTP APIs
    while IFS= read -r api_data; do
        [[ -z "$api_data" ]] && continue
        local api_id api_name api_type
        api_id=$(extract_jq_value "$api_data" '.ApiId')
        api_name=$(extract_jq_value "$api_data" '.Name')
        api_type=$(extract_jq_value "$api_data" '.ProtocolType')

        # Get WAF association for HTTP API - directly from stage data
        local http_stages_data api_waf_arn api_waf_name
        http_stages_data=$(aws apigatewayv2 get-stages --api-id "$api_id" --region "$region" 2> /dev/null || echo '{"Items":[]}')
        if [[ "$http_stages_data" != '{"Items":[]}' ]]; then
            api_waf_arn=$(extract_jq_value "$http_stages_data" '.Items[]?.WebAclArn')
            api_waf_name=$(get_waf_name "$api_waf_arn" "$region" || echo "$api_waf_arn")
            api_waf_name=$(normalize_csv_value "$api_waf_name")
        else
            api_waf_name=""
        fi
        buffer+="apigateway,HttpAPI,,$api_name,${region},$api_id,$api_type,$api_waf_name,,\n"

        # Collect HTTP API (apigatewayv2) authorizers using aws apigatewayv2 get-authorizers
        # Each authorizer is output as a separate row (similar to ELB TargetGroup/Listener pattern)
        local ag2_authorizers_json
        ag2_authorizers_json=$(aws apigatewayv2 get-authorizers --api-id "$api_id" --region "$region" 2> /dev/null || echo '{"Items": []}')

        while IFS= read -r ag2_item; do
            [[ -z "$ag2_item" ]] && continue
            local ag2_name ag2_type ag2_provider_info_raw ag2_provider_info
            ag2_name=$(extract_jq_value "$ag2_item" '.Name')
            ag2_type=$(extract_jq_value "$ag2_item" '.AuthorizerType')
            ag2_provider_info_raw=$(echo "$ag2_item" | jq -r '.IdentitySource[]? // .AuthorizerUri // .AuthorizerCredentialsArn // ""' 2> /dev/null | paste -sd$'\n' - || echo "")
            ag2_provider_info=$(normalize_csv_value "$ag2_provider_info_raw")

            # Output each authorizer as a separate row
            buffer+="apigateway,,Authorizer,${ag2_name},${region},,,,${ag2_type},${ag2_provider_info}\n"
        done < <(echo "$ag2_authorizers_json" | jq -c '.Items[]?' 2> /dev/null || true)
    done < <(aws apigatewayv2 get-apis --region "$region" | jq -c '.Items[]')

    echo "$buffer"
}

#######################################
# collect_batch_inventory: Collect Batch inventory (with categories)
#
# Description:
#   Collects AWS Batch JobQueues, Compute Environments, and JobDefinitions for
#   a specified region and returns them as CSV formatted lines. Use
#   "header" to output only the CSV header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted rows to stdout; prints header if called with "header"
#
# Usage:
#   collect_batch_inventory "ap-northeast-1"
#######################################
function collect_batch_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Priority,Type,Image,vCPU,Memory,Status"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r queue_data; do
        [[ -z "$queue_data" ]] && continue
        local queue_name queue_arn queue_state queue_priority
        queue_name=$(extract_jq_value "$queue_data" '.jobQueueName')
        queue_arn=$(extract_jq_value "$queue_data" '.jobQueueArn')
        queue_state=$(extract_jq_value "$queue_data" '.state')
        queue_priority=$(extract_jq_value "$queue_data" '.priority')
        buffer+="batch,JobQueue,,$queue_name,${region},$queue_arn,$queue_priority,,,,,$queue_state\n"
    done < <(aws batch describe-job-queues --region "$region" | jq -c '.jobQueues[]')

    while IFS= read -r compute_data; do
        [[ -z "$compute_data" ]] && continue
        local compute_name compute_arn compute_state compute_type
        compute_name=$(extract_jq_value "$compute_data" '.computeEnvironmentName')
        compute_arn=$(extract_jq_value "$compute_data" '.computeEnvironmentArn')
        compute_state=$(extract_jq_value "$compute_data" '.state')
        compute_type=$(extract_jq_value "$compute_data" '.type')
        buffer+="batch,ComputeEnvironment,,$compute_name,${region},$compute_arn,,$compute_type,,,,$compute_state\n"
    done < <(aws batch describe-compute-environments --region "$region" | jq -c '.computeEnvironments[]')

    # Collect Job Definitions (ACTIVE only, latest revision per name)
    # Use jq to group by jobDefinitionName and select the latest revision
    while IFS= read -r jobdef_data; do
        [[ -z "$jobdef_data" ]] && continue
        local jobdef_name jobdef_arn jobdef_type jobdef_status jobdef_image jobdef_vcpu jobdef_memory jobdef_revision
        jobdef_name=$(extract_jq_value "$jobdef_data" '.jobDefinitionName')
        jobdef_arn=$(extract_jq_value "$jobdef_data" '.jobDefinitionArn')
        jobdef_type=$(extract_jq_value "$jobdef_data" '.type')
        jobdef_status=$(extract_jq_value "$jobdef_data" '.status')
        jobdef_revision=$(extract_jq_value "$jobdef_data" '.revision')

        # Extract container image and resource requirements
        jobdef_image=$(extract_jq_value "$jobdef_data" '.containerProperties.image')

        # Extract vCPU and Memory from resourceRequirements
        jobdef_vcpu=$(echo "$jobdef_data" | jq -r '.containerProperties.resourceRequirements[]? | select(.type=="VCPU") | .value' 2> /dev/null || echo "")
        jobdef_memory=$(echo "$jobdef_data" | jq -r '.containerProperties.resourceRequirements[]? | select(.type=="MEMORY") | .value' 2> /dev/null || echo "")

        # Fallback to legacy fields if resourceRequirements is not present
        if [[ -z "$jobdef_vcpu" || "$jobdef_vcpu" == "null" ]]; then
            jobdef_vcpu=$(extract_jq_value "$jobdef_data" '.containerProperties.vcpus')
        fi
        if [[ -z "$jobdef_memory" || "$jobdef_memory" == "null" ]]; then
            jobdef_memory=$(extract_jq_value "$jobdef_data" '.containerProperties.memory')
        fi

        buffer+="batch,JobDefinition,,${jobdef_name}:${jobdef_revision},${region},$jobdef_arn,,$jobdef_type,$jobdef_image,$jobdef_vcpu,$jobdef_memory,$jobdef_status\n"
    done < <(aws batch describe-job-definitions --status ACTIVE --region "$region" 2> /dev/null | jq -c '.jobDefinitions | group_by(.jobDefinitionName) | map(max_by(.revision)) | .[]' || true)

    echo "$buffer"
}

#######################################
# collect_bedrock_inventory: Collect Bedrock inventory (with categories)
#
# Description:
#   Collects AWS Bedrock foundation and custom model summaries for a given
#   region and returns them as CSV rows.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted rows to stdout; prints header if called with "header"
#
# Usage:
#   collect_bedrock_inventory "us-east-1"
#######################################
function collect_bedrock_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,Identifier,Provider,InputModalities,OutputModalities"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # List foundation models
    while IFS= read -r model_data; do
        [[ -z "$model_data" ]] && continue
        local model_id model_name model_provider model_input_modalities model_output_modalities
        model_id=$(extract_jq_value "$model_data" '.modelId')
        model_name=$(extract_jq_value "$model_data" '.modelName')
        model_provider=$(extract_jq_value "$model_data" '.providerName')
        model_input_modalities=$(extract_jq_array "$model_data" '.inputModalities')
        model_output_modalities=$(extract_jq_array "$model_data" '.outputModalities')

        buffer+="bedrock,FoundationModel,,$model_name,${region},$model_id,$model_provider,$model_input_modalities,$model_output_modalities\n"
    done < <(aws bedrock list-foundation-models --region "$region" 2> /dev/null | jq -c '.modelSummaries[]?' || true)

    # List custom models
    while IFS= read -r custom_model_data; do
        [[ -z "$custom_model_data" ]] && continue
        local custom_model_arn custom_model_name custom_model_status
        custom_model_arn=$(extract_jq_value "$custom_model_data" '.modelArn')
        custom_model_name=$(extract_jq_value "$custom_model_data" '.modelName')
        custom_model_status=$(extract_jq_value "$custom_model_data" '.status')

        buffer+="bedrock,CustomModel,,$custom_model_name,${region},$custom_model_arn,$custom_model_status,\n"
    done < <(aws bedrock list-custom-models --region "$region" 2> /dev/null | jq -c '.modelSummaries[]?' || true)

    # List model customization jobs
    while IFS= read -r job_data; do
        [[ -z "$job_data" ]] && continue
        local job_arn job_name job_status
        job_arn=$(extract_jq_value "$job_data" '.jobArn')
        job_name=$(extract_jq_value "$job_data" '.jobName')
        job_status=$(extract_jq_value "$job_data" '.status')

        buffer+="bedrock,CustomizationJob,,$job_name,${region},$job_arn,$job_status,\n"
    done < <(aws bedrock list-model-customization-jobs --region "$region" 2> /dev/null | jq -c '.modelCustomizationJobSummaries[]?' || true)

    echo "$buffer"
}

#######################################
# collect_cloudfront_inventory: Collect CloudFront inventory (with categories)
#
# Description:
#   Collects CloudFront distributions for the specified region. For global
#   services it only returns data when the region argument is us-east-1.
#   Use "header" to return only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted CloudFront distribution rows to stdout
#
# Usage:
#   collect_cloudfront_inventory "us-east-1"
#######################################
function collect_cloudfront_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,AlternateDomain,Origin,PriceClass,WAF,Status"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    # CloudFront is a global service, only process from us-east-1
    if [[ "$region" != "us-east-1" ]]; then
        echo ""
        return 0
    fi

    local buffer=""

    while IFS= read -r dist_data; do
        [[ -z "$dist_data" ]] && continue
        local dist_id dist_domain dist_status dist_price_class dist_aliases dist_origin dist_waf_arn
        dist_id=$(extract_jq_value "$dist_data" '.Id')
        dist_domain=$(extract_jq_value "$dist_data" '.DomainName')
        dist_status=$(extract_jq_value "$dist_data" '.Status')
        dist_price_class=$(extract_jq_value "$dist_data" '.PriceClass')
        dist_aliases_raw=$(extract_jq_value "$dist_data" '.Aliases.Items | join("\n")')
        dist_aliases=$(normalize_csv_value "$dist_aliases_raw")
        dist_origin=$(extract_jq_value "$dist_data" '.Origins.Items[0].DomainName')

        # Get WAF WebACLId from distribution config
        local dist_config_json dist_web_acl_id dist_waf_name dist_waf_arn
        dist_config_json=$(aws cloudfront get-distribution-config --id "$dist_id" 2> /dev/null)
        dist_web_acl_id=$(extract_jq_value "$dist_config_json" '.DistributionConfig.WebACLId')
        dist_waf_arn="$dist_web_acl_id"

        # Resolve ARN -> friendly WAF Name (fallback to ARN) and normalize for CSV
        if [[ -n "$dist_waf_arn" && "$dist_waf_arn" != "null" ]]; then
            dist_waf_name=$(get_waf_name "$dist_waf_arn" "$region" || echo "$dist_waf_arn")
            dist_waf_name=$(normalize_csv_value "$dist_waf_name")
        else
            dist_waf_name=""
        fi

        buffer+="cloudfront,Distribution,,$dist_domain,Global,$dist_id,$dist_aliases,$dist_origin,$dist_price_class,$dist_waf_name,$dist_status\n"
    done < <(aws_paginate_items 'DistributionList.Items' aws cloudfront list-distributions --region us-east-1 || true)

    echo "$buffer"
}

#######################################
# collect_cloudformation_inventory: Collect CloudFormation inventory (with categories)
#
# Description:
#   Collects CloudFormation stacks, their resources, outputs, and parameters
#   for the specified region and returns CSV rows. Use "header" to return
#   only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows describing CloudFormation stacks and sub-resources to stdout
#
# Usage:
#   collect_cloudformation_inventory "ap-northeast-1"
#######################################
function collect_cloudformation_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Description,Type,Outputs,Parameters,Resources,CreatedDate,LastUpdatedTime,StackDriftStatus,Status"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Get all stacks
    while IFS= read -r stack_summary; do
        [[ -z "$stack_summary" ]] && continue
        local stack_name stack_arn stack_status stack_created
        stack_name=$(extract_jq_value "$stack_summary" '.StackName')
        stack_arn=$(extract_jq_value "$stack_summary" '.StackId')
        stack_status=$(extract_jq_value "$stack_summary" '.StackStatus')
        stack_created=$(extract_jq_value "$stack_summary" '.CreationTime')
        stack_updated=$(extract_jq_value "$stack_summary" '.LastUpdatedTime')

        # Get detailed stack information for outputs and parameters
        local stack_details stack_description
        stack_details=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region "$region" 2> /dev/null || echo '{"Stacks":[]}')

        # Extract description from describe-stacks response
        stack_description=$(normalize_csv_value "$(extract_jq_value "$stack_details" '.Stacks[0].Description')")
        # Extract stack drift status from describe-stacks response
        local stack_drift_status
        stack_drift_status=$(normalize_csv_value "$(extract_jq_value "$stack_details" '.Stacks[0].DriftInformation.StackDriftStatus')" "N/A")
        local outputs_summary=""
        while IFS= read -r output_data; do
            [[ -z "$output_data" ]] && continue
            local output_key output_value
            output_key=$(extract_jq_value "$output_data" '.OutputKey')
            output_value=$(normalize_csv_value "$(extract_jq_value "$output_data" '.OutputValue')")
            if [[ -n "$outputs_summary" ]]; then
                outputs_summary+="\n"
            fi
            outputs_summary+="${output_key}=${output_value}"
        done < <(echo "$stack_details" | jq -c '.Stacks[0].Outputs[]?' 2> /dev/null || true)
        outputs_summary=$(normalize_csv_value "$outputs_summary" "N/A")

        # Collect parameters
        local parameters_summary=""
        while IFS= read -r param_data; do
            [[ -z "$param_data" ]] && continue
            local param_key param_value
            param_key=$(extract_jq_value "$param_data" '.ParameterKey')
            param_value=$(normalize_csv_value "$(extract_jq_value "$param_data" '.ParameterValue')")
            if [[ -n "$parameters_summary" ]]; then
                parameters_summary+="\n"
            fi
            parameters_summary+="${param_key}=${param_value}"
        done < <(echo "$stack_details" | jq -c '.Stacks[0].Parameters[]?' 2> /dev/null || true)
        parameters_summary=$(normalize_csv_value "$parameters_summary" "N/A")

        # Collect resources
        local resources_summary=""
        while IFS= read -r resource_data; do
            [[ -z "$resource_data" ]] && continue
            local logical_id resource_type
            logical_id=$(extract_jq_value "$resource_data" '.LogicalResourceId')
            resource_type=$(extract_jq_value "$resource_data" '.ResourceType')
            if [[ -n "$resources_summary" ]]; then
                resources_summary+="\n"
            fi
            resources_summary+="${logical_id}=${resource_type}"
        done < <(aws cloudformation list-stack-resources --stack-name "$stack_name" --region "$region" 2> /dev/null | jq -c '.StackResourceSummaries[]?' 2> /dev/null || true)
        resources_summary=$(normalize_csv_value "$resources_summary" "N/A")

        # Stack row with all outputs, parameters, and resources
        buffer+="cloudformation,Stack,,$stack_name,${region},$stack_arn,$stack_description,Stack,$outputs_summary,$parameters_summary,$resources_summary,$stack_created,$stack_updated,$stack_drift_status,$stack_status\n"

    done < <(aws cloudformation list-stacks --region "$region" --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE 2> /dev/null | jq -c '.StackSummaries[]?' 2> /dev/null || true)

    # Get all stack sets
    while IFS= read -r stackset_summary; do
        [[ -z "$stackset_summary" ]] && continue
        local stackset_name stackset_arn stackset_status stackset_description
        stackset_name=$(extract_jq_value "$stackset_summary" '.StackSetName')
        stackset_arn=$(extract_jq_value "$stackset_summary" '.StackSetId')
        stackset_status=$(extract_jq_value "$stackset_summary" '.Status')
        stackset_description=$(normalize_csv_value "$(extract_jq_value "$stackset_summary" '.Description')")

        # Get detailed stack set information for parameters
        local stackset_details
        stackset_details=$(aws cloudformation describe-stack-set --stack-set-name "$stackset_name" --region "$region" 2> /dev/null || echo '{}')

        # Extract description from describe-stack-set response
        stackset_description=$(normalize_csv_value "$(extract_jq_value "$stackset_details" '.StackSet.Description')")
        # Extract stack set drift status from describe-stack-set response
        local stackset_drift_status
        stackset_drift_status=$(normalize_csv_value "$(extract_jq_value "$stackset_details" '.StackSet.DriftInformation.StackDriftStatus')" "N/A")
        local parameters_summary=""
        while IFS= read -r param_data; do
            [[ -z "$param_data" ]] && continue
            local param_key param_value
            param_key=$(extract_jq_value "$param_data" '.ParameterKey')
            param_value=$(normalize_csv_value "$(extract_jq_value "$param_data" '.ParameterValue')")
            if [[ -n "$parameters_summary" ]]; then
                parameters_summary+="\n"
            fi
            parameters_summary+="${param_key}=${param_value}"
        done < <(echo "$stackset_details" | jq -c '.StackSet.Parameters[]?' 2> /dev/null || true)
        parameters_summary=$(normalize_csv_value "$parameters_summary")

        # Stack sets don't have outputs or resources in the same way, so leave empty
        local outputs_summary=""
        local resources_summary=""

        # StackSet row
        buffer+="cloudformation,StackSet,,$stackset_name,${region},$stackset_arn,$stackset_description,StackSet,$outputs_summary,$parameters_summary,$resources_summary,,,$stackset_drift_status,$stackset_status\n"

    done < <(aws cloudformation list-stack-sets --region "$region" 2> /dev/null | jq -c '.Summaries[]?' 2> /dev/null || true)

    echo "$buffer"
}

#######################################
# collect_cloudwatch_alarms_inventory: Collect CloudWatch alarms inventory
#
# Description:
#   Collects CloudWatch alarms (MetricAlarms and CompositeAlarms) for the
#   target region and returns formatted CSV rows that include thresholds and
#   other alarm metadata. Call with "header" to output only the header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Prints CSV rows to stdout; if region is "header" prints header only
#
# Usage:
#   collect_cloudwatch_alarms_inventory "ap-northeast-1"
#######################################
function collect_cloudwatch_alarms_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,MetricName,Namespace,Statistic,Threshold,ComparisonOperator,EvaluationPeriods,Period,TreatMissingData"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r alarm_data; do
        [[ -z "$alarm_data" ]] && continue
        local alarm_name alarm_arn alarm_metric_name alarm_namespace alarm_statistic alarm_threshold alarm_comparison_operator alarm_evaluation_periods alarm_period alarm_treat_missing_data

        alarm_name=$(extract_jq_value "$alarm_data" '.AlarmName')
        alarm_arn=$(extract_jq_value "$alarm_data" '.AlarmArn')
        alarm_metric_name=$(extract_jq_value "$alarm_data" '.MetricName')
        alarm_namespace=$(extract_jq_value "$alarm_data" '.Namespace')
        alarm_statistic=$(extract_jq_value "$alarm_data" '.Statistic')
        alarm_threshold=$(extract_jq_value "$alarm_data" '.Threshold')
        alarm_comparison_operator=$(extract_jq_value "$alarm_data" '.ComparisonOperator')
        alarm_evaluation_periods=$(extract_jq_value "$alarm_data" '.EvaluationPeriods')
        alarm_period=$(extract_jq_value "$alarm_data" '.Period')
        alarm_treat_missing_data=$(extract_jq_value "$alarm_data" '.TreatMissingData')

        buffer+="cloudwatch,Alarm,,$alarm_name,${region},$alarm_arn,$alarm_metric_name,$alarm_namespace,$alarm_statistic,$alarm_threshold,$alarm_comparison_operator,$alarm_evaluation_periods,$alarm_period,$alarm_treat_missing_data\n"

    done < <(aws cloudwatch describe-alarms --region "$region" 2> /dev/null | jq -c '.MetricAlarms[], .CompositeAlarms[]' || true)

    echo "$buffer"
}

#######################################
# collect_cloudwatch_logs_inventory: Collect CloudWatch Logs inventory
#
# Description:
#   Retrieves CloudWatch LogGroups in the specified region and outputs CSV
#   rows that include retention, stored bytes and other metadata. Use
#   "header" to return the CSV header line only.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted log group rows to stdout
#
# Usage:
#   collect_cloudwatch_logs_inventory "ap-northeast-1"
#######################################
function collect_cloudwatch_logs_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,RetentionInDays,StoredBytes,MetricFilterCount,SubscriptionFilterCount,KMSKeyId,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r log_group_data; do
        [[ -z "$log_group_data" ]] && continue
        local log_group_name log_group_arn log_group_retention log_group_stored_bytes log_group_metric_filter_count log_group_subscription_filter_count log_group_kms_key_id log_group_creation_time

        log_group_name=$(extract_jq_value "$log_group_data" '.logGroupName')
        log_group_arn=$(extract_jq_value "$log_group_data" '.arn')
        log_group_retention=$(extract_jq_value "$log_group_data" '.retentionInDays' 'Never Expire')
        log_group_stored_bytes=$(extract_jq_value "$log_group_data" '.storedBytes' '0')
        log_group_metric_filter_count=$(extract_jq_value "$log_group_data" '.metricFilterCount' '0')
        log_group_subscription_filter_count=$(extract_jq_value "$log_group_data" '.subscriptionFilterCount' '0')
        log_group_kms_key_id=$(extract_jq_value "$log_group_data" '.kmsKeyId')
        log_group_creation_time=$(extract_jq_value "$log_group_data" '.creationTime')

        # Convert Unix timestamp to readable format if needed
        if [[ "$log_group_creation_time" =~ ^[0-9]+$ ]]; then
            log_group_creation_time=$(date -d "@$((log_group_creation_time / 1000))" '+%Y-%m-%d %H:%M:%S' 2> /dev/null || echo "$log_group_creation_time")
        fi

        buffer+="cloudwatch,LogGroup,,$log_group_name,${region},$log_group_arn,$log_group_retention,$log_group_stored_bytes,$log_group_metric_filter_count,$log_group_subscription_filter_count,$log_group_kms_key_id,$log_group_creation_time\n"

    done < <(aws logs describe-log-groups --region "$region" 2> /dev/null | jq -c '.logGroups[]' || true)

    echo "$buffer"
}

#######################################
# collect_cognito_inventory: Collect Cognito inventory (with categories)
#
# Description:
#   Collects Cognito User Pools and Identity Pools for the specified region
#   and returns CSV rows with basic information such as IDs, status, and
#   creation time. Call with "header" to print the CSV header only.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted rows to stdout; prints header if argument == "header"
#
# Usage:
#   collect_cognito_inventory "ap-northeast-1"
#######################################
function collect_cognito_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,StatusAllowUnauthenticated,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # UserPool - has Status and CreationDate
    while IFS= read -r pool_data; do
        [[ -z "$pool_data" ]] && continue
        local pool_id pool_name pool_status pool_creation_date
        pool_id=$(extract_jq_value "$pool_data" '.Id')
        pool_name=$(extract_jq_value "$pool_data" '.Name')
        pool_status=$(extract_jq_value "$pool_data" '.Status')
        pool_creation_date=$(extract_jq_value "$pool_data" '.CreationDate')
        buffer+="cognito,UserPool,,$pool_name,${region},$pool_id,$pool_status,$pool_creation_date\n"
    done < <(aws_paginate_items 'UserPools' aws cognito-idp list-user-pools --region "$region" || true)

    # IdentityPool - has AllowUnauthenticatedIdentities
    while IFS= read -r pool_data; do
        [[ -z "$pool_data" ]] && continue
        local pool_id pool_name pool_allow_unauthenticated
        pool_id=$(extract_jq_value "$pool_data" '.IdentityPoolId')
        pool_name=$(extract_jq_value "$pool_data" '.IdentityPoolName')
        pool_allow_unauthenticated=$(extract_jq_value "$pool_data" '.AllowUnauthenticatedIdentities')
        buffer+="cognito,IdentityPool,,$pool_name,${region},$pool_id,,$pool_allow_unauthenticated\n"
    done < <(aws_paginate_items 'IdentityPools' aws cognito-identity list-identity-pools --region "$region" || true)

    echo "$buffer"
}

#######################################
# collect_ec2_inventory: Collect EC2 inventory (with categories)
#
# Description:
#   Collects EC2 instance metadata for the specified region and formats it
#   as CSV rows. Includes instance, VPC, subnet and security group details.
#   Use "header" to emit only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Writes CSV formatted EC2 rows to stdout; prints header for the special
#   argument "header"
#
# Usage:
#   collect_ec2_inventory "ap-northeast-1"
#######################################
function collect_ec2_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,InstanceID,InstanceType,ImageID,VPC,Subnet,SecurityGroup,State"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r instance_data; do
        [[ -z "$instance_data" ]] && continue
        local instance_id instance_name instance_type instance_state
        instance_name=$(normalize_csv_value "$(extract_jq_value "$instance_data" '.Tags[]? | select(.Key=="Name") | .Value')")
        instance_id=$(extract_jq_value "$instance_data" '.InstanceId')
        instance_type=$(extract_jq_value "$instance_data" '.InstanceType')
        instance_image_id=$(extract_jq_value "$instance_data" '.ImageId')
        instance_vpc_id=$(extract_jq_value "$instance_data" '.VpcId')
        instance_subnet_id=$(extract_jq_value "$instance_data" '.SubnetId')
        # Resolve VPC and Subnet to friendly names (prefer Tag 'Name'), then normalize for CSV
        instance_vpc_name=$(get_vpc_name "$instance_vpc_id" "$region" || echo "$instance_vpc_id")
        instance_vpc_name=$(normalize_csv_value "$instance_vpc_name")
        instance_subnet_name=$(get_subnet_name "$instance_subnet_id" "$region" || echo "$instance_subnet_id")
        instance_subnet_name=$(normalize_csv_value "$instance_subnet_name")
        instance_security_groups=$(extract_jq_array "$instance_data" '.SecurityGroups[].GroupName')
        instance_state=$(extract_jq_value "$instance_data" '.State.Name')
        buffer+="ec2,Instance,,${instance_name},${region},${instance_id},${instance_type},${instance_image_id},${instance_vpc_name},${instance_subnet_name},${instance_security_groups},${instance_state}\n"
    done < <(aws ec2 describe-instances --region "$region" | jq -c '.Reservations[].Instances[]')

    echo "$buffer"
}

#######################################
# collect_dynamodb_inventory: Collect DynamoDB inventory (with categories)
#
# Description:
#   Collects DynamoDB table details, Point-in-Time Recovery (PITR) info, and
#   time-to-live (TTL) configuration for each table in the given region.
#   Use "header" to return just the CSV header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows to stdout with primary table and backup metadata
#
# Usage:
#   collect_dynamodb_inventory "ap-northeast-1"
#######################################
function collect_dynamodb_inventory {
    local region=$1
    # Group fields by the AWS API call that produced them: describe-table -> describe-continuous-backups -> describe-time-to-live
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,AttributeDefinitions,BillingMode,StreamEnabled,GlobalTable,PointInTimeRecovery,RecoveryPeriodInDays,EarliestRestorableDateTime,LatestRestorableDateTime,DeletionProtection,TTLAttribute,SSE,KMSKey,ItemCount,TableSizeBytes,Status"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r table_name; do
        [[ -z "$table_name" || "$table_name" == "null" ]] && continue

        # --- AWS call: describe-table (table_details) ---
        # Get detailed table information (many fields rely on this output)
        local table_details
        table_details=$(aws dynamodb describe-table --table-name "$table_name" --region "$region" 2> /dev/null || echo '{"Table":{}}')

        # Fields derived from describe-table
        local table_arn attribute_definitions table_status billing_mode item_count table_size
        local sse_status stream_enabled global_table_version kms_arn kms_key_name

        table_arn=$(extract_jq_value "$table_details" '.Table.TableArn')
        attribute_definitions=$(extract_jq_array "$table_details" '.Table.AttributeDefinitions[]?')
        attribute_definitions=$(normalize_csv_value "$attribute_definitions")
        table_status=$(extract_jq_value "$table_details" '.Table.TableStatus')
        billing_mode=$(extract_jq_value "$table_details" '.Table.BillingModeSummary.BillingMode' 'PROVISIONED')
        item_count=$(extract_jq_value "$table_details" '.Table.ItemCount' '0')
        table_size=$(extract_jq_value "$table_details" '.Table.TableSizeBytes' '0')
        sse_status=$(extract_jq_value "$table_details" '.Table.SSEDescription.Status' 'DISABLED')
        stream_enabled=$(extract_jq_value "$table_details" '.Table.StreamSpecification.StreamEnabled' 'false')
        global_table_version=$(extract_jq_value "$table_details" '.Table.GlobalTableVersion')
        deletion_protection=$(extract_jq_value "$table_details" '.Table.DeletionProtectionEnabled' 'false')
        # KMS Key (alias/name) is derived from describe-table; resolve alias/KeyId to a friendly name
        # We compute it here next to the describe-table call for clarity and to reduce later coupling
        kms_arn=$(extract_jq_value "$table_details" '.Table.SSEDescription.KMSMasterKeyArn')
        kms_key_name=$(get_kms_name "$kms_arn" "$region" || echo "$kms_arn")
        kms_key_name=$(normalize_csv_value "$kms_key_name")

        # --- AWS call: describe-continuous-backups (pitr_details) ---
        # Get Point-in-Time Recovery status and backup information
        local pitr_details
        pitr_details=$(aws dynamodb describe-continuous-backups --table-name "$table_name" --region "$region" 2> /dev/null || echo '{"ContinuousBackupsDescription":{}}')
        pitr_enabled=$(extract_jq_value "$pitr_details" '.ContinuousBackupsDescription.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus' 'DISABLED')
        recovery_period=$(extract_jq_value "$pitr_details" '.ContinuousBackupsDescription.PointInTimeRecoveryDescription.RecoveryPeriodInDays')
        earliest_restorable=$(extract_jq_value "$pitr_details" '.ContinuousBackupsDescription.PointInTimeRecoveryDescription.EarliestRestorableDateTime')
        latest_restorable=$(extract_jq_value "$pitr_details" '.ContinuousBackupsDescription.PointInTimeRecoveryDescription.LatestRestorableDateTime')

        # --- AWS call: describe-time-to-live (ttl_details) ---
        # TTL attribute (Time To Live) - separate API to get the TTL attribute name
        local ttl_details ttl_attribute
        ttl_details=$(aws dynamodb describe-time-to-live --table-name "$table_name" --region "$region" 2> /dev/null || echo '{}')
        ttl_attribute=$(extract_jq_value "$ttl_details" '.TimeToLiveDescription.AttributeName')
        ttl_attribute=$(normalize_csv_value "$ttl_attribute")

        # Output: group all table_fields (describe-table), then pitr_fields, then ttl field
        buffer+="dynamodb,Table,,$table_name,${region},$table_arn,${attribute_definitions},$billing_mode,$stream_enabled,$global_table_version,$pitr_enabled,$recovery_period,$earliest_restorable,$latest_restorable,$deletion_protection,${ttl_attribute},$sse_status,${kms_key_name},${item_count},$table_size,$table_status\n"
    done < <(aws_paginate_items 'TableNames' aws dynamodb list-tables --region "$region" 2> /dev/null | jq -r '.' 2> /dev/null || true)

    echo "$buffer"
}

#######################################
# collect_ecr_inventory: Collect ECR inventory (with categories)
#
# Description:
#   Gathers ECR repository information in the given region, such as URI,
#   image counts, mutability, and creation date. Use "header" to print only
#   the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows to stdout; prints header when argument is "header"
#
# Usage:
#   collect_ecr_inventory "ap-northeast-1"
#######################################
function collect_ecr_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,URI,Mutability,Encryption,ImageCount,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r repo_data; do
        [[ -z "$repo_data" ]] && continue
        local repo_name repo_uri repo_created repo_image_count
        repo_name=$(extract_jq_value "$repo_data" '.repositoryName')
        repo_uri=$(extract_jq_value "$repo_data" '.repositoryUri')
        repo_mutability=$(extract_jq_value "$repo_data" '.imageTagMutability')
        repo_encryption=$(extract_jq_value "$repo_data" '.encryptionConfiguration.encryptionType' 'NONE')
        repo_created=$(extract_jq_value "$repo_data" '.createdAt')
        repo_image_count=$(extract_jq_value "$(aws_retry_exec aws ecr describe-images --repository-name "$repo_name" --region "$region" --output json 2> /dev/null || echo '{}')" '.imageDetails | length' '0')
        buffer+="ecr,Repository,,$repo_name,${region},$repo_uri,$repo_mutability,$repo_encryption,$repo_image_count,$repo_created\n"
    done < <(aws_paginate_items 'repositories' aws ecr describe-repositories --region "$region" || true)

    echo "$buffer"
}

#######################################
# collect_ecs_inventory: Collect ECS inventory (grouped by Cluster)
#
# Description:
#   Collects ECS clusters, services, task definitions, and scheduled tasks
#   for the region. Output is grouped by cluster with per-service and
#   task-definition rows. Use "header" to output the CSV header only.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Emits CSV formatted rows grouped by ECS cluster to stdout
#
# Usage:
#   collect_ecs_inventory "ap-northeast-1"
#######################################
function collect_ecs_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,RoleARN,TaskDefinition,LaunchType,Status,CronSchedule,Spec,RuntimePlatform,PortMappings,Environment"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Get AWS Account ID once for efficiency
    local aws_account_id
    if ! aws_account_id=$(get_aws_account_id); then
        aws_account_id="unknown"
        log "WARN" "Could not retrieve AWS account ID"
    fi

    # Get all clusters first
    local cluster_arns_raw
    cluster_arns_raw=$(aws ecs list-clusters --region "$region" --query 'clusterArns[]' --output text 2> /dev/null || true)
    if [[ -z "$cluster_arns_raw" || "$cluster_arns_raw" == "None" ]]; then
        echo ""
        return 0
    fi
    local cluster_arns
    cluster_arns=$(echo "$cluster_arns_raw" | tr '\t' '\n')

    # 事前にEventBridgeルールをregion単位で収集
    local eventbridge_rules
    eventbridge_rules=$(aws events list-rules --region "$region" --query "Rules[?State==\`ENABLED\`]" --output json 2> /dev/null || echo "[]")

    # 事前に全ScheduledTaskのターゲット情報を取得
    declare -A scheduled_tasks_by_cluster
    if [[ "$eventbridge_rules" != "[]" ]]; then
        while IFS= read -r rule_data; do
            [[ -z "$rule_data" ]] && continue
            local rule_name rule_schedule rule_state rule_arn
            rule_name=$(extract_jq_value "$rule_data" '.Name')
            rule_schedule=$(normalize_csv_value "$(extract_jq_value "$rule_data" '.ScheduleExpression')")
            rule_state=$(extract_jq_value "$rule_data" '.State')
            rule_arn="arn:aws:events:${region}:${aws_account_id}:rule/${rule_name}"
            local rule_targets
            rule_targets=$(aws events list-targets-by-rule --rule "$rule_name" --region "$region" 2> /dev/null || echo '{"Targets":[]}')
            # ECSターゲットを配列化してforループで処理
            mapfile -t ecs_targets < <(echo "$rule_targets" | jq -c '.Targets[]? | select(.EcsParameters?)')
            for ecs_target in "${ecs_targets[@]}"; do
                local cluster_arn task_def_arn task_launch_type task_def_name task_role_arn
                cluster_arn=$(extract_jq_value "$ecs_target" '.EcsParameters.ClusterArn // .Arn')
                task_def_arn=$(extract_jq_value "$ecs_target" '.EcsParameters.TaskDefinitionArn')
                task_launch_type=$(extract_jq_value "$ecs_target" '.EcsParameters.LaunchType')
                if [[ -n "$task_def_arn" && "$task_def_arn" != "N/A" ]]; then
                    task_def_name=$(basename "$task_def_arn" | cut -d':' -f1)
                    local task_def_details
                    task_def_details=$(aws_retry_exec aws ecs describe-task-definition --task-definition "$task_def_name" --region "$region" --query 'taskDefinition' --output json 2> /dev/null || echo '{}')
                    task_role_arn=$(extract_jq_value "$task_def_details" '.taskRoleArn // .executionRoleArn')
                else
                    task_def_arn="N/A"
                    task_def_name="N/A"
                    task_role_arn="N/A"
                fi
                local scheduled_row="ecs,,ScheduledTask,$rule_name,${region},$rule_arn,$task_role_arn,$task_def_arn,$task_launch_type,$rule_state,$rule_schedule,,,,\n"
                if [[ -n "$cluster_arn" ]]; then
                    scheduled_tasks_by_cluster[$cluster_arn]+="$scheduled_row"
                fi
            done
        done < <(echo "$eventbridge_rules" | jq -c '.[]')
    fi

    # 各クラスタごとに出力
    while IFS= read -r cluster_arn; do
        [[ -z "$cluster_arn" || "$cluster_arn" == "None" ]] && continue
        local cluster_data
        cluster_data=$(aws ecs describe-clusters --clusters "$cluster_arn" --region "$region" --query 'clusters[0]' 2> /dev/null) || continue
        local cluster_name cluster_status
        cluster_name=$(extract_jq_value "$cluster_data" '.clusterName')
        cluster_status=$(extract_jq_value "$cluster_data" '.status')
        local current_cluster_output=""
        current_cluster_output+="ecs,Cluster,,$cluster_name,${region},$cluster_arn,,,,$cluster_status,,,,,\n"

        # Get services for this cluster
        local service_arns_raw
        service_arns_raw=$(aws ecs list-services --cluster "$cluster_arn" --region "$region" --query 'serviceArns[]' --output text 2> /dev/null || true)

        if [[ -n "$service_arns_raw" && "$service_arns_raw" != "None" ]]; then
            # Convert tab-separated output to newline-separated
            local service_arns
            service_arns=$(echo "$service_arns_raw" | tr '\t' '\n')

            while IFS= read -r service_arn; do
                [[ -z "$service_arn" || "$service_arn" == "None" ]] && continue

                # Get service details
                local service_data
                service_data=$(aws ecs describe-services --cluster "$cluster_arn" --services "$service_arn" --region "$region" --query 'services[0]' 2> /dev/null) || continue

                local service_name service_status service_desired service_running service_task_def service_role service_launch_type
                service_name=$(extract_jq_value "$service_data" '.serviceName')
                service_status=$(extract_jq_value "$service_data" '.status')
                service_desired=$(extract_jq_value "$service_data" '.desiredCount')
                service_running=$(extract_jq_value "$service_data" '.runningCount')
                service_launch_type=$(extract_jq_value "$service_data" '.launchType')
                local service_status_detail="${service_status} (${service_running}/${service_desired})"

                # Get task definition details
                local task_def_arn service_task_def service_role service_task_def_arn
                task_def_arn=$(extract_jq_value "$service_data" '.taskDefinition')

                if [[ -n "$task_def_arn" && "$task_def_arn" != "null" ]]; then
                    service_task_def_arn="$task_def_arn"
                    service_task_def=$(echo "$task_def_arn" | sed 's/.*task-definition\/\([^:]*\).*/\1/')

                    # Get task role from task definition
                    local task_def_details task_role_arn
                    task_def_details=$(aws_retry_exec aws ecs describe-task-definition --task-definition "$service_task_def" --region "$region" --query 'taskDefinition' --output json 2> /dev/null || echo '{}')
                    task_role_arn=$(extract_jq_value "$task_def_details" '.taskRoleArn // .executionRoleArn')
                    service_role="$task_role_arn"
                else
                    service_task_def_arn="N/A"
                    service_task_def="N/A"
                    service_role="N/A"
                fi

                # Service row: Category,SubCategory,SubSubCcategory,Name,Region,ARN,Role ARN,TaskDefinition,LaunchType,Status,CronSchedule,Spec,RuntimePlatform
                # For services, CronSchedule and RuntimePlatform are empty
                current_cluster_output+="ecs,,Service,$service_name,${region},$service_arn,$service_role,$service_task_def_arn,$service_launch_type,$service_status_detail,,,,,\n"
            done <<< "$service_arns"
        fi

        # クラスタ直下にScheduledTask出力
        if [[ -n "${scheduled_tasks_by_cluster[$cluster_arn]:-}" ]]; then
            current_cluster_output+="${scheduled_tasks_by_cluster[$cluster_arn]}"
        fi
        buffer+="$current_cluster_output"
    done <<< "$cluster_arns"

    # Collect all Task Definition families (latest revision only, no duplicates)
    # Get unique task definition families first, then get latest revision for each
    declare -A task_def_families
    while IFS= read -r task_def_arn; do
        [[ -z "$task_def_arn" || "$task_def_arn" == "None" ]] && continue
        local family_name
        family_name=$(basename "$task_def_arn" | cut -d':' -f1)
        # Store only the latest revision for each family
        if [[ -z "${task_def_families[$family_name]:-}" ]]; then
            task_def_families[$family_name]="$task_def_arn"
        fi
    done < <(aws ecs list-task-definitions --region "$region" --query 'taskDefinitionArns[]' --output text 2> /dev/null | tr '\t' '\n')

    # Process each unique task definition family (latest revision only)
    for family_name in "${!task_def_families[@]}"; do
        local task_def_arn="${task_def_families[$family_name]}"

        # Get task definition details
        local task_def_details task_def_status task_role_arn task_def_cpu task_def_memory task_def_network_mode task_def_requires_attributes task_def_revision

        # Get detailed task definition information for the latest revision
        task_def_details=$(aws_retry_exec aws ecs describe-task-definition --task-definition "$family_name" --region "$region" --query 'taskDefinition' --output json 2> /dev/null || echo '{}')

        if [[ "$task_def_details" != "{}" ]]; then
            task_def_status=$(extract_jq_value "$task_def_details" '.status')
            task_role_arn=$(extract_jq_value "$task_def_details" '.taskRoleArn // .executionRoleArn')
            task_def_cpu=$(extract_jq_value "$task_def_details" '.cpu')
            task_def_memory=$(extract_jq_value "$task_def_details" '.memory')
            task_def_network_mode=$(extract_jq_value "$task_def_details" '.networkMode')
            task_def_requires_attributes=$(extract_jq_array "$task_def_details" '.requiresAttributes[].name')
            task_def_revision=$(extract_jq_value "$task_def_details" '.revision')
            task_def_arn=$(extract_jq_value "$task_def_details" '.taskDefinitionArn')

            # Get runtime platform information
            local task_def_runtime_os task_def_runtime_arch task_def_runtime_platform
            task_def_runtime_os=$(extract_jq_value "$task_def_details" '.runtimePlatform.operatingSystemFamily')
            task_def_runtime_arch=$(extract_jq_value "$task_def_details" '.runtimePlatform.cpuArchitecture')

            # Format runtime platform as OS/ARCH or fallback to default
            if [[ -n "$task_def_runtime_os" && "$task_def_runtime_os" != "N/A" ]] && [[ -n "$task_def_runtime_arch" && "$task_def_runtime_arch" != "N/A" ]]; then
                task_def_runtime_platform="${task_def_runtime_os}/${task_def_runtime_arch}"
            else
                task_def_runtime_platform="LINUX/X86_64" # Default for ECS
            fi

            # Get port mappings information
            local task_def_port_mappings
            task_def_port_mappings=$(echo "$task_def_details" | jq -r '.containerDefinitions[]?.portMappings[]? | "\(.containerPort):\(.hostPort // "dynamic"):\(.protocol // "tcp")"' 2> /dev/null | paste -sd ',' - || echo "")

            # Apply normalize_csv_value to port mappings
            task_def_port_mappings=$(normalize_csv_value "$task_def_port_mappings")

            # Get environment variables information
            local task_def_environment
            task_def_environment=$(echo "$task_def_details" | jq -r '.containerDefinitions[]?.environment[]? | "\(.name)=\(.value)"' 2> /dev/null | paste -sd $'\n' - || echo "")

            # Apply normalize_csv_value to environment variables
            task_def_environment=$(normalize_csv_value "$task_def_environment")

            # Format requires attributes for display
            if [[ -n "$task_def_requires_attributes" && "$task_def_requires_attributes" != "N/A" ]]; then
                task_def_requires_attributes=$(echo "$task_def_requires_attributes" | tr ',' ';')
            fi

            # TaskDefinition row: Category,SubCategory,SubSubCcategory,Name,Region,ARN,Role ARN,TaskDefinition,LaunchType,Status,CronSchedule,Spec,RuntimePlatform,PortMappings,Environment
            # For TaskDefinitions: LaunchType is empty, Status shows actual status, CronSchedule is empty, Spec shows CPU/Memory/NetworkMode, RuntimePlatform shows OS/ARCH, PortMappings shows container:host:protocol, Environment shows name=value pairs
            local task_def_details_summary="${task_def_cpu}CPU/${task_def_memory}MB/${task_def_network_mode}"
            buffer+="ecs,TaskDefinition,,$family_name:${task_def_revision},${region},$task_def_arn,$task_role_arn,$task_def_arn,,$task_def_status,,$task_def_details_summary,$task_def_runtime_platform,$task_def_port_mappings,$task_def_environment\n"
        fi
    done

    echo "$buffer"
}

#######################################
# collect_efs_inventory: Collect EFS inventory (with categories)
#
# Description:
#   Retrieves EFS file systems, mount targets, and access points for the
#   provided region and formats the results as CSV rows. Use "header" to
#   print only the CSV header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Prints CSV formatted EFS rows to stdout
#
# Usage:
#   collect_efs_inventory "ap-northeast-1"
#######################################
function collect_efs_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,Type,Performance,Throughput,Encrypted,Size,Subnet,IPAddress,SecurityGroup,Path,UID,GID,State,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Get File Systems
    while IFS= read -r fs_data; do
        [[ -z "$fs_data" ]] && continue
        local fs_id fs_name fs_state fs_creation_time fs_size fs_performance_mode fs_throughput_mode fs_encrypted
        fs_id=$(extract_jq_value "$fs_data" '.FileSystemId')
        fs_name=$(extract_jq_value "$fs_data" '.Name')
        fs_state=$(extract_jq_value "$fs_data" '.LifeCycleState')
        fs_creation_time=$(extract_jq_value "$fs_data" '.CreationTime')
        fs_size=$(extract_jq_value "$fs_data" '.SizeInBytes.Value')
        fs_performance_mode=$(extract_jq_value "$fs_data" '.PerformanceMode')
        fs_throughput_mode=$(extract_jq_value "$fs_data" '.ThroughputMode')
        fs_encrypted=$(extract_jq_value "$fs_data" '.Encrypted')

        # FileSystem: Core info with empty fields for mount-target-specific data
        buffer+="efs,FileSystem,,$fs_name,${region},$fs_id,FileSystem,$fs_performance_mode,$fs_throughput_mode,$fs_encrypted,$fs_size,,,,,,$fs_state,$fs_creation_time\n"

        # Get Mount Targets for this File System
        while IFS= read -r mt_data; do
            [[ -z "$mt_data" ]] && continue
            local mt_id mt_subnet_id mt_ip mt_state mt_security_groups
            mt_id=$(extract_jq_value "$mt_data" '.MountTargetId')
            mt_subnet_id=$(extract_jq_value "$mt_data" '.SubnetId')
            mt_ip=$(extract_jq_value "$mt_data" '.IpAddress')
            mt_state=$(extract_jq_value "$mt_data" '.LifeCycleState')

            # Get security groups for this mount target
            mt_security_groups=$(extract_jq_value "$(aws efs describe-mount-target-security-groups --mount-target-id "$mt_id" --region "$region" 2> /dev/null || echo '{}')" '.SecurityGroups | join(",")')

            # MountTarget: Core info with empty fields for filesystem-specific and accesspoint-specific data
            buffer+="efs,MountTarget,,$mt_id,${region},$mt_id,MountTarget,,,,,$mt_subnet_id,$mt_ip,$mt_security_groups,,,,$mt_state,\n"
        done < <(aws efs describe-mount-targets --file-system-id "$fs_id" --region "$region" 2> /dev/null | jq -c '.MountTargets[]' || true)

        # Get Access Points for this File System
        while IFS= read -r ap_data; do
            [[ -z "$ap_data" ]] && continue
            local ap_id ap_name ap_state ap_path ap_uid ap_gid
            ap_id=$(extract_jq_value "$ap_data" '.AccessPointId')
            ap_name=$(extract_jq_value "$ap_data" '.Name')
            ap_state=$(extract_jq_value "$ap_data" '.LifeCycleState')
            ap_path=$(extract_jq_value "$ap_data" '.RootDirectory.Path')
            ap_uid=$(extract_jq_value "$ap_data" '.PosixUser.Uid')
            ap_gid=$(extract_jq_value "$ap_data" '.PosixUser.Gid')

            # Use default "/" for path if empty
            if [[ -z "$ap_path" || "$ap_path" == "N/A" ]]; then
                ap_path="/"
            fi

            # AccessPoint: Core info with empty fields for filesystem-specific and mount-target-specific data
            buffer+="efs,AccessPoint,,$ap_name,${region},$ap_id,AccessPoint,,,,,,,,$ap_path,$ap_uid,$ap_gid,$ap_state,\n"
        done < <(aws efs describe-access-points --file-system-id "$fs_id" --region "$region" 2> /dev/null | jq -c '.AccessPoints[]' || true)

    done < <(aws efs describe-file-systems --region "$region" 2> /dev/null | jq -c '.FileSystems[]' || true)

    echo "$buffer"
}

#######################################
# collect_elasticache_inventory: Collect ElastiCache inventory (with categories)
#
# Description:
#   Collects ElastiCache Replication Groups and Cache Clusters for a given
#   region and formats the data as CSV rows.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted rows to stdout; prints header if called with "header"
#
# Usage:
#   collect_elasticache_inventory "us-east-1"
#######################################
function collect_elasticache_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Description,ReplicationGroupID,ClusterID,Engine,Version,NodeType,NodeGroups,NumNodes,CacheParameterGroup,SecurityGroup,MultiAZ,AutomaticFailover,EncryptedAtRest,EncryptedTransit,AuthTokenEnabled,AutoMinorVersionUpgrade,PreferredMaintenanceWindow,SnapshotRetentionLimit,SnapshotWindow,CreateTime,Status"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Get all Replication Groups
    local replication_groups
    replication_groups=$(aws elasticache describe-replication-groups --region "$region" 2> /dev/null || echo '{"ReplicationGroups":[]}')

    # Get all Cache Clusters
    local cache_clusters
    cache_clusters=$(aws elasticache describe-cache-clusters --region "$region" 2> /dev/null || echo '{"CacheClusters":[]}')

    # Process Replication Groups
    while IFS= read -r rg_data; do
        [[ -z "$rg_data" ]] && continue
        local rg_id rg_status rg_node_type rg_multi_az rg_auth rg_at_rest rg_transit
        rg_id=$(extract_jq_value "$rg_data" '.ReplicationGroupId')
        rg_arn=$(extract_jq_value "$rg_data" '.ARN')
        rg_description=$(extract_jq_value "$rg_data" '.Description')
        rg_engine=$(extract_jq_value "$rg_data" '.Engine')
        rg_node_type=$(extract_jq_value "$rg_data" '.CacheNodeType')
        rg_multi_az=$(extract_jq_value "$rg_data" '.MultiAZ')
        rg_automatic_failover=$(extract_jq_value "$rg_data" '.AutomaticFailover')
        rg_node_groups=$(normalize_csv_value "$(extract_jq_value "$rg_data" '.NodeGroups[]')")
        rg_auth=$(extract_jq_value "$rg_data" '.AuthTokenEnabled')
        rg_at_rest=$(extract_jq_value "$rg_data" '.AtRestEncryptionEnabled')
        rg_transit=$(extract_jq_value "$rg_data" '.TransitEncryptionEnabled')
        rg_auto_minor_version_upgrade=$(extract_jq_value "$rg_data" '.AutoMinorVersionUpgrade')
        rg_snapshot_retention_limit=$(extract_jq_value "$rg_data" '.SnapshotRetentionLimit')
        rg_snapshot_window=$(extract_jq_value "$rg_data" '.SnapshotWindow')
        rg_create_time=$(extract_jq_value "$rg_data" '.ReplicationGroupCreateTime')
        rg_status=$(extract_jq_value "$rg_data" '.Status')

        buffer+="elasticache,ReplicationGroup,,$rg_id,${region},$rg_arn,$rg_description,$rg_id,,$rg_engine,,$rg_node_type,$rg_node_groups,,,,$rg_multi_az,$rg_automatic_failover,$rg_at_rest,$rg_transit,$rg_auth,$rg_auto_minor_version_upgrade,,$rg_snapshot_retention_limit,$rg_snapshot_window,$rg_create_time,$rg_status\n"

        # Iterate all cache clusters to find members of this replication group
        while IFS= read -r cc_data; do
            [[ -z "$cc_data" ]] && continue
            local cc_rg_id
            cc_rg_id=$(extract_jq_value "$cc_data" '.ReplicationGroupId')

            if [[ "$cc_rg_id" == "$rg_id" ]]; then
                local cc_id cc_status cc_engine cc_version cc_node_type cc_num_nodes cc_arn cc_create_time
                cc_id=$(extract_jq_value "$cc_data" '.CacheClusterId')
                cc_arn=$(extract_jq_value "$cc_data" '.ARN')
                cc_engine=$(extract_jq_value "$cc_data" '.Engine')
                cc_version=$(extract_jq_value "$cc_data" '.EngineVersion')
                cc_node_type=$(extract_jq_value "$cc_data" '.CacheNodeType')
                cc_num_nodes=$(extract_jq_value "$cc_data" '.NumCacheNodes')
                cc_cache_parameter_group=$(normalize_csv_value "$(extract_jq_value "$cc_data" '.CacheParameterGroup')")

                # Resolve Security Group IDs to Names
                local cc_sg_list_raw cc_sg_name_list_raw cc_sg_id cc_sg_name
                cc_sg_list_raw=$(echo "$cc_data" | jq -r '.SecurityGroups[].SecurityGroupId' 2> /dev/null || echo "")
                cc_sg_name_list_raw=""
                if [[ -n "$cc_sg_list_raw" && "$cc_sg_list_raw" != "null" ]]; then
                    while IFS= read -r cc_sg_id; do
                        [[ -z "$cc_sg_id" || "$cc_sg_id" == "null" ]] && continue
                        cc_sg_name=$(get_security_group_name "$cc_sg_id" "$region" || echo "$cc_sg_id")
                        if [[ -z "$cc_sg_name" ]]; then cc_sg_name="$cc_sg_id"; fi
                        if [[ -z "$cc_sg_name_list_raw" ]]; then
                            cc_sg_name_list_raw="$cc_sg_name"
                        else
                            cc_sg_name_list_raw+=$'\n'$cc_sg_name
                        fi
                    done <<< "$cc_sg_list_raw"
                fi
                cc_security_groups=$(normalize_csv_value "$cc_sg_name_list_raw")

                cc_at_rest=$(extract_jq_value "$cc_data" '.AtRestEncryptionEnabled')
                cc_transit=$(extract_jq_value "$cc_data" '.TransitEncryptionEnabled')
                cc_auth=$(extract_jq_value "$cc_data" '.AuthTokenEnabled')
                cc_create_time=$(extract_jq_value "$cc_data" '.CacheClusterCreateTime')
                cc_auto_minor_version_upgrade=$(extract_jq_value "$cc_data" '.AutoMinorVersionUpgrade')
                cc_preferred_maintenance_window=$(extract_jq_value "$cc_data" '.PreferredMaintenanceWindow')
                cc_snapshot_retention_limit=$(extract_jq_value "$cc_data" '.SnapshotRetentionLimit')
                cc_snapshot_window=$(extract_jq_value "$cc_data" '.SnapshotWindow')
                cc_status=$(extract_jq_value "$cc_data" '.CacheClusterStatus')

                buffer+="elasticache,,CacheCluster,$cc_id,${region},$cc_arn,,$cc_rg_id,$cc_id,$cc_engine,$cc_version,$cc_node_type,,$cc_num_nodes,$cc_cache_parameter_group,$cc_security_groups,,,$cc_at_rest,$cc_transit,$cc_auth,$cc_auto_minor_version_upgrade,$cc_preferred_maintenance_window,$cc_snapshot_retention_limit,$cc_snapshot_window,$cc_create_time,$cc_status\n"
            fi
        done < <(echo "$cache_clusters" | jq -c '.CacheClusters[]' || true)

    done < <(echo "$replication_groups" | jq -c '.ReplicationGroups[]' || true)

    # Process Standalone Cache Clusters (those without ReplicationGroupId)
    while IFS= read -r cc_data; do
        [[ -z "$cc_data" ]] && continue
        local cc_rg_id
        cc_rg_id=$(extract_jq_value "$cc_data" '.ReplicationGroupId')

        if [[ -z "$cc_rg_id" || "$cc_rg_id" == "null" ]]; then
            local cc_id cc_status cc_engine cc_version cc_node_type cc_num_nodes cc_arn cc_create_time
            cc_id=$(extract_jq_value "$cc_data" '.CacheClusterId')
            cc_arn=$(extract_jq_value "$cc_data" '.ARN')
            cc_engine=$(extract_jq_value "$cc_data" '.Engine')
            cc_version=$(extract_jq_value "$cc_data" '.EngineVersion')
            cc_node_type=$(extract_jq_value "$cc_data" '.CacheNodeType')
            cc_num_nodes=$(extract_jq_value "$cc_data" '.NumCacheNodes')
            cc_cache_parameter_group=$(normalize_csv_value "$(extract_jq_value "$cc_data" '.CacheParameterGroup')")

            # Resolve Security Group IDs to Names
            local cc_sg_list_raw cc_sg_name_list_raw cc_sg_id cc_sg_name
            cc_sg_list_raw=$(echo "$cc_data" | jq -r '.SecurityGroups[].SecurityGroupId' 2> /dev/null || echo "")
            cc_sg_name_list_raw=""
            if [[ -n "$cc_sg_list_raw" && "$cc_sg_list_raw" != "null" ]]; then
                while IFS= read -r cc_sg_id; do
                    [[ -z "$cc_sg_id" || "$cc_sg_id" == "null" ]] && continue
                    cc_sg_name=$(get_security_group_name "$cc_sg_id" "$region" || echo "$cc_sg_id")
                    if [[ -z "$cc_sg_name" ]]; then cc_sg_name="$cc_sg_id"; fi
                    if [[ -z "$cc_sg_name_list_raw" ]]; then
                        cc_sg_name_list_raw="$cc_sg_name"
                    else
                        cc_sg_name_list_raw+=$'\n'$cc_sg_name
                    fi
                done <<< "$cc_sg_list_raw"
            fi
            cc_security_groups=$(normalize_csv_value "$cc_sg_name_list_raw")

            cc_at_rest=$(extract_jq_value "$cc_data" '.AtRestEncryptionEnabled')
            cc_transit=$(extract_jq_value "$cc_data" '.TransitEncryptionEnabled')
            cc_auth=$(extract_jq_value "$cc_data" '.AuthTokenEnabled')
            cc_auto_minor_version_upgrade=$(extract_jq_value "$cc_data" '.AutoMinorVersionUpgrade')
            cc_preferred_maintenance_window=$(extract_jq_value "$cc_data" '.PreferredMaintenanceWindow')
            cc_snapshot_retention_limit=$(extract_jq_value "$cc_data" '.SnapshotRetentionLimit')
            cc_snapshot_window=$(extract_jq_value "$cc_data" '.SnapshotWindow')
            cc_create_time=$(extract_jq_value "$cc_data" '.CacheClusterCreateTime')
            cc_status=$(extract_jq_value "$cc_data" '.CacheClusterStatus')

            buffer+="elasticache,CacheCluster,,$cc_id,${region},$cc_arn,,,$cc_id,$cc_engine,$cc_version,$cc_node_type,,$cc_num_nodes,$cc_cache_parameter_group,$cc_security_groups,,,$cc_at_rest,$cc_transit,$cc_auth,$cc_auto_minor_version_upgrade,$cc_preferred_maintenance_window,$cc_snapshot_retention_limit,$cc_snapshot_window,$cc_create_time,$cc_status\n"
        fi
    done < <(echo "$cache_clusters" | jq -c '.CacheClusters[]' || true)

    echo "$buffer"
}

#######################################
# collect_elb_inventory: Collect ELB inventory (with categories)
#
# Description:
#   Collects ELB (ALB / NLB) and related resources (target groups, listeners)
#   for the specified region and returns CSV lines. Use "header" to return
#   only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows describing load balancers, target groups, listeners
#
# Usage:
#   collect_elb_inventory "ap-northeast-1"
#######################################
function collect_elb_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,DNSName,Type,VPC,AvailabilityZone,SecurityGroup,WAF,Protocol,Port,HealthCheck,SSLPolicy,State,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r elb_data; do
        [[ -z "$elb_data" ]] && continue
        local elb_arn elb_name elb_dns elb_type elb_vpc elb_vpc_name elb_az elb_state elb_waf elb_created
        elb_arn=$(extract_jq_value "$elb_data" '.LoadBalancerArn')
        elb_name=$(extract_jq_value "$elb_data" '.LoadBalancerName')
        elb_dns=$(extract_jq_value "$elb_data" '.DNSName')
        elb_type=$(extract_jq_value "$elb_data" '.Type')
        # Extract VPC ID and Availability Zones (join multiple AZs with newline for normalize_csv_value)
        elb_vpc=$(extract_jq_value "$elb_data" '.VpcId')
        # Resolve VPC ID to friendly name (fallback to ID) and normalize for CSV
        elb_vpc_name=$(get_vpc_name "$elb_vpc" "$region" || echo "$elb_vpc")
        elb_vpc_name=$(normalize_csv_value "$elb_vpc_name")
        elb_az_raw=$(echo "$elb_data" | jq -r '.AvailabilityZones? // [] | map(.ZoneName) | join("\n")' 2> /dev/null || echo "")
        elb_az=$(normalize_csv_value "$elb_az_raw")
        elb_state=$(extract_jq_value "$elb_data" '.State.Code')
        elb_created=$(extract_jq_value "$elb_data" '.CreatedTime')
        # Retrieve WAF association JSON safely into a variable, then extract ARN
        local elb_waf_json
        elb_waf_json=$(aws wafv2 get-web-acl-for-resource --resource-arn "$elb_arn" --region "$region" 2> /dev/null || echo '{}')
        elb_waf=$(extract_jq_value "$elb_waf_json" '.WebACL.ARN')
        # Extract associated Security Groups for the load balancer (may be empty for NLBs)
        local sg_list_raw sg_name_list_raw sg_name_list sg_id sg_name
        # Try to read SecurityGroups from the LoadBalancer attributes returned by describe-load-balancers
        sg_list_raw=$(echo "$elb_data" | jq -r '.SecurityGroups? // [] | join("\n")' 2> /dev/null || echo "")
        sg_name_list_raw=""
        if [[ -n "$sg_list_raw" && "$sg_list_raw" != "null" ]]; then
            while IFS= read -r sg_id; do
                [[ -z "$sg_id" || "$sg_id" == "null" ]] && continue
                # Resolve SG ID to name (fallback to ID if not resolvable)
                sg_name=$(get_security_group_name "$sg_id" "$region" || echo "$sg_id")
                if [[ -z "$sg_name" ]]; then sg_name="$sg_id"; fi
                if [[ -z "$sg_name_list_raw" ]]; then
                    sg_name_list_raw="$sg_name"
                else
                    sg_name_list_raw+=$'\n'$sg_name
                fi
            done <<< "$sg_list_raw"
        fi
        sg_name_list=$(normalize_csv_value "$sg_name_list_raw")

        buffer+="elb,LoadBalancer,,$elb_name,${region},$elb_arn,$elb_dns,$elb_type,${elb_vpc_name},${elb_az},${sg_name_list},${elb_waf},,,,,${elb_state},${elb_created}\n"

        # Target Groups
        while IFS= read -r tg_data; do
            [[ -z "$tg_data" ]] && continue
            local tg_arn tg_name tg_type tg_protocol tg_port tg_health_check
            tg_arn=$(extract_jq_value "$tg_data" '.TargetGroupArn')
            tg_name=$(extract_jq_value "$tg_data" '.TargetGroupName')
            tg_type=$(extract_jq_value "$tg_data" '.TargetType')
            tg_protocol=$(extract_jq_value "$tg_data" '.Protocol')
            tg_port=$(extract_jq_value "$tg_data" '.Port')
            tg_health_check=$(extract_jq_value "$tg_data" '.HealthCheckPath')
            buffer+="elb,,TargetGroup,$tg_name,${region},$tg_arn,,$tg_type,,,,,$tg_protocol,$tg_port,$tg_health_check,,,\n"
        done < <(aws elbv2 describe-target-groups --load-balancer-arn "$elb_arn" --region "$region" 2> /dev/null | jq -c '.TargetGroups[]?' || echo "")

        # Listeners
        while IFS= read -r listener_data; do
            [[ -z "$listener_data" ]] && continue
            local listener_arn listener_protocol listener_port listener_ssl_policy
            listener_arn=$(extract_jq_value "$listener_data" '.ListenerArn')
            listener_protocol=$(extract_jq_value "$listener_data" '.Protocol')
            listener_port=$(extract_jq_value "$listener_data" '.Port')
            listener_ssl_policy=$(extract_jq_value "$listener_data" '.SslPolicy')
            buffer+="elb,,Listener,${listener_protocol}:${listener_port},${region},$listener_arn,,,,,,,$listener_protocol,$listener_port,,$listener_ssl_policy,,\n"
        done < <(aws elbv2 describe-listeners --load-balancer-arn "$elb_arn" --region "$region" 2> /dev/null | jq -c '.Listeners[]?' || echo "")
    done < <(aws elbv2 describe-load-balancers --region "$region" | jq -c '.LoadBalancers[]')

    echo "$buffer"
}

#######################################
# collect_eventbridge_inventory: Collect EventBridge inventory (with categories)
#
# Description:
#   Collects EventBridge rules and EventBridge Scheduler schedules for the
#   given region, and outputs CSV rows with schedule and target information.
#   Use "header" to only return the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Emits CSV formatted EventBridge rows to stdout
#
# Usage:
#   collect_eventbridge_inventory "ap-northeast-1"
#######################################
function collect_eventbridge_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Description,RoleARN,ScheduleExpression,Target,RetryMaxAttempts,RetryMaxEventAgeSeconds,State"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Collect EventBridge Rules
    while IFS= read -r rule_data; do
        [[ -z "$rule_data" ]] && continue
        local rule_name rule_arn rule_state rule_description rule_schedule rule_role
        rule_name=$(extract_jq_value "$rule_data" '.Name')
        rule_arn=$(extract_jq_value "$rule_data" '.Arn')
        rule_state=$(extract_jq_value "$rule_data" '.State')
        rule_description=$(normalize_csv_value "$(extract_jq_value "$rule_data" '.Description')")
        rule_schedule=$(normalize_csv_value "$(extract_jq_value "$rule_data" '.ScheduleExpression')")

        # Get targets for this rule to determine role
        local targets_data rule_target_info
        targets_data=$(aws events list-targets-by-rule --rule "$rule_name" --region "$region" 2> /dev/null || echo '{"Targets":[]}')

        # Get first target's role and ARN (automatically get N/A if empty)
        rule_role=$(extract_jq_value "$targets_data" '.Targets[0].RoleArn')
        rule_target_info=$(extract_jq_value "$targets_data" '.Targets[0].Arn')

        # Extract RetryPolicy details (separate columns) if present on the first target
        local rule_retry_max_attempts rule_retry_max_age
        rule_retry_max_attempts=$(extract_jq_value "$targets_data" '.Targets[0].RetryPolicy.MaximumRetryAttempts' '')
        rule_retry_max_age=$(extract_jq_value "$targets_data" '.Targets[0].RetryPolicy.MaximumEventAgeInSeconds' '')

        # Apply normalize_csv_value to fields that may contain commas
        rule_description=$(normalize_csv_value "$rule_description")
        rule_target_info=$(normalize_csv_value "$rule_target_info")
        rule_retry_max_attempts=$(normalize_csv_value "$rule_retry_max_attempts")
        rule_retry_max_age=$(normalize_csv_value "$rule_retry_max_age")

        # Rule row: EventBridge Rule (split Retry into two columns)
        buffer+="eventbridge,Rule,,$rule_name,${region},$rule_arn,$rule_description,$rule_role,$rule_schedule,$rule_target_info,$rule_retry_max_attempts,$rule_retry_max_age,$rule_state\n"

    done < <(aws events list-rules --region "$region" 2> /dev/null | jq -c '.Rules[]' || true)

    # Collect EventBridge Schedules (from EventBridge Scheduler)
    while IFS= read -r schedule_data; do
        [[ -z "$schedule_data" ]] && continue
        local schedule_name schedule_arn schedule_state schedule_description schedule_expression schedule_role schedule_target
        schedule_name=$(extract_jq_value "$schedule_data" '.Name')
        schedule_arn=$(extract_jq_value "$schedule_data" '.Arn')
        schedule_state=$(extract_jq_value "$schedule_data" '.State')

        # Get detailed schedule information
        local schedule_details
        schedule_details=$(aws scheduler get-schedule --name "$schedule_name" --region "$region" 2> /dev/null || echo '{}')

        schedule_description=$(normalize_csv_value "$(extract_jq_value "$schedule_details" '.Description')")
        schedule_expression=$(extract_jq_value "$schedule_details" '.ScheduleExpression')

        # Get target role and target ARN
        schedule_role=$(extract_jq_value "$schedule_details" '.Target.RoleArn')
        schedule_target=$(extract_jq_value "$schedule_details" '.Target.Arn')

        # Extract RetryPolicy details (separate columns) if present on scheduler target
        local schedule_retry_max_attempts schedule_retry_max_age
        schedule_retry_max_attempts=$(extract_jq_value "$schedule_details" '.Target.RetryPolicy.MaximumRetryAttempts' '')
        schedule_retry_max_age=$(extract_jq_value "$schedule_details" '.Target.RetryPolicy.MaximumEventAgeInSeconds' '')

        # Apply normalize_csv_value to fields that may contain commas
        schedule_description=$(normalize_csv_value "$schedule_description")
        schedule_expression=$(normalize_csv_value "$schedule_expression")
        schedule_target=$(normalize_csv_value "$schedule_target")
        schedule_retry_max_attempts=$(normalize_csv_value "$schedule_retry_max_attempts")
        schedule_retry_max_age=$(normalize_csv_value "$schedule_retry_max_age")

        # Schedule row: EventBridge Scheduler
        buffer+="eventbridge,Scheduler,,$schedule_name,${region},$schedule_arn,$schedule_description,$schedule_role,$schedule_expression,$schedule_target,$schedule_retry_max_attempts,$schedule_retry_max_age,$schedule_state\n"

    done < <(aws scheduler list-schedules --region "$region" 2> /dev/null | jq -c '.Schedules[]' || true)

    echo "$buffer"
}

#######################################
# collect_glue_inventory: Collect Glue inventory (with categories)
#
# Description:
#   Collects AWS Glue databases and jobs for the specified region and returns
#   CSV formatted records. Use "header" to return only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows containing Glue database and job information
#
# Usage:
#   collect_glue_inventory "ap-northeast-1"
#######################################
function collect_glue_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,Description,RoleARN,Timeout,WorkerType,NumberOfWorkers,MaxRetries,GlueVersion,Language,ScriptLocation"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Collect Databases
    while IFS= read -r db_data; do
        [[ -z "$db_data" ]] && continue
        local db_name db_description
        db_name=$(extract_jq_value "$db_data" '.Name')
        db_description=$(normalize_csv_value "$(extract_jq_value "$db_data" '.Description')")
        # Database: Description,Location filled, job-specific fields empty
        buffer+="glue,Database,,$db_name,${region},$db_name,$db_description,,,,,,,\n"
    done < <(aws glue get-databases --region "$region" | jq -c '.DatabaseList[]')

    # Collect Jobs
    while IFS= read -r job_data; do
        [[ -z "$job_data" ]] && continue
        local job_name job_role job_timeout job_worker_type job_max_retries job_script_location job_num_workers job_glue_version job_language job_command_type
        job_name=$(extract_jq_value "$job_data" '.Name')
        job_description=$(normalize_csv_value "$(extract_jq_value "$job_data" '.Description')")
        job_role=$(extract_jq_value "$job_data" '.Role')
        job_timeout=$(extract_jq_value "$job_data" '.Timeout')
        job_worker_type=$(extract_jq_value "$job_data" '.WorkerType')
        job_max_retries=$(extract_jq_value "$job_data" '.MaxRetries')
        job_num_workers=$(extract_jq_value "$job_data" '.NumberOfWorkers')
        job_glue_version=$(extract_jq_value "$job_data" '.GlueVersion')
        job_command_type=$(extract_jq_value "$job_data" '.Command.Name')

        # Get Python version or determine language from job type
        local python_version
        python_version=$(extract_jq_value "$job_data" '.Command.PythonVersion')
        if [[ -n "$python_version" && "$python_version" != "N/A" ]]; then
            job_language="Python${python_version}"
        elif [[ "$job_command_type" == "glueetl" || "$job_command_type" == "pythonshell" ]]; then
            job_language="Python3" # Default for ETL and Python shell jobs
        else
            job_language="$job_command_type" # Use command type as fallback
        fi

        job_script_location=$(extract_jq_value "$job_data" '.Command.ScriptLocation')
        # Job: database-specific fields empty, job-specific fields filled
        buffer+="glue,Job,,$job_name,${region},$job_name,$job_description,$job_role,$job_timeout,$job_worker_type,$job_num_workers,$job_max_retries,$job_glue_version,$job_language,$job_script_location\n"
    done < <(aws glue get-jobs --region "$region" | jq -c '.Jobs[]')

    echo "$buffer"
}

#######################################
# collect_iam_inventory: Collect IAM inventory (with categories)
#
# Description:
#   Retrieves IAM Roles, Users, and local Policies and returns CSV rows
#   describing each resource. This function only runs for Global (us-east-1)
#   context and will return nothing for other regions.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted IAM rows to stdout (header if requested)
#
# Usage:
#   collect_iam_inventory "us-east-1"
#######################################
function collect_iam_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Path,CreateDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    # IAM is a global service, only process from us-east-1
    if [[ "$region" != "us-east-1" ]]; then
        echo ""
        return 0
    fi

    local buffer=""

    while IFS= read -r role_data; do
        [[ -z "$role_data" ]] && continue
        local role_name role_arn role_path role_created
        role_name=$(extract_jq_value "$role_data" '.RoleName')
        role_arn=$(extract_jq_value "$role_data" '.Arn')
        role_path=$(extract_jq_value "$role_data" '.Path')
        role_created=$(extract_jq_value "$role_data" '.CreateDate')
        buffer+="iam,Role,,$role_name,Global,$role_arn,$role_path,$role_created\n"
    done < <(aws iam list-roles | jq -c '.Roles[]')

    while IFS= read -r user_data; do
        [[ -z "$user_data" ]] && continue
        local user_name user_arn user_path user_created
        user_name=$(extract_jq_value "$user_data" '.UserName')
        user_arn=$(extract_jq_value "$user_data" '.Arn')
        user_path=$(extract_jq_value "$user_data" '.Path')
        user_created=$(extract_jq_value "$user_data" '.CreateDate')
        buffer+="iam,User,,$user_name,Global,$user_arn,$user_path,$user_created\n"
    done < <(aws iam list-users | jq -c '.Users[]')

    while IFS= read -r policy_data; do
        [[ -z "$policy_data" ]] && continue
        local policy_name policy_arn policy_path policy_created
        policy_name=$(extract_jq_value "$policy_data" '.PolicyName')
        policy_arn=$(extract_jq_value "$policy_data" '.Arn')
        policy_path=$(extract_jq_value "$policy_data" '.Path')
        policy_created=$(extract_jq_value "$policy_data" '.CreateDate')
        buffer+="iam,Policy,,$policy_name,Global,$policy_arn,$policy_path,$policy_created\n"
    done < <(aws iam list-policies --scope Local | jq -c '.Policies[]')

    echo "$buffer"
}

#######################################
# collect_kinesis_inventory: Collect Kinesis inventory (with categories)
#
# Description:
#   Gathers Kinesis Streams and Firehose delivery stream details for the
#   given region and emits CSV rows with common attributes like ARN, status
#   and shard counts. Use "header" to output header only.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows to stdout describing Kinesis data streams and firehose
#
# Usage:
#   collect_kinesis_inventory "ap-northeast-1"
#######################################
function collect_kinesis_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Status,Shards,DestinationId,RetentionPeriodHours,CreatedDate,LastModifiedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Kinesis Streams
    while IFS= read -r stream_name; do
        [[ -z "$stream_name" ]] && continue
        local stream_desc stream_arn stream_status stream_shards stream_retention stream_created
        stream_desc=$(aws kinesis describe-stream --stream-name "$stream_name" --region "$region" 2> /dev/null || echo "{}")
        stream_arn=$(extract_jq_value "$stream_desc" '.StreamDescription.StreamARN')
        stream_shards=$(extract_jq_value "$stream_desc" '.StreamDescription.Shards | length' '0')
        stream_retention=$(extract_jq_value "$stream_desc" '.StreamDescription.RetentionPeriodHours')
        stream_status=$(extract_jq_value "$stream_desc" '.StreamDescription.StreamStatus')
        stream_created=$(extract_jq_value "$stream_desc" '.StreamDescription.StreamCreationTimestamp')
        buffer+="kinesis,Stream,,$stream_name,${region},$stream_arn,$stream_status,$stream_shards,,$stream_retention,$stream_created,\n"
    done < <(aws kinesis list-streams --region "$region" | jq -r '.StreamNames[]?')

    # Kinesis Data Firehose
    while IFS= read -r ds_name; do
        [[ -z "$ds_name" ]] && continue
        local firehose_data
        firehose_data=$(aws firehose describe-delivery-stream --delivery-stream-name "$ds_name" --region "$region" 2> /dev/null)
        [[ -z "$firehose_data" ]] && continue
        local firehose_name firehose_arn firehose_status firehose_dest firehose_created firehose_last_update
        firehose_name=$(extract_jq_value "$firehose_data" '.DeliveryStreamDescription.DeliveryStreamName')
        firehose_arn=$(extract_jq_value "$firehose_data" '.DeliveryStreamDescription.DeliveryStreamARN')
        firehose_dest=$(extract_jq_value "$firehose_data" '.DeliveryStreamDescription.Destinations[0].DestinationId')
        firehose_created=$(extract_jq_value "$firehose_data" '.DeliveryStreamDescription.CreateTimestamp')
        firehose_status=$(extract_jq_value "$firehose_data" '.DeliveryStreamDescription.DeliveryStreamStatus')
        firehose_last_update=$(extract_jq_value "$firehose_data" '.DeliveryStreamDescription.LastUpdateTimestamp')
        buffer+="kinesis,Firehose,,$firehose_name,${region},$firehose_arn,$firehose_status,,$firehose_dest,,$firehose_created,$firehose_last_update\n"
    done < <(aws firehose list-delivery-streams --region "$region" | jq -r '.DeliveryStreamNames[]?')

    echo "$buffer"
}

#######################################
# collect_kms_inventory: Collect KMS inventory (with categories)
#
# Description:
#   Collects KMS keys and related metadata for a region, including alias and
#   key usage information, and outputs them as CSV rows. Call with
#   "header" to return the header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Emits CSV rows for KMS keys to stdout
#
# Usage:
#   collect_kms_inventory "ap-northeast-1"
#######################################
function collect_kms_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Description,KeyUsage,KeyManager,State"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r key_data; do
        [[ -z "$key_data" ]] && continue
        local key_id key_arn key_description key_usage key_state key_name
        key_id=$(extract_jq_value "$key_data" '.KeyId')

        # Get detailed key information
        local key_details
        key_details=$(aws_retry_exec aws kms describe-key --key-id "$key_id" --region "$region" --output json 2> /dev/null || echo '{"KeyMetadata":{}}')

        key_arn=$(extract_jq_value "$key_details" '.KeyMetadata.Arn')
        key_description=$(normalize_csv_value "$(extract_jq_value "$key_details" '.KeyMetadata.Description')")
        key_usage=$(extract_jq_value "$key_details" '.KeyMetadata.KeyUsage')

        # Skip AWS managed keys for cleaner output (optional)
        local key_manager
        key_manager=$(extract_jq_value "$key_details" '.KeyMetadata.KeyManager')

        # Check for aliases and use alias name if available
        local aliases_json
        aliases_json=$(aws_paginate_items 'Aliases' aws kms list-aliases --key-id "$key_id" --region "$region" 2> /dev/null | jq -s '{Aliases: .}' 2> /dev/null || echo '{}')
        key_aliases=$(extract_jq_value "$aliases_json" '.Aliases[0].AliasName')

        if [[ -n "$key_aliases" && "$key_aliases" != "N/A" ]]; then
            key_name="$key_aliases"
        else
            key_name="$key_id"
        fi
        key_state=$(extract_jq_value "$key_details" '.KeyMetadata.KeyState')

        buffer+="kms,Key,,$key_name,${region},$key_arn,$key_description,$key_usage,$key_manager,$key_state\n"
    done < <(aws kms list-keys --region "$region" | jq -c '.Keys[]')

    echo "$buffer"
}

#######################################
# collect_lambda_inventory: Collect Lambda inventory (with categories)
#
# Description:
#   Collects Lambda functions for the specified region and outputs CSV rows
#   including runtime, memory, timeout, environment variables (masked), and
#   last modified time. Use the special "header" value to return the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Writes CSV formatted Lambda rows to stdout; prints header for "header"
#
# Usage:
#   collect_lambda_inventory "ap-northeast-1"
#######################################
function collect_lambda_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,RoleARN,Type,Runtime,Architecture,MemorySize,Timeout,EnvVars,LastModified"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r func_data; do
        [[ -z "$func_data" ]] && continue
        local func_name func_arn func_runtime func_arch func_role func_memory func_timeout func_last_modified func_env_vars
        func_name=$(extract_jq_value "$func_data" '.FunctionName')
        func_arn=$(extract_jq_value "$func_data" '.FunctionArn')
        func_runtime=$(extract_jq_value "$func_data" '.Runtime')
        func_arch=$(extract_jq_value "$func_data" '.Architectures[0]')
        func_role=$(extract_jq_value "$func_data" '.Role')
        func_memory=$(extract_jq_value "$func_data" '.MemorySize')
        func_timeout=$(extract_jq_value "$func_data" '.Timeout')
        func_last_modified=$(extract_jq_value "$func_data" '.LastModified')

        # 環境変数を1セルにまとめて出力（改行区切り、PRIVATE_KEYはマスク）
        local func_env_vars_raw=""
        if echo "$func_data" | jq -e '.Environment.Variables' > /dev/null 2>&1; then
            while IFS= read -r env_pair; do
                [[ -z "$env_pair" ]] && continue
                local env_key env_value
                env_key=$(echo "$env_pair" | cut -d'=' -f1)
                env_value=$(echo "$env_pair" | cut -d'=' -f2-)
                if [[ "$env_key" =~ PRIVATE_KEY ]]; then
                    env_value="*****"
                fi
                if [[ -n "$func_env_vars_raw" ]]; then
                    func_env_vars_raw+=$'\n'
                fi
                func_env_vars_raw+="${env_key}=${env_value}"
            done < <(echo "$func_data" | jq -r '.Environment.Variables | to_entries[] | "\(.key)=\(.value)"' 2> /dev/null)
        fi
        func_env_vars=$(normalize_csv_value "$func_env_vars_raw")

        buffer+="lambda,Function,,$func_name,${region},$func_arn,$func_role,Function,$func_runtime,$func_arch,$func_memory,$func_timeout,$func_env_vars,$func_last_modified\n"
    done < <(aws_paginate_items 'Functions' aws lambda list-functions --region "$region" 2> /dev/null | jq -c -s 'sort_by(.FunctionName) | .[]')

    echo "$buffer"
}

#######################################
# collect_quicksight_inventory: Collect QuickSight inventory (with categories)
#
# Description:
#   Collects QuickSight data sources and analyses for the given AWS region and
#   outputs CSV rows. Use "header" to return only the CSV header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Emits CSV rows or header to stdout
#
# Usage:
#   collect_quicksight_inventory "ap-northeast-1"
#######################################
function collect_quicksight_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,Type,Status,CreatedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r ds_data; do
        [[ -z "$ds_data" ]] && continue
        local ds_id ds_name ds_type ds_status
        ds_id=$(extract_jq_value "$ds_data" '.DataSourceId')
        ds_name=$(extract_jq_value "$ds_data" '.Name')
        ds_type=$(extract_jq_value "$ds_data" '.Type')
        ds_status=$(extract_jq_value "$ds_data" '.Status')
        buffer+="quicksight,DataSource,,$ds_name,${region},$ds_id,$ds_type,$ds_status,N/A\n"
    done < <(aws quicksight list-data-sources --aws-account-id "$(get_aws_account_id 2> /dev/null || echo 'unknown')" --region "$region" 2> /dev/null | jq -c '.DataSources[]' || true)

    while IFS= read -r analysis_data; do
        [[ -z "$analysis_data" ]] && continue
        local analysis_id analysis_name analysis_status analysis_created
        analysis_id=$(extract_jq_value "$analysis_data" '.AnalysisId')
        analysis_name=$(extract_jq_value "$analysis_data" '.Name')
        analysis_name=$(normalize_csv_value "$analysis_name")
        analysis_status=$(extract_jq_value "$analysis_data" '.Status')
        analysis_created=$(extract_jq_value "$analysis_data" '.CreatedTime')
        buffer+="quicksight,Analysis,,$analysis_name,${region},$analysis_id,$analysis_status,$analysis_created\n"
    done < <(aws quicksight list-analyses --aws-account-id "$(get_aws_account_id 2> /dev/null || echo 'unknown')" --region "$region" 2> /dev/null | jq -c '.AnalysisSummaryList[]' || true)

    echo "$buffer"
}

# collect_rds_inventory: Collect RDS inventory (grouped by Cluster where applicable)
# - DBClusters are shown first with their member DBInstances as children
# - DBInstances show Writer/Reader role when part of a cluster
# - Standalone DBInstances (not in clusters) are listed separately
# - Added columns: EngineLifecycleSupport, IAM_DB_Auth, Kerberos_Auth, KMS_Key, AZ, BackupRetentionPeriod
#######################################
# collect_rds_inventory: Collect RDS inventory (grouped by Cluster)
#
# Description:
#   Collects RDS clusters and instances (including DB clusters with member
#   instances) for the specified region. The function outputs CSV rows for
#   each cluster and DB instance and includes information about engine, role,
#   IAM DB authentication, KMS key, and backup retention. Use "header" to
#   return only the CSV header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows for RDS clusters and instances to stdout
#
# Usage:
#   collect_rds_inventory "ap-northeast-1"
#######################################
function collect_rds_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,Type,Engine,Version,InstanceClass,AllocatedStorage,MultiAZ,DBClusterMembers,EngineLifecycleSupport,IAMDatabaseAuthenticationEnabled,KerberosAuth,KmsKeyId,AvailabilityZone,BackupRetentionPeriod"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # First, collect all clusters and their instances
    declare -A cluster_instances_map

    # Get all clusters first
    while IFS= read -r cluster_data; do
        [[ -z "$cluster_data" ]] && continue
        local cluster_id cluster_engine cluster_db_cluster_members cluster_version cluster_multi_az
        local cluster_extended_support cluster_iam_auth cluster_kerberos_auth cluster_kms_key cluster_az

        cluster_id=$(extract_jq_value "$cluster_data" '.DBClusterIdentifier')
        cluster_engine=$(extract_jq_value "$cluster_data" '.Engine')
        cluster_db_cluster_members=$(extract_jq_value "$cluster_data" '.DBClusterMembers | length')
        cluster_version=$(extract_jq_value "$cluster_data" '.EngineVersion')

        # MultiAZ for cluster
        cluster_multi_az=$(extract_jq_value "$cluster_data" '.MultiAZ')

        # Extended Support (available for certain engines) - use EngineLifecycleSupport
        cluster_extended_support=$(extract_jq_value "$cluster_data" '.EngineLifecycleSupport')

        # IAM Database Authentication
        cluster_iam_auth=$(extract_jq_value "$cluster_data" '.IAMDatabaseAuthenticationEnabled')

        # Kerberos Authentication
        kerberos_config=$(extract_jq_value "$cluster_data" '.DomainMemberships[]? | select(.Status == "joined") | .Domain')
        cluster_kerberos_auth=$(if [[ -n "$kerberos_config" && "$kerberos_config" != "N/A" ]]; then echo "true"; else echo "false"; fi)

        # KMS Key
        cluster_kms_key=$(extract_jq_value "$cluster_data" '.KmsKeyId')

        # Availability Zones (newline-separated, normalized for CSV)
        cluster_az_raw=$(extract_jq_value "$cluster_data" '.AvailabilityZones | join("\n")')
        cluster_az=$(normalize_csv_value "$cluster_az_raw")

        # Backup Retention Period
        cluster_backup_retention=$(extract_jq_value "$cluster_data" '.BackupRetentionPeriod')

        local current_cluster_output=""
        # DBCluster: Core info with empty fields for instance-specific data (InstanceClass, AllocatedStorage)
        current_cluster_output+="rds,DBCluster,,$cluster_id,${region},$cluster_id,DBCluster,$cluster_engine,$cluster_version,,,$cluster_multi_az,$cluster_db_cluster_members,$cluster_extended_support,$cluster_iam_auth,$cluster_kerberos_auth,$cluster_kms_key,$cluster_az,$cluster_backup_retention\n"

        # Get cluster members and their roles
        while IFS= read -r member_data; do
            [[ -z "$member_data" ]] && continue
            local member_id member_role
            member_id=$(extract_jq_value "$member_data" '.DBInstanceIdentifier')
            member_role=$(extract_jq_value "$member_data" '.IsClusterWriter')
            if [[ "$member_role" == "true" ]]; then
                member_role="Writer"
            else
                member_role="Reader"
            fi

            # Store cluster member information
            cluster_instances_map["$member_id"]="$cluster_id|$member_role"
        done < <(echo "$cluster_data" | jq -c '.DBClusterMembers[]?' || echo "")

        # Get detailed instance information for cluster members
        while IFS= read -r instance_data; do
            [[ -z "$instance_data" ]] && continue
            local instance_id instance_cluster_id instance_engine instance_version instance_class instance_allocated_storage instance_multi_az
            local instance_extended_support instance_iam_auth instance_kerberos_auth instance_kms_key instance_az

            instance_id=$(extract_jq_value "$instance_data" '.DBInstanceIdentifier')
            instance_cluster_id=$(extract_jq_value "$instance_data" '.DBClusterIdentifier')

            # Only process instances that belong to this cluster
            if [[ "$instance_cluster_id" == "$cluster_id" ]]; then
                instance_engine=$(extract_jq_value "$instance_data" '.Engine')
                instance_version=$(extract_jq_value "$instance_data" '.EngineVersion')
                instance_class=$(extract_jq_value "$instance_data" '.DBInstanceClass')
                instance_allocated_storage=$(extract_jq_value "$instance_data" '.AllocatedStorage')
                instance_multi_az=$(extract_jq_value "$instance_data" '.MultiAZ')

                # Extended Support (inherit from cluster or check instance) - use EngineLifecycleSupport
                instance_extended_support=$(extract_jq_value "$instance_data" '.EngineLifecycleSupport')
                if [[ -z "$instance_extended_support" || "$instance_extended_support" == "null" ]]; then
                    instance_extended_support="$cluster_extended_support"
                fi

                # IAM Database Authentication (inherit from cluster)
                instance_iam_auth="$cluster_iam_auth"

                # Kerberos Authentication (inherit from cluster)
                instance_kerberos_auth="$cluster_kerberos_auth"

                # KMS Key (inherit from cluster)
                instance_kms_key="$cluster_kms_key"

                # Availability Zone
                instance_az=$(extract_jq_value "$instance_data" '.AvailabilityZone')

                # Backup Retention Period (inherit from cluster)
                instance_backup_retention="$cluster_backup_retention"

                # Get role from cluster members map
                local instance_role=""
                if [[ -n "${cluster_instances_map[$instance_id]:-}" ]]; then
                    instance_role="${cluster_instances_map[$instance_id]#*|}"
                fi

                # DBInstance (cluster member): Core info with empty Members field (cluster-level attribute)
                current_cluster_output+="rds,,DBInstance,$instance_id,${region},$instance_id,DBInstance ($instance_role),$instance_engine,$instance_version,$instance_class,$instance_allocated_storage,$instance_multi_az,,$instance_extended_support,$instance_iam_auth,$instance_kerberos_auth,$instance_kms_key,$instance_az,$instance_backup_retention\n"
            fi
        done < <(aws rds describe-db-instances --region "$region" | jq -c '.DBInstances[]')

        buffer+="$current_cluster_output"
    done < <(aws rds describe-db-clusters --region "$region" | jq -c '.DBClusters[]')

    # Now get standalone DB instances (not part of any cluster)
    while IFS= read -r db_data; do
        [[ -z "$db_data" ]] && continue
        local db_id db_cluster_id db_engine db_version db_class db_allocated_storage db_multi_az
        local db_extended_support db_iam_auth db_kerberos_auth db_kms_key db_az db_backup_retention

        db_id=$(extract_jq_value "$db_data" '.DBInstanceIdentifier')
        db_cluster_id=$(extract_jq_value "$db_data" '.DBClusterIdentifier')

        # Only process standalone instances (not part of a cluster)
        if [[ -z "$db_cluster_id" || "$db_cluster_id" == "null" ]]; then
            db_engine=$(extract_jq_value "$db_data" '.Engine')
            db_version=$(extract_jq_value "$db_data" '.EngineVersion')
            db_class=$(extract_jq_value "$db_data" '.DBInstanceClass')
            db_allocated_storage=$(extract_jq_value "$db_data" '.AllocatedStorage')
            db_multi_az=$(extract_jq_value "$db_data" '.MultiAZ')

            # Extended Support - use EngineLifecycleSupport
            db_extended_support=$(extract_jq_value "$db_data" '.EngineLifecycleSupport')

            # IAM Database Authentication
            db_iam_auth=$(extract_jq_value "$db_data" '.IAMDatabaseAuthenticationEnabled')

            # Kerberos Authentication
            kerberos_config=$(extract_jq_value "$db_data" '.DomainMemberships[]? | select(.Status == "joined") | .Domain')
            db_kerberos_auth=$(if [[ -n "$kerberos_config" && "$kerberos_config" != "N/A" ]]; then echo "true"; else echo "false"; fi)

            # KMS Key
            db_kms_key=$(extract_jq_value "$db_data" '.KmsKeyId')

            # Availability Zone
            db_az=$(extract_jq_value "$db_data" '.AvailabilityZone')

            # Backup Retention Period
            db_backup_retention=$(extract_jq_value "$db_data" '.BackupRetentionPeriod')

            # Standalone DBInstance: Core info with empty Members field (not applicable to standalone instances)
            buffer+="rds,DBInstance,,$db_id,${region},$db_id,DBInstance,$db_engine,$db_version,$db_class,$db_allocated_storage,$db_multi_az,,$db_extended_support,$db_iam_auth,$db_kerberos_auth,$db_kms_key,$db_az,$db_backup_retention\n"
        fi
    done < <(aws rds describe-db-instances --region "$region" | jq -c '.DBInstances[]')

    # Clear the associative array for the current region
    unset cluster_instances_map

    echo "$buffer"
}

#######################################
# collect_redshift_inventory: Collect Redshift inventory (with categories)
#
# Description:
#   Collects Redshift cluster information for the specified region and
#   returns CSV rows with the cluster ID, status, and node type. Use
#   "header" to return the CSV header only.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV formatted Redshift rows to stdout
#
# Usage:
#   collect_redshift_inventory "ap-northeast-1"
#######################################
function collect_redshift_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,RoleARN,NodeType,NumberOfNodes,DBName,Endpoint,Port,MasterUsername,VPCName,ClusterSubnetGroupName,SecurityGroup,Encrypted,KMSKey,PubliclyAccessible,ClusterStatus"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r cluster_data; do
        [[ -z "$cluster_data" ]] && continue
        local cluster_id cluster_status cluster_node_type cluster_number_of_nodes cluster_db_name cluster_endpoint cluster_port cluster_master_username cluster_role_arn cluster_vpc cluster_subnet_group_name cluster_encrypted cluster_kms_key cluster_security_groups cluster_publicly_accessible
        cluster_id=$(extract_jq_value "$cluster_data" '.ClusterIdentifier')
        cluster_status=$(extract_jq_value "$cluster_data" '.ClusterStatus')
        cluster_node_type=$(extract_jq_value "$cluster_data" '.NodeType')
        cluster_number_of_nodes=$(extract_jq_value "$cluster_data" '.NumberOfNodes')
        cluster_db_name=$(extract_jq_value "$cluster_data" '.DBName')
        cluster_endpoint=$(extract_jq_value "$cluster_data" '.Endpoint.Address')
        cluster_port=$(extract_jq_value "$cluster_data" '.Endpoint.Port')
        cluster_master_username=$(extract_jq_value "$cluster_data" '.MasterUsername')
        cluster_role_arn=$(extract_jq_value "$cluster_data" '.IamRoles[0].IamRoleArn')
        cluster_vpc=$(extract_jq_value "$cluster_data" '.VpcId')
        cluster_vpc=$(get_vpc_name "$cluster_vpc" "$region" || echo "$cluster_vpc")
        cluster_subnet_group_name=$(extract_jq_value "$cluster_data" '.ClusterSubnetGroupName')
        cluster_encrypted=$(extract_jq_value "$cluster_data" '.Encrypted')
        cluster_kms_key=$(extract_jq_value "$cluster_data" '.KmsKeyId')
        cluster_kms_key=$(get_kms_name "$cluster_kms_key" "$region" || echo "$cluster_kms_key")
        cluster_security_groups=$(extract_jq_array "$cluster_data" '.VpcSecurityGroups[].VpcSecurityGroupId')
        cluster_publicly_accessible=$(extract_jq_value "$cluster_data" '.PubliclyAccessible')
        # Convert security group IDs to names
        if [[ "$cluster_security_groups" != "N/A" && "$cluster_security_groups" != "\"\"" ]]; then
            local sg_names=""
            # Remove quotes and split by comma
            local sg_ids
            sg_ids=${cluster_security_groups//\"/}
            IFS=',' read -ra sg_id_array <<< "$sg_ids"
            for sg_id in "${sg_id_array[@]}"; do
                sg_id=$(echo "$sg_id" | xargs) # Trim whitespace
                if [[ -n "$sg_id" ]]; then
                    sg_name=$(get_security_group_name "$sg_id" "$region" || echo "$sg_id")
                    if [[ -n "$sg_names" ]]; then
                        sg_names="$sg_names,$sg_name"
                    else
                        sg_names="$sg_name"
                    fi
                fi
            done
            cluster_security_groups=$(normalize_csv_value "$sg_names")
        fi
        buffer+="redshift,Cluster,,$cluster_id,${region},$cluster_role_arn,$cluster_node_type,$cluster_number_of_nodes,$cluster_db_name,$cluster_endpoint,$cluster_port,$cluster_master_username,$cluster_vpc,$cluster_subnet_group_name,$cluster_security_groups,$cluster_encrypted,$cluster_kms_key,$cluster_publicly_accessible,$cluster_status\n"
    done < <(aws redshift describe-clusters --region "$region" | jq -c '.Clusters[]')

    echo "$buffer"
}

# collect_route53_inventory: Collect Route53 inventory (grouped by HostedZone)
# Note: TXT records may contain multiple lines (e.g., SPF, DKIM records)
#######################################
#
# Description:
#   Collects Route53 HostedZones and their ResourceRecordSets. For global
#   services this function runs only in us-east-1; use the option
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows describing hosted zones and records to stdout
#
# Usage:
#   collect_route53_inventory "us-east-1"
#######################################
function collect_route53_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,Type,Comment,TTL,RecordType,Value,RecordCount"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    # Route53 is a global service, only process from us-east-1
    if [[ "$region" != "us-east-1" ]]; then
        echo ""
        return 0
    fi

    local buffer=""

    while IFS= read -r zone_data; do
        [[ -z "$zone_data" ]] && continue
        local zone_id zone_name zone_type zone_records zone_comment
        zone_id=$(extract_jq_value "$zone_data" '.Id')
        # Extract zone ID from the full path (e.g., /hostedzone/Z123456789 -> Z123456789)
        zone_id=$(basename "$zone_id")
        zone_name=$(extract_jq_value "$zone_data" '.Name')
        zone_type=$(extract_jq_value "$zone_data" '.Config.PrivateZone')
        if [[ "$zone_type" == "true" ]]; then
            zone_type="Private"
        else
            zone_type="Public"
        fi
        zone_records=$(extract_jq_value "$zone_data" '.ResourceRecordSetCount')
        zone_comment=$(extract_jq_value "$zone_data" '.Config.Comment')
        zone_comment=$(normalize_csv_value "$zone_comment")

        # Add current HostedZone data to output
        local current_zone_output=""
        # HostedZone: Type, Comment, Record_Count (empty fields for record-specific data)
        current_zone_output+="route53,HostedZone,,$zone_name,Global,$zone_id,$zone_type,$zone_comment,,,,$zone_records\n"

        # Get Resource Record Sets for this Hosted Zone
        while IFS= read -r record_data; do
            [[ -z "$record_data" ]] && continue
            local record_name record_type record_ttl record_values
            record_name=$(extract_jq_value "$record_data" '.Name')
            record_type=$(extract_jq_value "$record_data" '.Type')
            record_ttl=$(extract_jq_value "$record_data" '.TTL')

            # Handle alias records vs regular records
            local alias_target
            alias_target=$(extract_jq_value "$record_data" '.AliasTarget.DNSName')
            if [[ -n "$alias_target" && "$alias_target" != "null" ]]; then
                record_values=$(normalize_csv_value "$alias_target")
                record_ttl="Alias"
            else
                # Get regular record values
                local raw_values
                raw_values=$(extract_jq_value "$record_data" '.ResourceRecords[]?.Value')
                record_values=$(normalize_csv_value "$raw_values")
            fi

            # Skip default NS and SOA records for the zone itself to reduce noise
            # These are automatically created records and typically not of interest for inventory
            # Note: Custom A, CNAME, MX, etc. records including those with zone name will still be shown
            if [[ "$record_name" == "$zone_name" && ("$record_type" == "NS" || "$record_type" == "SOA") ]]; then
                continue
            fi

            # Record: TTL, RecordType, Value (empty fields for hostedzone-specific data)
            current_zone_output+="route53,,Record,$record_name,Global,,,,$record_ttl,$record_type,$record_values,\n"
        done < <(aws route53 list-resource-record-sets --hosted-zone-id "$zone_id" 2> /dev/null | jq -c '.ResourceRecordSets[]?' || echo "")

        # Add this zone's data to overall output
        buffer+="$current_zone_output"

    done < <(aws route53 list-hosted-zones | jq -c '.HostedZones[]')

    echo "$buffer"
}

# collect_s3_inventory: Collect S3 inventory (with categories)
#
# Description:
#   Enumerates S3 buckets and collects bucket-level metadata such as
#   encryption, versioning, public access block settings, logging and
#   lifecycle configuration. For global service S3, this function runs only
#   in us-east-1. Use "header" to output only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Prints CSV rows for each bucket to stdout; prints header for "header"
#
# Usage:
#   collect_s3_inventory "us-east-1"
# Note: Lifecycle rule names may contain multiple entries separated by semicolons
#######################################
function collect_s3_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Encryption,Versioning,PABBlockPublicACLs,PABIgnorePublicACLs,PABBlockPublicPolicy,PABRestrictPublicBuckets,AccessLogARN,LifecycleRules,CreationDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    # S3 is a global service, only process from us-east-1
    if [[ "$region" != "us-east-1" ]]; then
        echo ""
        return 0
    fi

    local buffer=""

    while IFS= read -r bucket_data; do
        [[ -z "$bucket_data" ]] && continue
        local bucket_name bucket_creation_date bucket_region bucket_encryption bucket_arn
        local bucket_versioning bucket_pab_block_public_acls bucket_pab_ignore_public_acls bucket_pab_block_public_policy bucket_pab_restrict_public_buckets bucket_lifecycle bucket_access_log_arn

        bucket_name=$(extract_jq_value "$bucket_data" '.Name')
        bucket_creation_date=$(extract_jq_value "$bucket_data" '.CreationDate')
        bucket_region=$(extract_jq_value "$(aws s3api get-bucket-location --bucket "$bucket_name" 2> /dev/null || echo '{}')" '.LocationConstraint' 'us-east-1')

        # Construct bucket ARN
        bucket_arn="arn:aws:s3:::${bucket_name}"

        # Get encryption
        bucket_encryption=$(extract_jq_value "$(aws s3api get-bucket-encryption --bucket "$bucket_name" 2> /dev/null || echo '{}')" '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' 'None')

        # Get versioning
        bucket_versioning=$(extract_jq_value "$(aws s3api get-bucket-versioning --bucket "$bucket_name" 2> /dev/null || echo '{}')" '.Status' 'Disabled')

        # Get Public Access Block settings
        local pab_data
        pab_data=$(aws s3api get-public-access-block --bucket "$bucket_name" 2> /dev/null | jq '.PublicAccessBlockConfiguration' 2> /dev/null || echo "null")

        # Parse each Public Access Block setting with defaults
        bucket_pab_block_public_acls=$(extract_jq_value "$pab_data" '.BlockPublicAcls' 'false')
        bucket_pab_ignore_public_acls=$(extract_jq_value "$pab_data" '.IgnorePublicAcls' 'false')
        bucket_pab_block_public_policy=$(extract_jq_value "$pab_data" '.BlockPublicPolicy' 'false')
        bucket_pab_restrict_public_buckets=$(extract_jq_value "$pab_data" '.RestrictPublicBuckets' 'false')

        # Get access logging configuration
        local access_log_data bucket_access_log_bucket
        access_log_data=$(aws s3api get-bucket-logging --bucket "$bucket_name" 2> /dev/null | jq '.LoggingEnabled' 2> /dev/null || echo "null")
        if [[ "$access_log_data" != "null" && -n "$access_log_data" ]]; then
            bucket_access_log_bucket=$(extract_jq_value "$access_log_data" '.TargetBucket')
            if [[ -n "$bucket_access_log_bucket" && "$bucket_access_log_bucket" != "N/A" ]]; then
                bucket_access_log_arn="arn:aws:s3:::${bucket_access_log_bucket}"
            else
                bucket_access_log_arn="N/A"
            fi
        else
            bucket_access_log_arn="N/A"
        fi
        bucket_access_log_arn=$(normalize_csv_value "$bucket_access_log_arn")

        # Get lifecycle configuration with actual rule names
        local lifecycle_config
        lifecycle_config=$(aws s3api get-bucket-lifecycle-configuration --bucket "$bucket_name" 2> /dev/null | jq '.Rules' 2> /dev/null || echo "null")
        if [[ "$lifecycle_config" != "null" && "$lifecycle_config" != "[]" ]]; then
            bucket_lifecycle=$(extract_jq_value "$lifecycle_config" '.[]')
        else
            bucket_lifecycle="N/A"
        fi
        bucket_lifecycle=$(normalize_csv_value "$bucket_lifecycle")

        buffer+="s3,Bucket,,${bucket_name},${bucket_region},$bucket_arn,$bucket_encryption,$bucket_versioning,$bucket_pab_block_public_acls,$bucket_pab_ignore_public_acls,$bucket_pab_block_public_policy,$bucket_pab_restrict_public_buckets,$bucket_access_log_arn,$bucket_lifecycle,$bucket_creation_date\n"
    done < <(aws s3api list-buckets | jq -c '.Buckets[]')

    echo "$buffer"
}

# collect_secretsmanager_inventory: Collect Secrets Manager inventory (with categories)
#
# Description:
#   Lists Secrets Manager secrets in the specified region and outputs CSV
#   rows including name, ARN, description and last-modified time. Use
#   "header" to return only the header line.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Writes CSV formatted secrets to stdout
#
# Usage:
#   collect_secretsmanager_inventory "ap-northeast-1"
#######################################
function collect_secretsmanager_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Description,RotationEnabled,RotationLambdaARN,LastAccessedDate,LastRotatedDate,LastChangedDate"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r secret_data; do
        [[ -z "$secret_data" ]] && continue
        local secret_name secret_arn secret_description secret_rotation_enabled secret_rotation_lambda_arn secret_last_accessed_date secret_last_rotated_date secret_last_changed_date
        secret_name=$(extract_jq_value "$secret_data" '.Name')
        secret_arn=$(extract_jq_value "$secret_data" '.ARN')
        secret_description=$(normalize_csv_value "$(extract_jq_value "$secret_data" '.Description')")
        secret_rotation_enabled=$(extract_jq_value "$secret_data" '.RotationEnabled')
        secret_rotation_lambda_arn=$(extract_jq_value "$secret_data" '.RotationLambdaARN')
        secret_last_accessed_date=$(extract_jq_value "$secret_data" '.LastAccessedDate')
        secret_last_rotated_date=$(extract_jq_value "$secret_data" '.LastRotatedDate')
        secret_last_changed_date=$(extract_jq_value "$secret_data" '.LastChangedDate')
        buffer+="secretsmanager,Secret,,$secret_name,${region},$secret_arn,$secret_description,$secret_rotation_enabled,$secret_rotation_lambda_arn,$secret_last_accessed_date,$secret_last_rotated_date,$secret_last_changed_date\n"
    done < <(aws secretsmanager list-secrets --region "$region" | jq -c '.SecretList[]')

    echo "$buffer"
}

#######################################
# collect_sns_inventory: Collect SNS inventory (with categories)
#
# Description:
#   Enumerates SNS topics in the region and outputs topic A RN, display name,
#   and subscription count as CSV rows. Use "header" to print only the CSV
#   header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Prints CSV rows for SNS topics to stdout
#
# Usage:
#   collect_sns_inventory "ap-northeast-1"
#######################################
function collect_sns_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,DisplayName,SubscriptionCount"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r topic_data; do
        [[ -z "$topic_data" ]] && continue
        local topic_arn topic_name topic_display_name topic_subscriptions
        topic_arn=$(extract_jq_value "$topic_data" '.TopicArn')
        # Extract topic name from ARN (last part after the last colon)
        topic_name="${topic_arn##*:}"
        topic_display_name=$(extract_jq_value "$(aws sns get-topic-attributes --topic-arn "$topic_arn" --region "$region" 2> /dev/null || echo '{}')" '.Attributes.DisplayName')
        topic_subscriptions=$(extract_jq_value "$(aws sns list-subscriptions-by-topic --topic-arn "$topic_arn" --region "$region" 2> /dev/null || echo '{}')" '.Subscriptions | length' '0')
        buffer+="sns,Topic,,${topic_name},${region},${topic_arn},${topic_display_name},${topic_subscriptions}\n"
    done < <(aws sns list-topics --region "$region" | jq -c '.Topics[]')

    echo "$buffer"
}

#######################################
# collect_sqs_inventory: Collect SQS inventory (with categories)
#
# Description:
#   Scans SQS queues in a given region and returns details such as type,
#   visibility timeout, DLQ target ARN, message retention period and timestamps
#   formatted as CSV rows. Use "header" to output the CSV header only.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Emits CSV rows for each SQS queue to stdout
#
# Usage:
#   collect_sqs_inventory "ap-northeast-1"
#######################################
function collect_sqs_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,URL,Type,VisibilityTimeout,DelaySeconds,MessageRetentionPeriod,MaxReceiveCount,DLQTargetARN,CreatedTimestamp,LastModifiedTimestamp"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r queue_url; do
        [[ -z "$queue_url" ]] && continue
        local queue_name queue_type visibility_timeout delay_seconds max_receive_count dlq_target_arn message_retention_period created_timestamp last_modified_timestamp
        queue_name=$(basename "$queue_url")

        # Get queue attributes
        local queue_attrs
        queue_attrs=$(aws sqs get-queue-attributes --queue-url "$queue_url" --attribute-names All --region "$region" 2> /dev/null || echo '{"Attributes":{}}')

        queue_type=$(extract_jq_value "$queue_attrs" '.Attributes.FifoQueue' 'false')
        if [[ "$queue_type" == "true" ]]; then
            queue_type="FIFO"
        else
            queue_type="Standard"
        fi

        visibility_timeout=$(extract_jq_value "$queue_attrs" '.Attributes.VisibilityTimeout')
        delay_seconds=$(extract_jq_value "$queue_attrs" '.Attributes.DelaySeconds')
        message_retention_period=$(extract_jq_value "$queue_attrs" '.Attributes.MessageRetentionPeriod')
        created_timestamp=$(extract_jq_value "$queue_attrs" '.Attributes.CreatedTimestamp')
        last_modified_timestamp=$(extract_jq_value "$queue_attrs" '.Attributes.LastModifiedTimestamp')

        # Dead Letter Queue related attributes
        local redrive_policy
        redrive_policy=$(extract_jq_value "$queue_attrs" '.Attributes.RedrivePolicy')
        if [[ -n "$redrive_policy" && "$redrive_policy" != "N/A" ]]; then
            max_receive_count=$(extract_jq_value "$redrive_policy" '.maxReceiveCount')
            dlq_target_arn=$(extract_jq_value "$redrive_policy" '.deadLetterTargetArn')
        else
            max_receive_count=""
            dlq_target_arn=""
        fi
        max_receive_count=$(normalize_csv_value "$max_receive_count")
        dlq_target_arn=$(normalize_csv_value "$dlq_target_arn")

        # Convert timestamps to readable format
        if [[ -n "$created_timestamp" && "$created_timestamp" =~ ^[0-9]+$ ]]; then
            created_timestamp=$(date -d "@$created_timestamp" "+%Y-%m-%d %H:%M:%S" 2> /dev/null || echo "$created_timestamp")
        fi
        if [[ -n "$last_modified_timestamp" && "$last_modified_timestamp" =~ ^[0-9]+$ ]]; then
            last_modified_timestamp=$(date -d "@$last_modified_timestamp" "+%Y-%m-%d %H:%M:%S" 2> /dev/null || echo "$last_modified_timestamp")
        fi
        created_timestamp=$(normalize_csv_value "$created_timestamp")
        last_modified_timestamp=$(normalize_csv_value "$last_modified_timestamp")

        buffer+="sqs,Queue,,$queue_name,${region},$queue_url,$queue_type,$visibility_timeout,$delay_seconds,$message_retention_period,$max_receive_count,$dlq_target_arn,$created_timestamp,$last_modified_timestamp\n"
    done < <(aws sqs list-queues --region "$region" | jq -r '.QueueUrls[]?')

    echo "$buffer"
}

#######################################
# collect_transferfamily_inventory: Collect Transfer Family inventory (with categories)
#
# Description:
#   Collects AWS Transfer Family servers and state in the specified region
#   and outputs CSV rows containing server id, protocol and state. Use
#   "header" to request only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Writes CSV rows to stdout describing Transfer Family servers
#
# Usage:
#   collect_transferfamily_inventory "ap-northeast-1"
#######################################
function collect_transferfamily_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ServerID,Protocol,State"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    while IFS= read -r server_data; do
        [[ -z "$server_data" ]] && continue
        local server_id server_state server_protocol
        server_id=$(extract_jq_value "$server_data" '.ServerId')
        server_state=$(extract_jq_value "$server_data" '.State')
        server_protocol=$(extract_jq_value "$server_data" '.Protocols[0]')
        buffer+="transferfamily,Server,,${server_id},${region},$server_id,$server_protocol,$server_state\n"
    done < <(aws transfer list-servers --region "$region" | jq -c '.Servers[]')

    echo "$buffer"
}

#######################################
# collect_vpc_inventory: Collect VPC inventory (grouped by VPC)
#
# Description:
#   Collects VPCs and related sub-resources (subnets, route tables, NAT
#   gateways, internet gateways, network ACLs, security groups, endpoints)
#   for the specified region and returns a CSV listing grouped by VPC.
#   Use "header" to return only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Outputs CSV rows describing VPC and sub-resources to stdout
#
# Usage:
#   collect_vpc_inventory "ap-northeast-1"
#######################################
function collect_vpc_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ID,Description,CIDR,PublicIP,Settings,State"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Collect all VPC data in a single call with tags
    local vpc_json
    vpc_json=$(aws ec2 describe-vpcs --region "$region" 2> /dev/null) || return 0

    if [[ $(extract_jq_value "$vpc_json" '.Vpcs | length' '0') -eq 0 ]]; then
        echo ""
        return 0
    fi

    # Process each VPC and collect all its subresources
    while IFS= read -r vpc_id; do
        [[ -z "$vpc_id" || "$vpc_id" == "null" ]] && continue

        # Get VPC details
        local vpc_data
        vpc_data=$(echo "$vpc_json" | jq -c --arg vpc_id "$vpc_id" '.Vpcs[] | select(.VpcId == $vpc_id)')
        local cidr vpc_name vpc_state
        cidr=$(extract_jq_value "$vpc_data" '.CidrBlock')
        vpc_state=$(extract_jq_value "$vpc_data" '.State')

        # Get VPC name from tags
        vpc_name=$(normalize_csv_value "$(extract_jq_value "$vpc_data" '.Tags[]? | select(.Key == "Name") | .Value')")

        # Start with main VPC entry
        local current_vpc_output=""
        current_vpc_output+="vpc,VPC,,${vpc_name},${region},$vpc_id,,$cidr,,,$vpc_state\n"

        # Get route tables for this VPC to help classify subnets
        local rt_json
        rt_json=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true

        # Collect and classify subnets for this VPC
        local subnet_json
        subnet_json=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true

        local public_subnets="" private_subnets=""
        while IFS= read -r subnet_data; do
            [[ -z "$subnet_data" ]] && continue
            local subnet_id subnet_cidr subnet_name
            subnet_id=$(extract_jq_value "$subnet_data" '.SubnetId')
            subnet_cidr=$(extract_jq_value "$subnet_data" '.CidrBlock')
            subnet_name=$(normalize_csv_value "$(extract_jq_value "$subnet_data" '.Tags[]? | select(.Key == "Name") | .Value')")

            # Check if subnet is public by looking at associated route table
            local is_public=false
            local subnet_rt_associations
            subnet_rt_associations=$(echo "$rt_json" | jq -r --arg subnet_id "$subnet_id" '.RouteTables[] | select(.Associations[]?.SubnetId == $subnet_id) | .RouteTableId // empty')

            # If no explicit association, check main route table
            if [[ -z "$subnet_rt_associations" ]]; then
                subnet_rt_associations=$(echo "$rt_json" | jq -r '.RouteTables[] | select(.Associations[]?.Main == true) | .RouteTableId // empty')
            fi

            # Check if any associated route table has route to internet gateway
            while IFS= read -r rt_id; do
                [[ -z "$rt_id" ]] && continue
                local has_igw_route
                has_igw_route=$(echo "$rt_json" | jq -r --arg rt_id "$rt_id" '.RouteTables[] | select(.RouteTableId == $rt_id) | .Routes[] | select(.GatewayId? // empty | startswith("igw-")) | .GatewayId')
                if [[ -n "$has_igw_route" ]]; then
                    is_public=true
                    break
                fi
            done <<< "$subnet_rt_associations"

            if [[ "$is_public" == "true" ]]; then
                public_subnets+="vpc,,PublicSubnet,${subnet_name},${region},$subnet_id,,$subnet_cidr,,,\n"
            else
                private_subnets+="vpc,,PrivateSubnet,${subnet_name},${region},$subnet_id,,$subnet_cidr,,,\n"
            fi
        done < <(echo "$subnet_json" | jq -c '.Subnets[]?')

        # Collect route tables for this VPC
        local route_tables=""
        while IFS= read -r rt_data; do
            [[ -z "$rt_data" ]] && continue
            local rt_id rt_name
            rt_id=$(extract_jq_value "$rt_data" '.RouteTableId')
            rt_name=$(normalize_csv_value "$(extract_jq_value "$rt_data" '.Tags[]? | select(.Key == "Name") | .Value')")
            route_tables+="vpc,,RouteTable,${rt_name},${region},$rt_id,,,,\n"
        done < <(echo "$rt_json" | jq -c '.RouteTables[]?')

        # Collect internet gateways for this VPC
        local internet_gateways=""
        local igw_json
        igw_json=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true

        while IFS= read -r igw_data; do
            [[ -z "$igw_data" ]] && continue
            local igw_id igw_name
            igw_id=$(extract_jq_value "$igw_data" '.InternetGatewayId')
            igw_name=$(normalize_csv_value "$(extract_jq_value "$igw_data" '.Tags[]? | select(.Key == "Name") | .Value')")
            internet_gateways+="vpc,,InternetGateway,${igw_name},${region},$igw_id,,,,,attached\n"
        done < <(echo "$igw_json" | jq -c '.InternetGateways[]?')

        # Collect NAT gateways for this VPC
        local nat_gateways=""
        local nat_json
        nat_json=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true

        while IFS= read -r nat_data; do
            [[ -z "$nat_data" ]] && continue
            local nat_id nat_name nat_state nat_public_ip
            nat_id=$(extract_jq_value "$nat_data" '.NatGatewayId')
            nat_state=$(extract_jq_value "$nat_data" '.State')
            nat_name=$(normalize_csv_value "$(extract_jq_value "$nat_data" '.Tags[]? | select(.Key == "Name") | .Value')")
            # Get public IP address (Elastic IP) from NatGatewayAddresses
            nat_public_ip=$(extract_jq_value "$nat_data" '.NatGatewayAddresses[0].PublicIp')
            nat_gateways+="vpc,,NATGateway,${nat_name},${region},$nat_id,,,$nat_public_ip,,$nat_state\n"
        done < <(echo "$nat_json" | jq -c '.NatGateways[]?')

        # Collect Network ACLs for this VPC
        local network_acls=""
        local nacl_json
        nacl_json=$(aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true
        while IFS= read -r nacl_data; do
            [[ -z "$nacl_data" ]] && continue
            local nacl_id nacl_name nacl_desc nacl_entries nacl_associations
            nacl_id=$(extract_jq_value "$nacl_data" '.NetworkAclId')
            nacl_name=$(normalize_csv_value "$(extract_jq_value "$nacl_data" '.Tags[]? | select(.Key == "Name") | .Value')")
            nacl_desc=""
            # Summarize entries (rules) with line breaks
            nacl_entries=$(echo "$nacl_data" | jq -r '.Entries[]? | "Rule#: " + (.RuleNumber|tostring) + " | Protocol: " + (.Protocol // "-") + " | RuleAction: " + (.RuleAction // "-") + " | Egress: " + (.Egress|tostring) + " | CIDR: " + (.CidrBlock // "-") + " | PortRange: " + (if .PortRange? then (.PortRange.From|tostring) + "-" + (.PortRange.To|tostring) else "-" end)' | paste -sd "\n" -)
            nacl_entries=$(normalize_csv_value "$nacl_entries")
            # Summarize associations (subnets)
            nacl_associations=$(echo "$nacl_data" | jq -r '.Associations[]? | .SubnetId' | paste -sd ";" -)
            nacl_associations=$(normalize_csv_value "$nacl_associations")
            network_acls+="vpc,,NetworkACL,${nacl_name},${region},${nacl_id},${nacl_desc},,,${nacl_entries},\n"
        done < <(echo "$nacl_json" | jq -c '.NetworkAcls[]?')

        # Collect security groups for this VPC
        local security_groups=""
        local sg_json
        sg_json=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true
        while IFS= read -r sg_data; do
            [[ -z "$sg_data" ]] && continue
            local sg_id sg_name sg_desc sg_inbound sg_outbound
            sg_id=$(extract_jq_value "$sg_data" '.GroupId')
            sg_name=$(normalize_csv_value "$(extract_jq_value "$sg_data" '.GroupName')")
            sg_desc=$(normalize_csv_value "$(extract_jq_value "$sg_data" '.Description')")
            # Inbound rules summary (改行区切り、説明付き)
            sg_inbound=$(echo "$sg_data" | jq -r '.IpPermissions[]? | "Protocol: " + (.IpProtocol // "-") + " | FromPort: " + ((.FromPort // "-") | tostring) + " | ToPort: " + ((.ToPort // "-") | tostring) + " | CIDR: " + (.IpRanges[]?.CidrIp // "-")' | paste -sd "\n" -)
            # Outbound rules summary (改行区切り、説明付き)
            sg_outbound=$(echo "$sg_data" | jq -r '.IpPermissionsEgress[]? | "Protocol: " + (.IpProtocol // "-") + " | FromPort: " + ((.FromPort // "-") | tostring) + " | ToPort: " + ((.ToPort // "-") | tostring) + " | CIDR: " + (.IpRanges[]?.CidrIp // "-")' | paste -sd "\n" -)
            sg_settings=$(normalize_csv_value "Inbound:\n$sg_inbound\nOutbound:\n$sg_outbound")
            # Output as SubSubCategory for VPC
            security_groups+="vpc,,SecurityGroup,${sg_name},${region},${sg_id},${sg_desc},,,${sg_settings},\n"
        done < <(echo "$sg_json" | jq -c '.SecurityGroups[]?')

        # Collect VPC endpoints for this VPC
        local endpoints=""
        local endpoint_json
        endpoint_json=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpc_id" --region "$region" 2> /dev/null) || true
        while IFS= read -r ep_data; do
            [[ -z "$ep_data" ]] && continue
            local ep_id ep_name ep_type ep_state ep_service ep_subnets ep_route_tables ep_security_groups ep_desc
            ep_id=$(extract_jq_value "$ep_data" '.VpcEndpointId')
            ep_type=$(extract_jq_value "$ep_data" '.VpcEndpointType')
            ep_state=$(extract_jq_value "$ep_data" '.State')
            ep_service=$(extract_jq_value "$ep_data" '.ServiceName')
            ep_subnets=$(extract_jq_value "$ep_data" '.SubnetIds | join("\n")')
            ep_route_tables=$(extract_jq_value "$ep_data" '.RouteTableIds | join("\n")')
            ep_security_groups=$(extract_jq_value "$ep_data" '.Groups[]?.GroupId')
            ep_security_groups=$(normalize_csv_value "$ep_security_groups")
            ep_name=$(normalize_csv_value "$(extract_jq_value "$ep_data" '.Tags[]? | select(.Key == "Name") | .Value')")
            ep_desc="Type: $ep_type\nService: $ep_service\nSubnet: $ep_subnets\nRouteTable: $ep_route_tables\nSecurityGroup: $ep_security_groups"
            ep_desc=$(normalize_csv_value "$ep_desc")
            endpoints+="vpc,,Endpoint,${ep_name},${region},${ep_id},,,,${ep_desc},$ep_state\n"
        done < <(echo "$endpoint_json" | jq -c '.VpcEndpoints[]?')

        # Group VPC subresources before adding to buffer
        current_vpc_output+="$public_subnets"
        current_vpc_output+="$private_subnets"
        current_vpc_output+="$route_tables"
        current_vpc_output+="$internet_gateways"
        current_vpc_output+="$nat_gateways"
        current_vpc_output+="$network_acls"
        current_vpc_output+="$security_groups"
        current_vpc_output+="$endpoints"

        # Add this VPC's data to overall output
        buffer+="$current_vpc_output"

    done < <(echo "$vpc_json" | jq -r '.Vpcs[]?.VpcId // empty')

    echo "$buffer"
}

# collect_waf_inventory: Collect WAF inventory (with categories)
#
# Description:
#   Collects WAF Web ACLs (Regional and CloudFront) and their rules,
#   associated resources and logging configuration. Use "header" to return
#   only the CSV header.
#
# Arguments:
#   $1 - AWS region or the string "header" to request CSV header
#
# Global Variables:
#   None
#
# Returns:
#   Emits CSV rows that describe each WAF Web ACL and its settings
#
# Usage:
#   collect_waf_inventory "ap-northeast-1"
#######################################
function collect_waf_inventory {
    local region=$1
    local header="Category,SubCategory,SubSubCcategory,Name,Region,ARN,Description,Scope,Rules,AssociatedResources,Logging"

    # Return header if requested
    if [[ "$region" == "header" ]]; then
        echo "$header"
        return 0
    fi

    local buffer=""

    # Regional WAF
    while IFS= read -r waf_data; do
        [[ -z "$waf_data" ]] && continue
        local waf_name waf_id waf_description waf_scope waf_arn
        local waf_detail waf_rules_raw waf_associated_raw waf_logging_raw

        waf_name=$(extract_jq_value "$waf_data" '.Name')
        waf_id=$(extract_jq_value "$waf_data" '.Id')
        waf_description=$(normalize_csv_value "$(extract_jq_value "$waf_data" '.Description')")
        waf_scope="REGIONAL"
        waf_arn=$(extract_jq_value "$waf_data" '.ARN')

        # Get full WebACL configuration to extract Rules
        waf_detail=$(aws wafv2 get-web-acl --name "$waf_name" --scope REGIONAL --id "$waf_id" --region "$region" 2> /dev/null || echo '{}')
        waf_rules_raw=$(extract_jq_value "$waf_detail" '.WebACL.Rules | map(.Name) | join("\n")' '')

        # Associated resources: query likely resource types
        waf_associated_raw=""
        local resource_types=(APPLICATION_LOAD_BALANCER API_GATEWAY)
        for rt in "${resource_types[@]}"; do
            local tmp
            tmp=$(aws wafv2 list-resources-for-web-acl --web-acl-arn "$waf_arn" --resource-type "$rt" --region "$region" 2> /dev/null | jq -r '.ResourceArns[]?' 2> /dev/null || true)
            [[ -n "$tmp" ]] && waf_associated_raw+="${waf_associated_raw:+$'\n'}$tmp"
        done

        # Logging configuration
        waf_logging_raw=$(aws wafv2 get-logging-configuration --resource-arn "$waf_arn" --region "$region" 2> /dev/null | jq -r '.LoggingConfiguration.LogDestinationConfigs[]? // empty' 2> /dev/null || true)

        # Output CSV row
        buffer+="waf,WebACL,,$waf_name,${region},$waf_arn,$waf_description,$waf_scope,$(normalize_csv_value "$waf_rules_raw"),$(normalize_csv_value "$waf_associated_raw"),$(normalize_csv_value "$waf_logging_raw")\n"
    done < <(aws wafv2 list-web-acls --scope REGIONAL --region "$region" | jq -c '.WebACLs[]')

    # CloudFront WAF (only from us-east-1)
    if [[ "$region" == "us-east-1" ]]; then
        while IFS= read -r waf_data; do
            [[ -z "$waf_data" ]] && continue
            local waf_name waf_id waf_description waf_scope waf_arn
            local waf_detail waf_rules_raw waf_associated_raw waf_logging_raw

            waf_name=$(extract_jq_value "$waf_data" '.Name')
            waf_id=$(extract_jq_value "$waf_data" '.Id')
            waf_description=$(normalize_csv_value "$(extract_jq_value "$waf_data" '.Description')")
            waf_scope="CLOUDFRONT"
            waf_arn=$(extract_jq_value "$waf_data" '.ARN')

            # Get full WebACL configuration to extract Rules
            waf_detail=$(aws wafv2 get-web-acl --name "$waf_name" --scope CLOUDFRONT --id "$waf_id" --region us-east-1 2> /dev/null || echo '{}')
            waf_rules_raw=$(extract_jq_value "$waf_detail" '.WebACL.Rules | map(.Name) | join("\n")' '')

            # Associated CloudFront distributions
            waf_associated_raw=$(aws_paginate_items 'DistributionList.Items' aws cloudfront list-distributions-by-web-acl-id --web-acl-id "$waf_arn" --region us-east-1 2> /dev/null | jq -r '.ARN' 2> /dev/null || true)

            # Logging configuration
            waf_logging_raw=$(aws wafv2 get-logging-configuration --resource-arn "$waf_arn" --region us-east-1 2> /dev/null | jq -r '.LoggingConfiguration.LogDestinationConfigs[]? // empty' 2> /dev/null || true)

            # Output CSV row
            buffer+="waf,WebACL,,$waf_name,Global,$waf_arn,$waf_description,$waf_scope,$(normalize_csv_value "$waf_rules_raw"),$(normalize_csv_value "$waf_associated_raw"),$(normalize_csv_value "$waf_logging_raw")\n"
        done < <(aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1 | jq -c '.WebACLs[]')
    fi

    echo "$buffer"
}

#######################################
# generate_html_index: Generate HTML index and manifest for CSV outputs
#
# Description:
#   Generate a JSON manifest (files.json) and a single-page index.html
#   that reads CSV files under ${OUTPUT_DIR}/resources and renders them.
#
# Arguments:
#   None
#
# Global Variables:
#   OUTPUT_DIR, INDEX_TITLE, INDEX_DESCRIPTION
#
# Returns:
#   None (writes files to OUTPUT_DIR)
#
# Usage:
#   generate_html_index
#
#######################################
function generate_html_index {
    # Description: Generate a JSON manifest (files.json) and a single-page index.html
    #              that reads CSV files under ${OUTPUT_DIR}/resources and renders them.
    # Uses globals: OUTPUT_DIR, INDEX_TITLE, INDEX_DESCRIPTION
    log "INFO" "Generating HTML index in ${OUTPUT_DIR}"
    local manifest_file index_file
    manifest_file="${OUTPUT_DIR}/files.json"
    index_file="${OUTPUT_DIR}/index.html"
    # Build files.json manifest robustly using jq. We list CSVs under resources/, skip the combined OUTPUT_FILE (all.csv)
    rm -f "$manifest_file"
    # Collect CSV file paths (sorted). Use newline-separated list (no NUL) since paths won't contain newlines.
    mapfile -t _csvs < <(find "${OUTPUT_DIR}/resources" -type f -name '*.csv' 2> /dev/null | sort || true)
    if [[ ${#_csvs[@]} -eq 0 ]]; then
        # Write empty JSON array
        printf '[]\n' > "$manifest_file"
    else
        # Emit relative paths (relative to OUTPUT_DIR) and skip combined OUTPUT_FILE
        {
            # Use a stable prefix to safely strip the OUTPUT_DIR from each file path
            local _prefix
            _prefix="${OUTPUT_DIR%/}/"
            for f in "${_csvs[@]}"; do
                if [[ "$(basename "$f")" == "$OUTPUT_FILE" ]]; then
                    continue
                fi
                printf '%s\n' "${f#"$_prefix"}"
            done
        } | jq -R -s -c 'split("\n") | map(select(length > 0)) | map({path: ., display_name: (.| split("/") | .[-1] | sub("\\.csv$"; ""))})' > "$manifest_file"
    fi

    # Copy reusable index.html template into place and substitute placeholders
    local template_file="${SCRIPT_DIR}/files/aws_get_resources/index.html"
    if [[ -f "$template_file" ]]; then
        cp "$template_file" "$index_file"
        # Include AWS Account ID in the title (e.g. "AWS Resources (123456789012)")
        local acct_id
        acct_id="${aws_account_id:-$(get_aws_account_id 2> /dev/null || echo unknown)}"
        sed -i "s|@@INDEX_TITLE@@|${INDEX_TITLE} (${acct_id})|g" "$index_file"
        sed -i "s|@@INDEX_DESCRIPTION@@|${INDEX_DESCRIPTION}|g" "$index_file"
        sed -i "s|@@OUTPUT_FILE@@|${OUTPUT_FILE}|g" "$index_file"
        log "INFO" "Copied HTML template to: $index_file"
    else
        log "WARN" "Template file not found at $template_file; falling back to embedded generator"
        # fallback: write a minimal index.html
        cat > "$index_file" << 'EOHTML'
<!doctype html><html><head><meta charset="utf-8"><title>AWS Resources</title></head><body><pre>Template missing</pre></body></html>
EOHTML
    fi

    log "INFO" "Generated HTML index: $index_file"
}

#######################################
# initialize_regions: Initialize regions to check
#
# Description:
#   Sets REGIONS_TO_CHECK array using the configured AWS_REGION and ensures
#   that us-east-1 is included to account for global services when needed.
#
# Arguments:
#   None
#
# Returns:
#   None (populates global REGIONS_TO_CHECK)
#
# Usage:
#   initialize_regions
#
#######################################
function initialize_regions {
    REGIONS_TO_CHECK=("$AWS_REGION")
    if [[ "$AWS_REGION" != "us-east-1" ]]; then
        REGIONS_TO_CHECK+=("us-east-1")
    fi
    log "INFO" "Regions to check: ${REGIONS_TO_CHECK[*]}"
}

#######################################
# output_csv_data: Output CSV data with standard formatting and sorting
#
# Description:
#   Writes CSV data to both per-category files and combined output file.
#   Supports optional sorting of output data.
#
# Arguments:
#   $1 - Resource category name
#   $2 - CSV header line
#   $3 - CSV data buffer
#   $4 - Whether to sort output (optional, defaults to SORT_OUTPUT global)
#
# Global Variables:
#   OUTPUT_DIR - Base output directory
#   OUTPUT_FILE - Combined output filename
#   COMBINED_OUTPUT_PATH - Path to combined CSV file
#   SORT_OUTPUT - Global sort setting
#
# Returns:
#   0 on success
#
# Usage:
#   output_csv_data "ec2" "Name,Type,State" "instance1,t2.micro,running"
#
#######################################
function output_csv_data {
    local category=$1
    local header=$2
    local buffer=$3
    local sort_output=${4:-"$SORT_OUTPUT"} # Use explicit parameter or global setting

    # Determine combined output path; MAIN sets COMBINED_OUTPUT_PATH. Fallback to OUTPUT_FILE in-place.
    local combined_path="${COMBINED_OUTPUT_PATH:-$OUTPUT_FILE}"

    if [[ -n "$buffer" ]]; then
        # Ensure resources subdirectory exists when writing per-category files
        mkdir -p "${OUTPUT_DIR}/resources"

        # Write per-category CSV (overwrite if exists) under resources/
        local category_file="${OUTPUT_DIR}/resources/${category}.csv"
        {
            echo "$header"
            if [[ "$sort_output" == "true" ]]; then
                csv_sort "$buffer"
            else
                printf "%b" "$buffer"
            fi
            echo ""
        } > "$category_file"

        # Append category content to combined CSV
        cat "$category_file" >> "$combined_path"
        log "INFO" "$category inventory written to $category_file and appended to $combined_path"
    else
        log "INFO" "No data for category $category; no file created"
    fi
}

#######################################
# main: Main execution function for AWS resource inventory collection
#
# Description:
#   Orchestrates the entire AWS resource inventory collection process,
#   including argument parsing, validation, resource collection, and output generation.
#
# Arguments:
#   $@ - Command line arguments passed to the script
#
# Global Variables:
#   OUTPUT_DIR - Output directory path
#   OUTPUT_FILE - Output filename
#   AWS_REGION - AWS region setting
#   CATEGORIES - Specific categories to collect
#   HTML_MODE - Whether to generate HTML index
#
# Returns:
#   0 on success, exits with error code on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # Record start time
    start_time=$(date +%s)

    # Validate dependencies
    validate_dependencies "aws" "jq"

    # Check AWS credentials before any AWS CLI usage
    if ! check_aws_credentials; then
        error_exit "AWS credentials are not set or invalid."
    fi

    # Initialize regions to check
    initialize_regions

    # Log script start
    echo_section "Starting AWS resource inventory collection"
    log "INFO" "Output file name: $OUTPUT_FILE (will be created in $OUTPUT_DIR)"
    log "INFO" "AWS region: $AWS_REGION"

    if [[ -n "$CATEGORIES" ]]; then
        log "INFO" "Collecting categories: $CATEGORIES"
    else
        log "INFO" "Collecting all categories"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "Running in dry-run mode, no changes will be made"
        exit 0
    fi

    # Determine OUTPUT_DIR: always append AWS account id to the user-provided path
    aws_account_id=$(get_aws_account_id 2> /dev/null || echo "unknown")
    # normalize OUTPUT_DIR by removing trailing slash then append account id
    OUTPUT_DIR="${OUTPUT_DIR%/}/${aws_account_id}"

    # Prepare output directory: remove its contents if it already exists (safe-clear)
    if [[ -d "${OUTPUT_DIR}" ]]; then
        log "INFO" "Cleaning existing output directory: ${OUTPUT_DIR}"
        # remove children but keep the directory itself
        find "${OUTPUT_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    else
        mkdir -p "${OUTPUT_DIR}"
    fi

    # Ensure resources subdirectory exists
    mkdir -p "${OUTPUT_DIR}/resources"

    # Place combined CSV inside resources/ so index.html remains separate and we can treat all.csv as download-only
    COMBINED_OUTPUT_PATH="${OUTPUT_DIR}/resources/${OUTPUT_FILE}"
    true > "$COMBINED_OUTPUT_PATH"

    # Determine which categories to process
    local categories_to_process=()
    if [[ -n "$CATEGORIES" ]]; then
        # Split comma-separated categories into array
        IFS=',' read -ra categories_to_process <<< "$CATEGORIES"
        log "INFO" "Processing specified categories: ${categories_to_process[*]}"

        # Validate specified categories
        for category in "${categories_to_process[@]}"; do
            local valid_category=false
            for valid in "${AWS_RESOURCE_CATEGORIES[@]}"; do
                if [[ "$category" == "$valid" ]]; then
                    valid_category=true
                    break
                fi
            done
            if [[ "$valid_category" == "false" ]]; then
                error_exit "Invalid category: $category. Valid categories are: ${AWS_RESOURCE_CATEGORIES[*]}"
            fi
        done
    else
        # Use all categories if none specified
        categories_to_process=("${AWS_RESOURCE_CATEGORIES[@]}")
        log "INFO" "Processing all categories: ${categories_to_process[*]}"
    fi

    # Collect inventory for specified categories
    for resource_category in "${categories_to_process[@]}"; do
        call_collect_aws_resources "$resource_category"
    done

    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    log "INFO" "AWS resource inventory completed in ${elapsed} seconds"

    echo_section "AWS resource inventory collection completed successfully"
    if [[ "${HTML_MODE:-false}" == "true" ]]; then
        generate_html_index
    fi
    # Show the combined output path where CSVs are stored
    echo "Results written to: ${COMBINED_OUTPUT_PATH:-$OUTPUT_FILE}"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi

#######################################
# cleanup: Cleanup handler for safe teardown and resource cleanup
#
# Description:
#   Performs cleanup operations when the script exits, including
#   removal of temporary files and graceful shutdown procedures.
#
# Arguments:
#   None
#
# Global Variables:
#   DRY_RUN - Whether running in dry-run mode
#
# Returns:
#   0 on success
#
# Usage:
#   cleanup (called automatically via trap)
#
#######################################
function cleanup {
    # Placeholder for temporary resource cleanup - update if mktemp is used
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log "INFO" "Exiting (dry-run); no cleanup required."
        return 0
    fi
    log "INFO" "Cleanup complete"
}

# Ensure cleanup runs on exit and catches common signals
trap cleanup EXIT INT TERM
