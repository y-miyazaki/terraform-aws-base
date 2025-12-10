#!/bin/bash
#######################################
# Description: Generate AWS architecture diagram YAML and image from AWS CLI using awsdac with hierarchical VPC structure
# Usage: ./aws_architecture_generate_diagram.sh [options]
#   options:
#     -h, --help        Display this help message
#     -v, --verbose     Enable verbose output
#     -d, --dry-run     Show what would be done without executing
#     -r, --region     AWS region to use (default: $AWS_DEFAULT_REGION or ap-northeast-1)
#     -o, --output      Output diagram file (default: aws_architecture_diagram.png)
#     -f, --format      Output format (png, svg, pdf) (default: png)
#     --git             Commit and push diagram to git (default: no git operation)
#
# Output:
# - Generates awsdac YAML file: auto_generated_aws_dac.yaml (always kept)
# - Creates architecture diagram image with hierarchical VPC structure (VPC → Subnet → EC2)
# - Optionally commits and pushes to git repository
#
# Dependencies:
# - aws CLI: Query AWS resources directly
# - jq: Parse JSON AWS CLI responses
# - awsdac: Generate diagram from YAML
#
# Design:
# - Queries AWS resources directly using AWS CLI
# - Extracts AWS resources (Lambda, S3) from AWS API responses
# - Generates awsdac-compatible YAML with hierarchical VPC structure (VPC → Subnet → EC2)
# - Creates diagram image using awsdac
# - Supports git integration for automated updates
#######################################

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
OUTPUT_FILE="aws_architecture_diagram.png"
OUTPUT_FORMAT="png"
AWS_REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"
GIT_COMMIT=false
TEMP_YAML_FILE="auto_generated_aws_dac.yaml"
REGIONS_TO_CHECK=()

# AWS resource categories list for diagram generation (alphabetical order)
# Simple resources use RESOURCE_CONFIGS, complex resources need custom functions
#
# NEW RESOURCE ADDITION EXAMPLES:
#
# For simple resources (recommended - just 2 steps):
# 1. Add "dynamodb" to AWS_RESOURCE_CATEGORIES array below
# 2. Uncomment RESOURCE_CONFIGS[dynamodb] line above
#
# For complex resources (only if special logic needed):
# 1. Add "custom" to AWS_RESOURCE_CATEGORIES array below
# 2. Create generate_custom_resources function (see generate_vpc_hierarchical_resources example)
#
# AWS resource categories for hierarchical diagram generation
AWS_RESOURCE_CATEGORIES=(
    "dynamodb"         # Uses RESOURCE_CONFIGS (simple) - Non-VPC resources
    "ecs"              # Uses RESOURCE_CONFIGS (simple) - Non-VPC resources
    "lambda_nonvpc"    # Uses HIERARCHICAL_CONFIGS (complex - Non-VPC Lambda functions)
    "s3_regional"      # Uses HIERARCHICAL_CONFIGS (complex - region filtering)
    "vpc_hierarchical" # Uses custom function (hierarchical VPC -> Subnet -> EC2 -> Lambda)
)

#######################################
# show_usage: Display usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    show_help_header "$(basename "$0")" "Generate AWS architecture diagram from AWS CLI" "[options]"
    echo "This script queries AWS resources using AWS CLI, generates"
    echo "awsdac YAML, and creates architecture diagram image."
    echo ""
    echo "Options:"
    echo "  -h, --help        Display this help message"
    echo "  -v, --verbose     Enable verbose output"
    echo "  -d, --dry-run     Show what would be done without executing"
    echo "  -r, --region      AWS region to query (default: \$AWS_DEFAULT_REGION or ap-northeast-1)"
    echo "  -o, --output      Output diagram file (default: aws_architecture_diagram.png)"
    echo "  -f, --format      Output format (png, svg, pdf) (default: png)"
    echo "  --git             Commit and push diagram to git (default: no git operation)"
    echo ""
    show_help_footer
    echo "Examples:"
    echo "  $0 -v -r us-west-2"
    echo "  $0 --dry-run"
    echo "  $0 -o my_diagram.svg -f svg"
    echo "  $0 --git"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and options
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   VERBOSE - Enable verbose output
#   DRY_RUN - Enable dry-run mode
#   OUTPUT_FILE - Output diagram file path
#   AWS_REGION - AWS region to query
#   OUTPUT_FORMAT - Output format for diagram
#   GIT_COMMIT - Enable git commit flag
#
# Returns:
#   None
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help) show_usage ;;
            -v | --verbose)
                VERBOSE=true
                export VERBOSE
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -o | --output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -r | --region)
                AWS_REGION="$2"
                shift 2
                ;;
            -f | --format)
                OUTPUT_FORMAT="$2"
                export OUTPUT_FORMAT
                shift 2
                ;;
            --git)
                GIT_COMMIT=true
                shift
                ;;
            *) break ;;
        esac
    done
}

#######################################
# Resource configuration functions
#
# To add a new resource type:
# SIMPLE RESOURCES (recommended):
# 1. Add "resource_name" to AWS_RESOURCE_CATEGORIES array
# 2. Define configuration in RESOURCE_CONFIGS associative array
#    Format: RESOURCE_CONFIGS[name]="service|command|field|type|regional"
#    Example: RESOURCE_CONFIGS[rds]="rds|describe-db-instances|DBInstanceIdentifier|AWS::RDS::DBInstance|true"
#
# COMPLEX RESOURCES (for special logic like VPC categorization):
# 1. Add "resource_name" to AWS_RESOURCE_CATEGORIES array
# 2. Create custom generate_resource_name_resources function
#    Example: generate_vpc_hierarchical_resources (see below)
#
# Quick examples:
# - RDS: RESOURCE_CONFIGS[rds]="rds|describe-db-instances|DBInstanceIdentifier|AWS::RDS::DBInstance|true"
# - EC2: RESOURCE_CONFIGS[ec2]="ec2|describe-instances|InstanceId|AWS::EC2::Instance|true"
# - ECS: RESOURCE_CONFIGS[ecs]="ecs|list-clusters|clusterName|AWS::ECS::Cluster|true"
#######################################

# Resource configuration templates (simple resources only)
# Format: RESOURCE_CONFIGS[name]="service|command|field|type|regional"
# - service: AWS CLI service name (e.g., "ec2", "rds")
# - command: List command (e.g., "describe-instances", "list-buckets")
# - field: Name field in response (e.g., "InstanceId", "BucketName")
# - type: AWS resource type for diagram (e.g., "AWS::EC2::Instance")
# - regional: "true" if regional service, "false" if global (e.g., S3 buckets)
declare -A RESOURCE_CONFIGS
RESOURCE_CONFIGS[ec2]="ec2|describe-instances|InstanceId|AWS::EC2::Instance|true"
RESOURCE_CONFIGS[rds]="rds|describe-db-instances|DBInstanceIdentifier|AWS::RDS::DBInstance|true"
RESOURCE_CONFIGS[ecs]="ecs|list-clusters|clusterName|AWS::ECS::Cluster|true"

# Hierarchical resource configuration for V2 mode
# Format: HIERARCHICAL_CONFIGS[name]="service|command|field|type|regional|parent_service|parent_field"
# Note: Currently used for documentation and future generic hierarchical implementation
declare -A HIERARCHICAL_CONFIGS
export HIERARCHICAL_CONFIGS
HIERARCHICAL_CONFIGS[vpc]="ec2|describe-vpcs|VpcId|AWS::EC2::VPC|true||"
HIERARCHICAL_CONFIGS[subnet]="ec2|describe-subnets|SubnetId|AWS::EC2::Subnet|true|vpc|VpcId"
HIERARCHICAL_CONFIGS[ec2_hierarchical]="ec2|describe-instances|InstanceId|AWS::EC2::Instance|true|subnet|SubnetId"
HIERARCHICAL_CONFIGS[lambda_vpc]="lambda|list-functions|FunctionName|AWS::Lambda::Function|true||VPC"
HIERARCHICAL_CONFIGS[lambda_nonvpc]="lambda|list-functions|FunctionName|AWS::Lambda::Function|true||NonVPC"
HIERARCHICAL_CONFIGS[s3_regional]="s3api|list-buckets|Name|AWS::S3::Bucket|false||Regional"

# Additional common AWS resources (ready to use - just add to AWS_RESOURCE_CATEGORIES)
RESOURCE_CONFIGS[dynamodb]="dynamodb|list-tables|TableName|AWS::DynamoDB::Table|true"
# RESOURCE_CONFIGS[sns]="sns|list-topics|TopicArn|AWS::SNS::Topic|true"
# RESOURCE_CONFIGS[sqs]="sqs|list-queues|QueueUrl|AWS::SQS::Queue|true"
# RESOURCE_CONFIGS[elasticache]="elasticache|describe-cache-clusters|CacheClusterId|AWS::ElastiCache::CacheCluster|true"
# RESOURCE_CONFIGS[elasticsearch]="es|list-domain-names|DomainName|AWS::Elasticsearch::Domain|true"
# RESOURCE_CONFIGS[kinesis]="kinesis|list-streams|StreamName|AWS::Kinesis::Stream|true"

#######################################
# generate_diagram: Generate diagram using awsdac
#
# Description:
#   Generate diagram using awsdac
#
# Arguments:
#   $1 - YAML file path
#   $2 - Output file path
#
# Global Variables:
#   VERBOSE - Enable verbose output
#   OUTPUT_FORMAT - Output format
#
# Returns:
#   0 on success, exits on failure
#
# Usage:
#   generate_diagram "yaml_file" "out_file"
#
#######################################
function generate_diagram {
    local yaml_file=$1
    local out_file=$2

    log "INFO" "Generating diagram: $out_file from $yaml_file"

    if ! command -v awsdac > /dev/null 2>&1; then
        error_exit "awsdac command not found. Please install awsdac."
    fi

    # Use OUTPUT_FORMAT if awsdac supports format option
    if [[ "$VERBOSE" == "true" ]]; then
        awsdac -d "$yaml_file" -o "$out_file" --verbose || {
            error_exit "Failed to generate diagram with awsdac"
        }
    else
        awsdac -d "$yaml_file" -o "$out_file" || {
            error_exit "Failed to generate diagram with awsdac"
        }
    fi

    log "INFO" "Diagram successfully generated: $out_file"
}

#######################################
# generate_generic_resources: Generic resource generator for simple resources
#
# Description:
#   Generic resource generator for simple resources
#
# Arguments:
#   $1 - Resource name
#   $2 - Data source (ignored for AWS CLI mode)
#   $3 - Output mode (optional, default: yaml)
#
# Global Variables:
#   RESOURCE_CONFIGS - Associative array of resource configurations
#   REGIONS_TO_CHECK - Array of regions to check
#   TEMP_YAML_FILE - Temporary YAML file path
#
# Returns:
#   0 on success
#
# Usage:
#   generate_generic_resources "resource_name" "data_source" "output_mode"
#
#######################################
function generate_generic_resources {
    local resource_name=$1
    local _data_source=$2 # Ignored for AWS CLI mode
    local output_mode=${3:-"yaml"}

    # Check if resource has configuration
    if [[ -z "${RESOURCE_CONFIGS[$resource_name]:-}" ]]; then
        log "WARN" "No configuration found for resource: $resource_name"
        return 0
    fi

    IFS='|' read -r aws_service list_command name_field type_field region_specific <<< "${RESOURCE_CONFIGS[$resource_name]}"

    case "$output_mode" in
        "stacks")
            echo "${resource_name^}Stack:${resource_name^} Resources"
            ;;
        "yaml" | *)
            for region in "${REGIONS_TO_CHECK[@]}"; do
                # Skip region-specific check for global services
                if [[ "$region_specific" == "false" && "$region" != "${REGIONS_TO_CHECK[0]}" ]]; then
                    continue
                fi

                local safe_region="${region//-/_}"
                local resources

                # Get resources using AWS CLI
                if aws "$aws_service" "$list_command" --region "$region" &> /dev/null; then
                    case "$aws_service" in
                        "ec2")
                            # Only get EC2 instances not in VPC (standalone EC2-Classic instances)
                            resources=$(aws ec2 describe-instances --region "$region" --query "Reservations[].Instances[?State.Name==\`running\` && VpcId==null]" --output json 2> /dev/null || echo '[]')
                            resources=$(echo "$resources" | jq -c 'flatten')
                            ;;
                        "rds")
                            # Only get RDS instances not in VPC
                            all_rds=$(aws rds describe-db-instances --region "$region" --query "DBInstances[]" --output json 2> /dev/null || echo '[]')
                            resources=$(echo "$all_rds" | jq -c '[.[] | select(.DBSubnetGroup.VpcId == null or .DBSubnetGroup == null)]')
                            ;;
                        "ecs")
                            resources=$(aws ecs list-clusters --region "$region" --query "clusterArns[]" --output json 2> /dev/null || echo '[]')
                            ;;
                        "dynamodb")
                            resources=$(aws_paginate_items 'TableNames' aws dynamodb list-tables --region "$region" 2> /dev/null || echo '[]')
                            ;;
                        *)
                            # Generic command execution for other services
                            resources=$(aws "$aws_service" "$list_command" --region "$region" --output json 2> /dev/null || echo '[]')
                            ;;
                    esac
                else
                    resources='[]'
                fi

                # Process resources and generate YAML
                local resource_count=0
                local resource_names=()

                # Count and collect resource names
                while IFS= read -r resource_data; do
                    if [[ "$resource_data" != "null" && "$resource_data" != "" ]]; then
                        local resource_name_value
                        case "$aws_service" in
                            "ecs")
                                # ECS clusters return ARNs, extract name
                                resource_name_value=$(basename "$resource_data")
                                ;;
                            "dynamodb")
                                # DynamoDB returns table names directly as strings
                                resource_name_value="$resource_data"
                                ;;
                            *)
                                # Standard field extraction for most services
                                resource_name_value=$(echo "$resource_data" | jq -r ".$name_field // \"Unknown\"")
                                ;;
                        esac

                        if [[ -n "$resource_name_value" && "$resource_name_value" != "null" ]]; then
                            resource_names+=("$resource_name_value")
                            resource_count=$((resource_count + 1))
                        fi
                    fi
                done < <(echo "$resources" | jq -c '.[]? // empty')

                # Generate stack and resources if count > 0
                if [[ $resource_count -gt 0 ]]; then
                    cat >> "$TEMP_YAML_FILE" << EOF

    ${resource_name^}Stack_${safe_region}:
      Type: AWS::Diagram::VerticalStack
      Title: ${resource_name^} Resources ($region)
      Children:
EOF

                    local counter=1
                    for res_name in "${resource_names[@]}"; do
                        echo "        - ${resource_name^}_${safe_region}_${counter}" >> "$TEMP_YAML_FILE"
                        counter=$((counter + 1))
                    done

                    # Generate resource definitions
                    counter=1
                    for res_name in "${resource_names[@]}"; do
                        # Clean up resource name for title (remove quotes and special chars)
                        local clean_name
                        clean_name=$(echo "$res_name" | sed 's/^"//;s/"$//;s/[<>:"/\\|?*]/-/g')

                        cat >> "$TEMP_YAML_FILE" << EOF

    ${resource_name^}_${safe_region}_${counter}:
      Type: $type_field
      Title: $clean_name
EOF
                        counter=$((counter + 1))
                    done
                fi
            done
            ;;
    esac
}

#######################################
# generate_stack_children: Generate stack children for a given category and region
#
# Description:
#   Generate stack children for a given category and region
#
# Arguments:
#   $1 - Category
#   $2 - Safe region name
#
# Global Variables:
#   HIERARCHICAL_CONFIGS - Associative array of hierarchical configurations
#   RESOURCE_CONFIGS - Associative array of resource configurations
#
# Returns:
#   Stack children lines
#
# Usage:
#   generate_stack_children "category" "safe_region"
#
#######################################
function generate_stack_children {
    local category=$1
    local safe_region=$2

    # Get stack list from resource function
    local generate_function="generate_${category}_resources"
    local stack_lines

    if declare -f "$generate_function" > /dev/null; then
        # Use custom function if exists
        stack_lines=$(${generate_function} "" "stacks")
    elif [[ -n "${HIERARCHICAL_CONFIGS[$category]:-}" ]]; then
        # Use hierarchical function for hierarchical resources
        case "$category" in
            "lambda_nonvpc")
                stack_lines="LambdaNonVPCStack:Lambda Functions (Non-VPC)"
                ;;
            "s3_regional")
                stack_lines="S3Stack:S3 Buckets"
                ;;
            *)
                stack_lines="${category^}Stack:${category^} Resources"
                ;;
        esac
    elif [[ -n "${RESOURCE_CONFIGS[$category]:-}" ]]; then
        # Use generic function for configured resources
        stack_lines=$(generate_generic_resources "$category" "" "stacks")
    else
        # Default configuration for unknown resource types
        stack_lines="${category^}Stack:${category^} Resources"
    fi

    # Process each stack line
    while IFS=':' read -r stack_name title_suffix; do
        if [[ -n "$stack_name" && -n "$title_suffix" ]]; then
            echo "        - ${stack_name}_${safe_region}"
        fi
    done <<< "$stack_lines"
}

#######################################
# generate_vpc_hierarchical_resources: Generate VPC resources hierarchically
#
# Description:
#   Generate VPC resources hierarchically
#
# Arguments:
#   $1 - Data source (ignored for AWS CLI mode)
#   $2 - Output mode (optional, default: yaml)
#
# Global Variables:
#   REGIONS_TO_CHECK - Array of regions to check
#   TEMP_YAML_FILE - Temporary YAML file path
#
# Returns:
#   Stack list or complete YAML depending on output mode
#
# Usage:
#   generate_vpc_hierarchical_resources "data_source" "output_mode"
#
#######################################
function generate_vpc_hierarchical_resources {
    local _data_source=$1 # Ignored for AWS CLI mode
    local output_mode=${2:-"yaml"}

    case "$output_mode" in
        "stacks")
            # Return stack list for Children
            echo "VPCHierarchicalStack:VPC Resources (Hierarchical)"
            ;;
        "yaml" | *)
            # Generate complete hierarchical YAML structure
            for region in "${REGIONS_TO_CHECK[@]}"; do
                local safe_region="${region//-/_}"

                # Get VPC information using AWS CLI
                local vpcs
                if aws ec2 describe-vpcs --region "$region" &> /dev/null; then
                    vpcs=$(aws ec2 describe-vpcs --region "$region" --output json 2> /dev/null || echo '{"Vpcs":[]}')
                else
                    vpcs='{"Vpcs":[]}'
                fi

                # Process and collect VPCs with their hierarchical children
                local vpc_data=()
                local vpc_count=0

                # First pass: collect all VPCs
                while IFS= read -r vpc_info; do
                    if [[ "$vpc_info" != "null" && "$vpc_info" != "" ]]; then
                        local vpc_id
                        vpc_id=$(echo "$vpc_info" | jq -r '.VpcId // ""')

                        if [[ -n "$vpc_id" && "$vpc_id" != "null" ]]; then
                            vpc_data+=("$vpc_info")
                            vpc_count=$((vpc_count + 1))
                        fi
                    fi
                done < <(echo "$vpcs" | jq -c '.Vpcs[]? // empty')

                # Only generate if there are VPCs
                if [[ $vpc_count -gt 0 ]]; then
                    # Generate main VPC stack
                    cat >> "$TEMP_YAML_FILE" << EOF

    VPCHierarchicalStack_${safe_region}:
      Type: AWS::Diagram::VerticalStack
      Title: VPC Resources (Hierarchical) ($region)
      Children:
EOF

                    # Add VPC references to main stack
                    local vpc_counter=1
                    for vpc_info in "${vpc_data[@]}"; do
                        echo "        - VPCHierarchical_${safe_region}_${vpc_counter}" >> "$TEMP_YAML_FILE"
                        vpc_counter=$((vpc_counter + 1))
                    done

                    # Generate hierarchical VPC definitions with children
                    vpc_counter=1
                    for vpc_info in "${vpc_data[@]}"; do
                        local vpc_id
                        local vpc_name
                        vpc_id=$(echo "$vpc_info" | jq -r '.VpcId // ""')

                        # Try to get VPC name from tags
                        vpc_name=$(echo "$vpc_info" | jq -r '.Tags[]? | select(.Key=="Name") | .Value // ""' 2> /dev/null || echo "")
                        if [[ -z "$vpc_name" || "$vpc_name" == "null" ]]; then
                            vpc_name="$vpc_id"
                        fi

                        # Get subnets for this VPC
                        local subnets
                        subnets=$(aws ec2 describe-subnets --region "$region" --filters "Name=vpc-id,Values=$vpc_id" --output json 2> /dev/null || echo '{"Subnets":[]}')

                        local subnet_children=()
                        local subnet_counter=1

                        # Collect subnet information
                        while IFS= read -r subnet_info; do
                            if [[ "$subnet_info" != "null" && "$subnet_info" != "" ]]; then
                                local subnet_id
                                subnet_id=$(echo "$subnet_info" | jq -r '.SubnetId // ""')

                                if [[ -n "$subnet_id" && "$subnet_id" != "null" ]]; then
                                    subnet_children+=("Subnet_${safe_region}_${vpc_counter}_${subnet_counter}")
                                    subnet_counter=$((subnet_counter + 1))
                                fi
                            fi
                        done < <(echo "$subnets" | jq -c '.Subnets[]? // empty')

                        # Generate VPC definition with subnet children
                        cat >> "$TEMP_YAML_FILE" << EOF

    VPCHierarchical_${safe_region}_${vpc_counter}:
      Type: AWS::EC2::VPC
      Title: $vpc_name
EOF

                        # Add children if subnets exist
                        if [[ ${#subnet_children[@]} -gt 0 ]]; then
                            echo "      Children:" >> "$TEMP_YAML_FILE"
                            for subnet_child in "${subnet_children[@]}"; do
                                echo "        - $subnet_child" >> "$TEMP_YAML_FILE"
                            done
                        fi

                        # Generate subnet definitions with EC2 children
                        subnet_counter=1
                        while IFS= read -r subnet_info; do
                            if [[ "$subnet_info" != "null" && "$subnet_info" != "" ]]; then
                                local subnet_id
                                local subnet_name
                                local availability_zone
                                subnet_id=$(echo "$subnet_info" | jq -r '.SubnetId // ""')
                                availability_zone=$(echo "$subnet_info" | jq -r '.AvailabilityZone // ""')

                                if [[ -n "$subnet_id" && "$subnet_id" != "null" ]]; then
                                    # Try to get subnet name from tags
                                    subnet_name=$(echo "$subnet_info" | jq -r '.Tags[]? | select(.Key=="Name") | .Value // ""' 2> /dev/null || echo "")
                                    if [[ -z "$subnet_name" || "$subnet_name" == "null" ]]; then
                                        subnet_name="$subnet_id ($availability_zone)"
                                    fi

                                    # Get EC2 instances in this subnet
                                    local ec2_instances
                                    ec2_instances=$(aws ec2 describe-instances --region "$region" --filters "Name=subnet-id,Values=$subnet_id" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[]" --output json 2> /dev/null || echo '[]')

                                    # Get Lambda functions in this VPC (paginated)
                                    local lambda_functions
                                    lambda_functions=$(aws_paginate_items 'Functions' aws lambda list-functions --region "$region" 2> /dev/null | jq -s '{Functions: .}' 2> /dev/null || echo '{"Functions":[]}')

                                    local ec2_children=()
                                    local lambda_children=()
                                    local ec2_counter=1
                                    local lambda_counter=1

                                    # Collect EC2 instances in this subnet
                                    while IFS= read -r instance_info; do
                                        if [[ "$instance_info" != "null" && "$instance_info" != "" ]]; then
                                            local instance_id
                                            instance_id=$(echo "$instance_info" | jq -r '.InstanceId // ""')

                                            if [[ -n "$instance_id" && "$instance_id" != "null" ]]; then
                                                ec2_children+=("EC2Hierarchical_${safe_region}_${vpc_counter}_${subnet_counter}_${ec2_counter}")
                                                ec2_counter=$((ec2_counter + 1))
                                            fi
                                        fi
                                    done < <(echo "$ec2_instances" | jq -c '.[]? // empty')

                                    # Collect Lambda functions in this VPC
                                    while IFS= read -r function_base64; do
                                        local function_json
                                        function_json=$(echo "$function_base64" | base64 --decode 2> /dev/null)
                                        [[ -z "$function_json" ]] && continue

                                        local function_name
                                        function_name=$(echo "$function_json" | jq -r '.FunctionName // empty')
                                        [[ -z "$function_name" ]] && continue

                                        # Check if Lambda is in this VPC
                                        local lambda_vpc_config
                                        lambda_vpc_config=$(echo "$function_json" | jq -r '.VpcConfig // empty')

                                        if [[ -n "$lambda_vpc_config" && "$lambda_vpc_config" != "null" && "$lambda_vpc_config" != "{}" ]]; then
                                            local lambda_vpc_id
                                            lambda_vpc_id=$(echo "$function_json" | jq -r '.VpcConfig.VpcId // empty')

                                            # Check if Lambda is in current VPC
                                            if [[ "$lambda_vpc_id" == "$vpc_id" ]]; then
                                                lambda_children+=("LambdaVPC_${safe_region}_${vpc_counter}_${lambda_counter}:$function_name")
                                                lambda_counter=$((lambda_counter + 1))
                                            fi
                                        fi
                                    done < <(echo "$lambda_functions" | jq -r '.Functions[]? | @base64')

                                    # Combine all children for subnet
                                    local all_children=()
                                    all_children+=("${ec2_children[@]}")

                                    # Add Lambda children (use subnet-specific IDs)
                                    local lambda_child_counter=1
                                    for lambda_child in "${lambda_children[@]}"; do
                                        all_children+=("LambdaVPC_${safe_region}_${vpc_counter}_${subnet_counter}_${lambda_child_counter}")
                                        lambda_child_counter=$((lambda_child_counter + 1))
                                    done

                                    # Generate subnet definition
                                    cat >> "$TEMP_YAML_FILE" << EOF

    Subnet_${safe_region}_${vpc_counter}_${subnet_counter}:
      Type: AWS::EC2::Subnet
      Title: $subnet_name
EOF

                                    # Add all children if they exist
                                    if [[ ${#all_children[@]} -gt 0 ]]; then
                                        echo "      Children:" >> "$TEMP_YAML_FILE"
                                        for child in "${all_children[@]}"; do
                                            echo "        - $child" >> "$TEMP_YAML_FILE"
                                        done
                                    fi

                                    # Generate EC2 instance definitions
                                    ec2_counter=1
                                    while IFS= read -r instance_info; do
                                        if [[ "$instance_info" != "null" && "$instance_info" != "" ]]; then
                                            local instance_id
                                            local instance_name
                                            local instance_type
                                            instance_id=$(echo "$instance_info" | jq -r '.InstanceId // ""')
                                            instance_type=$(echo "$instance_info" | jq -r '.InstanceType // ""')

                                            if [[ -n "$instance_id" && "$instance_id" != "null" ]]; then
                                                # Try to get instance name from tags
                                                instance_name=$(echo "$instance_info" | jq -r '.Tags[]? | select(.Key=="Name") | .Value // ""' 2> /dev/null || echo "")
                                                if [[ -z "$instance_name" || "$instance_name" == "null" ]]; then
                                                    instance_name="$instance_id ($instance_type)"
                                                fi

                                                cat >> "$TEMP_YAML_FILE" << EOF

    EC2Hierarchical_${safe_region}_${vpc_counter}_${subnet_counter}_${ec2_counter}:
      Type: AWS::EC2::Instance
      Title: $instance_name
EOF
                                                ec2_counter=$((ec2_counter + 1))
                                            fi
                                        fi
                                    done < <(echo "$ec2_instances" | jq -c '.[]? // empty')

                                    # Generate Lambda function definitions for this subnet
                                    local lambda_child_counter=1
                                    for lambda_child in "${lambda_children[@]}"; do
                                        local lambda_name="${lambda_child##*:}"
                                        cat >> "$TEMP_YAML_FILE" << EOF

    LambdaVPC_${safe_region}_${vpc_counter}_${subnet_counter}_${lambda_child_counter}:
      Type: AWS::Lambda::Function
      Title: $lambda_name (VPC)
EOF
                                        lambda_child_counter=$((lambda_child_counter + 1))
                                    done

                                    subnet_counter=$((subnet_counter + 1))
                                fi
                            fi
                        done < <(echo "$subnets" | jq -c '.Subnets[]? // empty')

                        vpc_counter=$((vpc_counter + 1))
                    done
                fi
            done
            ;;
    esac
}

#######################################
# generate_hierarchical_resources: Generate hierarchical resources with complex logic
#
# Description:
#   Generate hierarchical resources with complex logic
#
# Arguments:
#   $1 - Resource name
#
# Global Variables:
#   None
#
# Returns:
#   None
#
# Usage:
#   generate_hierarchical_resources "resource_name"
#
#######################################
generate_hierarchical_resources() {
    local resource_name="$1"
    log "INFO" "Generating hierarchical resources for: $resource_name"

    case "$resource_name" in
        "lambda_nonvpc")
            generate_lambda_nonvpc_hierarchical_resources
            ;;
        "s3_regional")
            generate_s3_hierarchical_resources
            ;;
        *)
            log "WARN" "Unknown hierarchical resource type: $resource_name"
            ;;
    esac
}

#######################################
# generate_lambda_vpc_hierarchical_resources: Generate lambda resources hierarchically with VPC categorization
#
# Description:
#   Generate lambda resources hierarchically with VPC categorization
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   None
#
# Usage:
#   generate_lambda_vpc_hierarchical_resources
#
#######################################
generate_lambda_vpc_hierarchical_resources() {
    log "INFO" "Lambda VPC resources integrated into VPC hierarchy (no separate stack needed)"
    # VPC Lambda functions are automatically included in generate_vpc_hierarchical_resources
    # This ensures proper parent-child relationships within VPC → Subnet → Lambda structure
}

#######################################
# generate_lambda_nonvpc_hierarchical_resources: Generate Non-VPC Lambda resources hierarchically
#
# Description:
#   Generate Non-VPC Lambda resources hierarchically
#
# Arguments:
#   None
#
# Global Variables:
#   REGIONS_TO_CHECK - Array of regions to check
#   TEMP_YAML_FILE - Temporary YAML file path
#
# Returns:
#   None
#
# Usage:
#   generate_lambda_nonvpc_hierarchical_resources
#
#######################################
generate_lambda_nonvpc_hierarchical_resources() {
    log "INFO" "Generating Lambda Non-VPC resources"

    for region in "${REGIONS_TO_CHECK[@]}"; do
        local safe_region="${region//-/_}"

        # Get all Lambda functions (paginated)
        local functions_json
        functions_json=$(aws_paginate_items 'Functions' aws lambda list-functions --region "$region" 2> /dev/null | jq -s '{Functions: .}' 2> /dev/null || echo '{"Functions":[]}')

        # Filter Non-VPC functions
        local nonvpc_functions=()
        while IFS= read -r function_base64; do
            local function_json
            function_json=$(echo "$function_base64" | base64 --decode 2> /dev/null)
            [[ -z "$function_json" ]] && continue

            local function_name
            function_name=$(echo "$function_json" | jq -r '.FunctionName // empty')
            [[ -z "$function_name" ]] && continue

            # Check VPC configuration
            local vpc_config
            vpc_config=$(echo "$function_json" | jq -r '.VpcConfig // empty')

            local is_vpc=false
            if [[ -n "$vpc_config" && "$vpc_config" != "null" && "$vpc_config" != "{}" ]]; then
                local vpc_id
                vpc_id=$(echo "$function_json" | jq -r '.VpcConfig.VpcId // empty')
                if [[ -n "$vpc_id" && "$vpc_id" != "null" ]]; then
                    is_vpc=true
                fi
            fi

            if [[ "$is_vpc" != true ]]; then
                nonvpc_functions+=("$function_name")
            fi
        done < <(echo "$functions_json" | jq -r '.Functions[]? | @base64')

        # Generate stack if Non-VPC functions exist
        if [[ ${#nonvpc_functions[@]} -gt 0 ]]; then
            cat >> "$TEMP_YAML_FILE" << EOF

    LambdaNonVPCStack_${safe_region}:
      Type: AWS::Diagram::VerticalStack
      Title: Lambda Functions (Non-VPC) ($region)
      Children:
EOF
            local counter=1
            for func_name in "${nonvpc_functions[@]}"; do
                echo "        - LambdaNonVPC_${safe_region}_${counter}" >> "$TEMP_YAML_FILE"
                counter=$((counter + 1))
            done

            # Generate resource definitions
            counter=1
            for func_name in "${nonvpc_functions[@]}"; do
                cat >> "$TEMP_YAML_FILE" << EOF

    LambdaNonVPC_${safe_region}_${counter}:
      Type: AWS::Lambda::Function
      Title: $func_name (Non-VPC)
EOF
                counter=$((counter + 1))
            done
        fi
    done
}

#######################################
# generate_s3_hierarchical_resources: Generate S3 resources hierarchically
#
# Description:
#   Generate S3 resources hierarchically
#
# Arguments:
#   None
#
# Global Variables:
#   REGIONS_TO_CHECK - Array of regions to check
#   TEMP_YAML_FILE - Temporary YAML file path
#
# Returns:
#   None
#
# Usage:
#   generate_s3_hierarchical_resources
#
#######################################
generate_s3_hierarchical_resources() {
    log "INFO" "Generating S3 resources"

    for region in "${REGIONS_TO_CHECK[@]}"; do
        local safe_region="${region//-/_}"

        # Get all S3 buckets (global)
        local buckets_json
        buckets_json=$(aws s3api list-buckets 2> /dev/null || echo '{"Buckets":[]}')

        # Filter buckets by region
        local region_buckets=()
        while IFS= read -r bucket_base64; do
            local bucket_json
            bucket_json=$(echo "$bucket_base64" | base64 --decode 2> /dev/null)
            [[ -z "$bucket_json" ]] && continue

            local bucket_name
            bucket_name=$(echo "$bucket_json" | jq -r '.Name // empty')
            [[ -z "$bucket_name" ]] && continue

            # Get bucket location
            local bucket_region
            bucket_region=$(aws s3api get-bucket-location --bucket "$bucket_name" 2> /dev/null | jq -r '.LocationConstraint // "us-east-1"')

            # Handle us-east-1 special case
            if [[ "$bucket_region" == "null" || -z "$bucket_region" ]]; then
                bucket_region="us-east-1"
            fi

            # Filter by region
            if [[ "$bucket_region" == "$region" ]]; then
                region_buckets+=("$bucket_name")
            fi
        done < <(echo "$buckets_json" | jq -r '.Buckets[]? | @base64')

        # Generate stack if buckets exist in this region
        if [[ ${#region_buckets[@]} -gt 0 ]]; then
            cat >> "$TEMP_YAML_FILE" << EOF

    S3Stack_${safe_region}:
      Type: AWS::Diagram::VerticalStack
      Title: S3 Buckets ($region)
      Children:
EOF
            local counter=1
            for bucket_name in "${region_buckets[@]}"; do
                echo "        - S3_${safe_region}_${counter}" >> "$TEMP_YAML_FILE"
                counter=$((counter + 1))
            done

            # Generate resource definitions
            counter=1
            for bucket_name in "${region_buckets[@]}"; do
                cat >> "$TEMP_YAML_FILE" << EOF

    S3_${safe_region}_${counter}:
      Type: AWS::S3::Bucket
      Title: $bucket_name
EOF
                counter=$((counter + 1))
            done
        fi
    done
}

#######################################
# initialize_regions: Function to initialize regions to check
#
# Description:
#   Function to initialize regions to check
#
# Arguments:
#   None
#
# Global Variables:
#   AWS_REGION - AWS region to query
#   REGIONS_TO_CHECK - Array of regions to check
#
# Returns:
#   None
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
# output_yaml: Generate awsdac YAML from AWS CLI
#
# Description:
#   Generate awsdac YAML from AWS CLI
#
# Arguments:
#   None
#
# Global Variables:
#   TEMP_YAML_FILE - Temporary YAML file path
#   REGIONS_TO_CHECK - Array of regions to check
#   AWS_RESOURCE_CATEGORIES - Array of resource categories
#
# Returns:
#   0 on success
#
# Usage:
#   output_yaml
#
#######################################
function output_yaml {
    log "INFO" "Generating awsdac YAML from AWS CLI"

    # Generate YAML header
    cat > "$TEMP_YAML_FILE" << EOF
Diagram:
  DefinitionFiles:
    - Type: URL
      Url: "https://raw.githubusercontent.com/awslabs/diagram-as-code/main/definitions/definition-for-aws-icons-light.yaml"

  Resources:
    Canvas:
      Type: AWS::Diagram::Canvas
      Direction: horizontal
      Children:
        - User
        - AWSCloud

    User:
      Type: AWS::Diagram::Resource
      Preset: User

    AWSCloud:
      Type: AWS::Diagram::Cloud
      Direction: horizontal
      Preset: AWSCloudNoLogo
      Align: center
      Children:
EOF

    # Add region children (using region names)
    for region in "${REGIONS_TO_CHECK[@]}"; do
        local safe_region="${region//-/_}"
        echo "        - Region_${safe_region}"
    done >> "$TEMP_YAML_FILE"

    # Generate region definitions
    for region in "${REGIONS_TO_CHECK[@]}"; do
        local safe_region="${region//-/_}"
        cat >> "$TEMP_YAML_FILE" << EOF

    Region_${safe_region}:
      Type: AWS::Region
      Title: $region
      Children:
EOF
        # Add children for each resource type that has resources in this region
        for category in "${AWS_RESOURCE_CATEGORIES[@]}"; do
            generate_stack_children "$category" "$safe_region"
        done >> "$TEMP_YAML_FILE"
    done

    # Generate complete YAML (stack definitions and resources) for each category
    for category in "${AWS_RESOURCE_CATEGORIES[@]}"; do
        local generate_function="generate_${category}_resources"

        if declare -f "$generate_function" > /dev/null; then
            # Use custom function if exists
            ${generate_function} "aws_cli" "yaml"
        elif [[ -n "${HIERARCHICAL_CONFIGS[$category]:-}" ]]; then
            # Use hierarchical function for hierarchical resources
            generate_hierarchical_resources "$category"
        elif [[ -n "${RESOURCE_CONFIGS[$category]:-}" ]]; then
            # Use generic function for configured resources
            generate_generic_resources "$category" "aws_cli" "yaml"
        else
            log "WARN" "No handler found for resource category: $category"
        fi
    done

    # Generate YAML footer
    cat >> "$TEMP_YAML_FILE" << 'EOF'

  Links:
    - Source: User
      SourcePosition: E
      Target: AWSCloud
      TargetPosition: W
      TargetArrowHead:
        Type: Open
      Type: straight
EOF

    log "INFO" "YAML generated: $TEMP_YAML_FILE"
}

#######################################
# update_git_repository: Update git repository if requested
#
# Description:
#   Update git repository if requested
#
# Arguments:
#   $1 - Diagram file path
#
# Global Variables:
#   GIT_COMMIT - Enable git commit flag
#   VERBOSE - Enable verbose output
#
# Returns:
#   0 on success, exits on failure
#
# Usage:
#   update_git_repository "diagram_file"
#
#######################################
function update_git_repository {
    local diagram_file=$1

    if [[ "$GIT_COMMIT" != "true" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            log "INFO" "Git integration disabled, skipping repository update"
        fi
        return 0
    fi

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log "WARN" "Not in a git repository, skipping git operations"
        return 0
    fi

    log "INFO" "Updating git repository with generated diagram"

    # Add and commit the diagram file
    git add "$diagram_file" || {
        error_exit "Failed to add diagram file to git"
    }

    git commit -m "Update AWS architecture diagram [auto] $(date '+%Y-%m-%d %H:%M:%S')" || {
        log "INFO" "No changes to commit (diagram unchanged)"
        return 0
    }

    # Push if we're in CI/CD environment
    if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${GITLAB_CI:-}" ]]; then
        log "INFO" "CI/CD environment detected, pushing changes"
        git push || {
            error_exit "Failed to push changes to git repository"
        }
    else
        log "INFO" "Manual environment detected, commit completed (not pushing)"
    fi
}

#######################################
# main: Main execution function
#
# Description:
#   Main execution function
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   DRY_RUN - Dry-run mode flag
#   OUTPUT_FILE - Output diagram file path
#   GIT_COMMIT - Git commit flag
#   AWS_REGION - AWS region
#   TEMP_YAML_FILE - Temporary YAML file path
#   OUTPUT_FILE - Output file path
#
# Returns:
#   0 on success, exits on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse command line arguments
    parse_arguments "$@"

    # Handle dry-run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "[DRY RUN] Would generate diagram"
        log "INFO" "[DRY RUN] Output file: $OUTPUT_FILE"
        log "INFO" "[DRY RUN] Git commit: $GIT_COMMIT"
        log "INFO" "[DRY RUN] AWS Region: $AWS_REGION"
        return 0
    fi

    # Validate required dependencies
    validate_dependencies "aws" "jq" "awsdac"

    # Check AWS credentials before any AWS CLI usage
    if ! check_aws_credentials; then
        error_exit "AWS credentials are not set or invalid."
    fi

    # Initialize regions to check based on AWS_REGION
    initialize_regions

    # Log script start
    echo_section "Starting create AWS Diagram from AWS CLI"

    # Change to workspace root
    cd /workspace || error_exit "Failed to change to workspace directory"

    # Generate awsdac YAML and diagram
    log "INFO" "Generating awsdac YAML and diagram from AWS CLI"
    output_yaml || {
        error_exit "Failed to generate awsdac YAML"
    }

    generate_diagram "$TEMP_YAML_FILE" "$OUTPUT_FILE" || {
        error_exit "Failed to generate diagram"
    }

    # Update git repository if requested
    update_git_repository "$OUTPUT_FILE"

    echo_section "AWS architecture diagram generation completed successfully"
    log "INFO" "Generated files:"
    log "INFO" "  - YAML: $TEMP_YAML_FILE"
    log "INFO" "  - Diagram: $OUTPUT_FILE"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
