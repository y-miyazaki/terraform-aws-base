#!/bin/bash
#######################################
# Description: AWS-specific utility functions for shell scripts
# Usage: source /path/to/scripts/lib/aws.sh
#
# This library provides AWS-related functions:
# - JSON parsing with jq
# - AWS CLI wrapper functions
# - Resource ARN parsing utilities
# - AWS region and account utilities
# - AWS credentials validation (check_aws_credentials)
#######################################

# Ensure common.sh is loaded for logging functions
if ! declare -f log > /dev/null 2>&1; then
    # Try to source common.sh from the same directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=./common.sh
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/common.sh"
fi

#######################################
# aws_safe_exec: Safely execute AWS CLI command with error handling
#
# Description:
#   Executes AWS CLI commands with proper error handling and logging
#
# Arguments:
#   $@ - AWS CLI command and arguments
#
# Returns:
#   0 on success, 1 on error (outputs command result to stdout)
#
# Usage:
#   result=$(aws_safe_exec aws s3 ls)
#
#######################################
function aws_safe_exec {
    # This function accepts either a single string command or an array-style command
    # Usage: aws_safe_exec "aws s3 ls --region us-east-1"
    #    or: aws_safe_exec aws s3 ls --region us-east-1
    local output
    local exit_code

    if [[ $# -eq 0 ]]; then
        log "ERROR" "aws_safe_exec: no command provided" >&2
        return 1
    fi

    # If more than one argument, execute safely as an array to avoid word-splitting
    if [[ $# -gt 1 ]]; then
        log "DEBUG" "Executing AWS CLI: $*" >&2
        if output=$("${@}" 2>&1); then
            echo "$output"
            return 0
        else
            exit_code=$?
            log "ERROR" "AWS CLI command failed (exit code: $exit_code): $*" >&2
            log "ERROR" "Output: $output" >&2
            return $exit_code
        fi
    fi

    # Single-string command: run under bash -c (keeps backward compatibility)
    local cmd_string="$1"
    log "DEBUG" "Executing AWS CLI (shell): $cmd_string" >&2
    if output=$(bash -c "$cmd_string" 2>&1); then
        echo "$output"
        return 0
    else
        exit_code=$?
        log "ERROR" "AWS CLI command failed (exit code: $exit_code): $cmd_string" >&2
        log "ERROR" "Output: $output" >&2
        return $exit_code
    fi
}

#######################################
# aws_retry_exec: Execute AWS CLI with retry/backoff
#
# Description:
#   Executes AWS CLI commands with automatic retry and exponential backoff
#
# Arguments:
#   $1 - max retries (optional, defaults to 3)
#   $@ - AWS CLI command and arguments
#
# Returns:
#   0 on success, non-zero on final failure (outputs command result to stdout)
#
# Usage:
#   result=$(aws_retry_exec aws s3 ls)
#
#######################################
function aws_retry_exec {
    # aws_retry_exec [max_retries] <cmd...>
    # If first argument is a positive integer, treat it as max_retries.
    local max_retries=3
    if [[ $# -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
        max_retries="$1"
        shift
    fi

    local cmd=("$@")
    local attempt=1
    local delay=2
    local output
    local rc

    while true; do
        log "DEBUG" "aws_retry_exec attempt $attempt cmd: ${cmd[*]}" >&2
        if output=$("${cmd[@]}" 2>&1); then
            echo "$output"
            return 0
        fi

        rc=$?
        # Detect common non-retryable client errors from AWS CLI output and abort retries.
        # AWS CLI often prints: "An error occurred (ErrorName) when calling the OperationName operation: message"
        # Try to extract the ErrorName via text parsing first, then fall back to JSON Error.Code.
        local non_retryable_error
        non_retryable_error=$(echo "$output" | sed -n 's/.*An error occurred (\([^)]*\)).*/\1/p' 2> /dev/null || true)
        if [[ -z "$non_retryable_error" ]]; then
            non_retryable_error=$(echo "$output" | jq -r '.Error.Code // empty' 2> /dev/null || true)
        fi
        if [[ -n "$non_retryable_error" ]]; then
            case "$non_retryable_error" in
                AccessDenied* | UnauthorizedOperation | Unauthorized* | Validation* | InvalidParameter* | InvalidArgument* | MissingParameter* | BadRequest* | ResourceNotFound* | NoSuchKey | NotFound*)
                    log "ERROR" "aws_retry_exec: non-retryable error detected ($non_retryable_error). Aborting: ${cmd[*]}" >&2
                    log "ERROR" "Output: $output" >&2
                    return $rc
                    ;;
            esac
        fi
        if ((attempt >= max_retries)); then
            log "ERROR" "aws_retry_exec failed after $attempt attempts (exit: $rc): ${cmd[*]}" >&2
            log "ERROR" "Output: $output" >&2
            return $rc
        fi

        log "WARN" "aws_retry_exec: attempt $attempt/$max_retries failed (exit: $rc). Retrying in ${delay}s: ${cmd[*]}" >&2
        sleep $delay
        attempt=$((attempt + 1))
        delay=$((delay * 2))
    done
}

#######################################
# aws_paginate_items: Paginate AWS list calls
#
# Description:
#   Handles pagination for AWS CLI list operations that use NextToken
#
# Arguments:
#   $1 - jq array key for extracting items
#   $@ - AWS CLI command and arguments
#
# Returns:
#   None (outputs each JSON array item line-by-line to stdout)
#
# Usage:
#   aws_paginate_items 'UserPools' aws cognito-idp list-user-pools --region us-east-1
#
#######################################
function aws_paginate_items {
    local jq_key="$1"
    shift
    local cmd_args=("$@")
    local max_results=60
    local next_token=""
    local out
    # Default preference: try --max-results (Cognito) first, fall back to --max-items
    local use_max_results=1

    while true; do
        # Try preferring --max-results; fall back to --max-items if unsupported
        if [[ ${cmd_args[1]:-} == "dynamodb" && ("${cmd_args[2]:-}" == "list-tables" || "${cmd_args[2]:-}" == "list-global-tables") ]]; then
            # Special-case DynamoDB pagination which uses ExclusiveStartTableName/ExclusiveStartGlobalTableName and
            # returns LastEvaluatedTableName/LastEvaluatedGlobalTableName. We handle both list-tables and list-global-tables.
            local start_param
            local last_eval_key
            if [[ "${cmd_args[2]}" == "list-global-tables" ]]; then
                start_param="--exclusive-start-global-table-name"
                last_eval_key='.LastEvaluatedGlobalTableName'
            else
                start_param="--exclusive-start-table-name"
                last_eval_key='.LastEvaluatedTableName'
            fi

            if [[ -n "$next_token" ]]; then
                out=$(aws_retry_exec "${cmd_args[@]}" "$start_param" "$next_token" --output json 2> /dev/null || echo '{}')
            else
                out=$(aws_retry_exec "${cmd_args[@]}" --output json 2> /dev/null || echo '{}')
            fi

            # Print each array item (if present) as a compact JSON object line
            if [[ -n "$out" ]]; then
                echo "$out" | jq -c ".${jq_key}[]?" 2> /dev/null || true
            fi

            next_token="$(echo "$out" | jq -r "$last_eval_key // empty" 2> /dev/null || true)"
            if [[ -z "$next_token" ]]; then
                break
            fi
            continue
        fi

        # Special-case S3 list-objects-v2 which uses ContinuationToken
        if [[ ${cmd_args[1]:-} == "s3api" && "${cmd_args[2]:-}" == "list-objects-v2" ]]; then
            if [[ -n "$next_token" ]]; then
                out=$(aws_retry_exec "${cmd_args[@]}" --continuation-token "$next_token" --output json 2> /dev/null || echo '{}')
            else
                out=$(aws_retry_exec "${cmd_args[@]}" --output json 2> /dev/null || echo '{}')
            fi

            if [[ -n "$out" ]]; then
                echo "$out" | jq -c ".${jq_key}[]?" 2> /dev/null || true
            fi

            next_token="$(echo "$out" | jq -r '.NextContinuationToken // empty' 2> /dev/null || true)"
            if [[ -z "$next_token" ]]; then
                break
            fi
            continue
        fi

        if [[ $use_max_results -eq 1 ]]; then
            if [[ -n "$next_token" ]]; then
                out=$(aws_retry_exec 1 "${cmd_args[@]}" --max-results "$max_results" --next-token "$next_token" --output json 2> /dev/null || echo '{}')
            else
                out=$(aws_retry_exec 1 "${cmd_args[@]}" --max-results "$max_results" --output json 2> /dev/null || echo '{}')
            fi
            # If call failed and produced no JSON, try --max-items in the next pass
            if [[ -z "$out" || "$out" == "{}" ]]; then
                use_max_results=0
                if [[ -n "$next_token" ]]; then
                    out=$(aws_retry_exec 1 "${cmd_args[@]}" --max-items "$max_results" --starting-token "$next_token" --output json 2> /dev/null || echo '{}')
                else
                    out=$(aws_retry_exec 1 "${cmd_args[@]}" --max-items "$max_results" --output json 2> /dev/null || echo '{}')
                fi
            fi
        else
            if [[ -n "$next_token" ]]; then
                out=$(aws_retry_exec 1 "${cmd_args[@]}" --max-items "$max_results" --starting-token "$next_token" --output json 2> /dev/null || echo '{}')
            else
                out=$(aws_retry_exec 1 "${cmd_args[@]}" --max-items "$max_results" --output json 2> /dev/null || echo '{}')
            fi
        fi

        # Print each array item (if present) as a compact JSON object line
        if [[ -n "$out" ]]; then
            echo "$out" | jq -c ".${jq_key}[]?" 2> /dev/null || true
        fi

        # Use common token names used by AWS (NextToken, NextMarker, NextContinuationToken)
        next_token="$(echo "$out" | jq -r '.NextToken // .NextMarker // .NextContinuationToken // empty' 2> /dev/null || true)"
        if [[ -z "$next_token" ]]; then
            break
        fi
    done

}

#######################################
# check_aws_credentials: Check AWS CLI credentials and identity
#
# Description:
#   Validates AWS credentials by attempting to get caller identity
#
# Arguments:
#   None
#
# Returns:
#   0 if credentials are valid, 1 if invalid
#
# Usage:
#   check_aws_credentials
#
#######################################
function check_aws_credentials {
    local identity
    identity=$(aws sts get-caller-identity --query 'Arn' --output text 2> /dev/null)
    if [[ -z "$identity" || "$identity" == "null" ]]; then
        log "ERROR" "AWS credentials are not set or invalid."
        return 1
    fi
    log "INFO" "AWS identity: $identity"
    return 0
}

#######################################
# extract_jq_array: Extract array values using jq
#
# Description:
#   Extracts array values from JSON using jq and joins them with a separator
#
# Arguments:
#   $1 - JSON data
#   $2 - jq query for array
#   $3 - default value (optional, defaults to "N/A")
#   $4 - separator (optional, defaults to ",")
#
# Returns:
#   Comma-separated values or custom separator-separated values (to stdout)
#
# Usage:
#   result=$(extract_jq_array "$json" ".items[]")
#
#######################################
function extract_jq_array {
    local json_data="$1"
    local jq_query="$2"
    local default_value="${3:-N/A}"
    local separator="${4:-,}"

    # Handle empty JSON data
    if [[ -z "$json_data" || "$json_data" == "null" ]]; then
        echo "$default_value"
        return 0
    fi

    # Execute jq query to get array and join with separator
    local result
    if result=$(echo "$json_data" | jq -r "${jq_query} | if type == \"array\" then join(\"${separator}\") else . end" 2> /dev/null); then
        # Handle null, empty, or array results
        if [[ -z "$result" || "$result" == "null" || "$result" == "[]" ]]; then
            echo "$default_value"
        else
            # For comma separator, wrap result in double quotes for CSV compatibility
            if [[ "$separator" == "," ]]; then
                echo "\"$result\""
            else
                echo "$result"
            fi
        fi
    else
        log "DEBUG" "jq array query failed: $jq_query"
        echo "$default_value"
    fi
}

#######################################
# extract_jq_value: Extract value using jq
#
# Description:
#   Extracts a single value from JSON using jq with default value support
#
# Arguments:
#   $1 - JSON data
#   $2 - jq query
#   $3 - default value (optional, defaults to "N/A")
#
# Returns:
#   Extracted value or default (to stdout)
#
# Usage:
#   result=$(extract_jq_value "$json" ".name")
#
#######################################
function extract_jq_value {
    local json_data="$1"
    local jq_query="$2"
    local default_value="${3:-N/A}"

    # Handle empty JSON data
    if [[ -z "$json_data" || "$json_data" == "null" ]]; then
        echo "$default_value"
        return 0
    fi

    # Execute jq query and handle errors
    local result
    if result=$(echo "$json_data" | jq -r "$jq_query" 2> /dev/null); then
        # Handle null or empty results
        if [[ -z "$result" || "$result" == "null" ]]; then
            echo "$default_value"
        else
            echo "$result"
        fi
    else
        log "DEBUG" "jq query failed: $jq_query"
        echo "$default_value"
    fi
}

#######################################
# format_aws_timestamp: Convert Unix timestamp to readable date
#
# Description:
#   Converts Unix timestamp (seconds or milliseconds) to human-readable date format
#
# Arguments:
#   $1 - Unix timestamp (seconds or milliseconds)
#
# Returns:
#   Formatted date string (YYYY-MM-DD HH:MM:SS) or "N/A" (to stdout)
#
# Usage:
#   date=$(format_aws_timestamp 1640995200)
#
#######################################
function format_aws_timestamp {
    local timestamp="$1"

    # Handle empty or non-numeric input
    if [[ ! "$timestamp" =~ ^[0-9]+$ ]]; then
        echo "N/A"
        return 0
    fi

    # Convert milliseconds to seconds if needed
    if [[ ${#timestamp} -gt 10 ]]; then
        timestamp=$((timestamp / 1000))
    fi

    # Format timestamp
    if date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S' 2> /dev/null; then
        return 0
    else
        echo "N/A"
        return 1
    fi
}

#######################################
# get_aws_account_id: Get AWS account ID
#
# Description:
#   Retrieves the current AWS account ID from caller identity
#
# Arguments:
#   None
#
# Returns:
#   AWS account ID (to stdout) or exits on error
#
# Usage:
#   account_id=$(get_aws_account_id)
#
#######################################
function get_aws_account_id {
    local account_id
    if ! account_id=$(aws sts get-caller-identity --query Account --output text 2> /dev/null); then
        log "ERROR" "Failed to get AWS account ID. Check AWS credentials."
        return 1
    fi
    echo "$account_id"
    return 0
}

#######################################
# get_aws_region: Get current AWS region
#
# Description:
#   Determines the current AWS region from configuration or instance metadata
#
# Arguments:
#   None
#
# Returns:
#   Current AWS region (to stdout) or exits on error
#
# Usage:
#   region=$(get_aws_region)
#
#######################################
function get_aws_region {
    local region
    local region_from_aws
    # aws configure get region returns empty string (exit 0) when not set, so capture value and test
    region_from_aws=$(aws configure get region 2> /dev/null || true)
    if [[ -n "$region_from_aws" ]]; then
        echo "$region_from_aws"
        return 0
    fi

    # Try to get from instance metadata if running on EC2
    local region_from_meta
    region_from_meta=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/region 2> /dev/null || true)
    if [[ -n "$region_from_meta" ]]; then
        echo "$region_from_meta"
        return 0
    fi

    error_exit "Failed to determine AWS region. Set AWS_DEFAULT_REGION or configure AWS CLI."
}

#######################################
# get_kms_name: Resolve KMS Key ARN/ID to alias/name
#
# Description:
#   Resolves a KMS Key ARN or Key ID to a human-friendly alias/name
#
# Arguments:
#   $1 - KMS Key ARN or Key ID
#   $2 - AWS region (optional, defaults to current region)
#
# Returns:
#   KMS alias/name or original input (to stdout)
#
# Usage:
#   name=$(get_kms_name "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012")
#
#######################################
function get_kms_name {
    local kms_identifier="$1"
    local region="${2:-$(get_aws_region)}"

    if [[ -z "$kms_identifier" || "$kms_identifier" == "N/A" ]]; then
        echo "N/A"
        return 1
    fi

    # If this is an alias ARN (arn:aws:kms:...:alias/...), just return the alias part
    if [[ "$kms_identifier" == *":alias/"* ]]; then
        echo "${kms_identifier##*:}"
        return 0
    fi

    # If this is a key ARN (arn:aws:kms:...:key/<id>), extract the key id
    local key_id="$kms_identifier"
    if [[ "$kms_identifier" == arn:aws:kms:*:*:key/* ]]; then
        key_id="${kms_identifier##*/}"
    fi

    # Try to describe the key to verify it exists (and obtain the canonical KeyId)
    local key_meta
    key_meta=$(aws_safe_exec "aws kms describe-key --key-id '$key_id' --region '$region' --output json" 2> /dev/null || echo '{}')
    if [[ "$key_meta" != "{}" ]]; then
        key_id=$(echo "$key_meta" | jq -r '.KeyMetadata.KeyId' 2> /dev/null || echo "$key_id")
    fi

    # Try to find an alias for the key
    local aliases_out alias_name
    # Use aws_paginate_items to reliably handle pagination and transient errors
    aliases_out=$(aws_paginate_items 'Aliases' aws kms list-aliases --key-id "$key_id" --region "$region" 2> /dev/null | jq -s '{Aliases: .}' 2> /dev/null || echo '{}')
    alias_name=$(echo "$aliases_out" | jq -r '.Aliases[]?.AliasName' 2> /dev/null | head -n1 || true)
    if [[ -n "$alias_name" && "$alias_name" != "null" ]]; then
        echo "$alias_name"
        return 0
    fi

    # As a last resort, return the KeyId or the original identifier
    if [[ -n "$key_id" ]]; then
        echo "$key_id"
        return 0
    fi

    echo "$kms_identifier"
    return 1
}

#######################################
# get_security_group_name: Resolve Security Group ID to name
#
# Description:
#   Resolves a Security Group ID to a human-friendly name using tags
#
# Arguments:
#   $1 - Security Group ID
#   $2 - AWS region (optional, defaults to current region)
#
# Returns:
#   Security Group name or original ID (to stdout)
#
# Usage:
#   name=$(get_security_group_name "sg-0123456789abcdef0")
#
#######################################
function get_security_group_name {
    local sg_id="$1"
    local region="${2:-$(get_aws_region)}"

    if [[ -z "$sg_id" ]]; then
        echo "N/A"
        return 1
    fi

    # Only attempt to resolve well-formed SG IDs
    if [[ ! "$sg_id" =~ ^sg-[0-9a-fA-F]+$ ]]; then
        # Not an SG id; return as-is
        echo "$sg_id"
        return 0
    fi

    local cmd out
    cmd=(aws ec2 describe-security-groups --group-ids "$sg_id" --region "$region" --output json)
    if out=$(aws_safe_exec "${cmd[*]}" 2> /dev/null); then
        # Prefer Tag 'Name' if present, otherwise GroupName
        local sg_name
        # Prefer Tag 'Name' if present (case-insensitive), otherwise GroupName
        sg_name=$(echo "$out" | jq -r '.SecurityGroups[0] | (.Tags[]? | select(.Key|ascii_downcase=="name") | .Value) // .GroupName // ""' 2> /dev/null || true)
        if [[ -n "$sg_name" ]]; then
            echo "$sg_name"
            return 0
        fi
        # Fallback to returning the ID
        echo "$sg_id"
        return 0
    else
        # If AWS call failed, return the ID to avoid breaking consumers
        echo "$sg_id"
        return 1
    fi
}

#######################################
# get_subnet_name: Resolve Subnet ID to name
#
# Description:
#   Resolves a Subnet ID to a human-friendly name using tags
#
# Arguments:
#   $1 - Subnet ID
#   $2 - AWS region (optional, defaults to current region)
#
# Returns:
#   Subnet name or original ID (to stdout)
#
# Usage:
#   name=$(get_subnet_name "subnet-0123456789abcdef0")
#
#######################################
function get_subnet_name {
    local subnet_id="$1"
    local region="${2:-$(get_aws_region)}"

    if [[ -z "$subnet_id" ]]; then
        echo "N/A"
        return 1
    fi

    # Only attempt to resolve well-formed Subnet IDs
    if [[ ! "$subnet_id" =~ ^subnet-[0-9a-fA-F]+$ ]]; then
        # Not a Subnet id; return as-is
        echo "$subnet_id"
        return 0
    fi

    local cmd out
    cmd=(aws ec2 describe-subnets --subnet-ids "$subnet_id" --region "$region" --output json)
    if out=$(aws_safe_exec "${cmd[*]}" 2> /dev/null); then
        # Prefer Tag 'Name' if present (case-insensitive), otherwise fall back to SubnetId
        # Some tools/taggers may use 'name' or different casings, so use ascii_downcase
        local subnet_name
        subnet_name=$(echo "$out" | jq -r '.Subnets[0] | (.Tags[]? | select(.Key|ascii_downcase=="name") | .Value) // .SubnetId // ""' 2> /dev/null || true)
        if [[ -n "$subnet_name" ]]; then
            echo "$subnet_name"
            return 0
        fi
        # Fallback to returning the ID
        echo "$subnet_id"
        return 0
    else
        # If AWS call failed, return the ID to avoid breaking consumers
        echo "$subnet_id"
        return 1
    fi
}

#######################################
# get_resource_name_from_arn: Get resource name from ARN
#
# Description:
#   Extracts the resource name from an AWS ARN
#
# Arguments:
#   $1 - AWS ARN
#
# Returns:
#   Resource name (to stdout) or exits on error
#
# Usage:
#   name=$(get_resource_name_from_arn "arn:aws:s3:::my-bucket")
#
#######################################
function get_resource_name_from_arn {
    local arn="$1"
    local resource_part

    if ! resource_part=$(parse_arn "$arn" | jq -r '.resource'); then
        return 1
    fi

    # Handle different resource formats
    if [[ "$resource_part" == */* ]]; then
        # Format: resource-type/resource-name
        echo "${resource_part##*/}"
    elif [[ "$resource_part" == *:* ]]; then
        # Format: resource-type:resource-name
        echo "${resource_part##*:}"
    else
        # Simple resource name
        echo "$resource_part"
    fi
}

#######################################
# get_vpc_name: Resolve VPC ID to name
#
# Description:
#   Resolves a VPC ID to a human-friendly name using tags
#
# Arguments:
#   $1 - VPC ID
#   $2 - AWS region (optional, defaults to current region)
#
# Returns:
#   VPC name or original ID (to stdout)
#
# Usage:
#   name=$(get_vpc_name "vpc-0123456789abcdef0")
#
#######################################
function get_vpc_name {
    local vpc_id="$1"
    local region="${2:-$(get_aws_region)}"

    if [[ -z "$vpc_id" ]]; then
        echo "N/A"
        return 1
    fi

    # Only attempt to resolve well-formed VPC IDs
    if [[ ! "$vpc_id" =~ ^vpc-[0-9a-fA-F]+$ ]]; then
        # Not a VPC id; return as-is
        echo "$vpc_id"
        return 0
    fi

    local cmd out
    cmd=(aws ec2 describe-vpcs --vpc-ids "$vpc_id" --region "$region" --output json)
    if out=$(aws_safe_exec "${cmd[*]}" 2> /dev/null); then
        # Prefer Tag 'Name' if present (case-insensitive), otherwise fall back to VpcId
        # The Name tag sometimes uses different casings (e.g. "name"), so use ascii_downcase
        local vpc_name
        vpc_name=$(echo "$out" | jq -r '.Vpcs[0] | (.Tags[]? | select(.Key|ascii_downcase=="name") | .Value) // .VpcId // ""' 2> /dev/null || true)
        if [[ -n "$vpc_name" ]]; then
            echo "$vpc_name"
            return 0
        fi
        # Fallback to returning the ID
        echo "$vpc_id"
        return 0
    else
        # If AWS call failed, return the ID to avoid breaking consumers
        echo "$vpc_id"
        return 1
    fi
}

#######################################
# get_waf_association: Get WAF association for a resource
#
# Description:
#   Retrieves the WAF Web ACL ARN associated with a resource
#
# Arguments:
#   $1 - Resource ARN
#   $2 - AWS region
#
# Returns:
#   WAF Web ACL ARN or "N/A" (to stdout)
#
# Usage:
#   waf_arn=$(get_waf_association "arn:aws:cloudfront::123456789012:distribution/ABC123" "us-east-1")
#
#######################################
function get_waf_association {
    local resource_arn="$1"
    local region="$2"

    # Try WAFv2 first, then WAF Classic
    local waf_result
    waf_result=$(aws wafv2 get-web-acl-for-resource --resource-arn "$resource_arn" --region "$region" 2> /dev/null || echo '{}')

    extract_jq_value "$waf_result" '.WebACL.ARN'
}

#######################################
# get_waf_name: Resolve WAF WebACL ARN to name
#
# Description:
#   Resolves a WAFv2 WebACL ARN to its human-friendly Name
#
# Arguments:
#   $1 - WAF WebACL ARN
#   $2 - AWS region (optional, defaults to current region)
#
# Returns:
#   WebACL Name or ARN (to stdout)
#
# Usage:
#   name=$(get_waf_name "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/MyWebACL/uuid")
#
#######################################
function get_waf_name {
    local waf_arn="$1"
    local region="${2:-$(get_aws_region)}"

    if [[ -z "$waf_arn" || "$waf_arn" == "N/A" ]]; then
        echo "N/A"
        return 1
    fi

    # Try to extract the name directly from ARN: /webacl/<name>/...
    local waf_name
    waf_name=$(echo "$waf_arn" | sed -n 's#.*/webacl/\([^/]*\)/.*#\1#p' || true)
    if [[ -n "$waf_name" ]]; then
        echo "$waf_name"
        return 0
    fi

    # Fallback: query list-web-acls for REGIONAL and CLOUDFRONT scopes and match ARN
    for scope in REGIONAL CLOUDFRONT; do
        local out
        # WAF CLOUDFRONT scope is global and should be queried in us-east-1 for reliability
        local list_region
        if [[ "$scope" == "CLOUDFRONT" ]]; then
            list_region="us-east-1"
        else
            list_region="$region"
        fi

        out=$(aws wafv2 list-web-acls --scope "$scope" --region "$list_region" --output json 2> /dev/null || echo '{}')
        waf_name=$(echo "$out" | jq -r --arg arn "$waf_arn" '.WebACLs[]? | select(.ARN==$arn) | .Name' 2> /dev/null || true)
        if [[ -n "$waf_name" && "$waf_name" != "null" ]]; then
            echo "$waf_name"
            return 0
        fi
    done

    # As a last resort, return the ARN so callers have something to show
    echo "$waf_arn"
    return 1
}

#######################################
# is_service_available_in_region: Check if AWS service is available in region
#
# Description:
#   Checks if a specific AWS service is available in the given region
#
# Arguments:
#   $1 - AWS service name
#   $2 - AWS region (optional, defaults to current region)
#
# Returns:
#   0 if service is available, 1 if not
#
# Usage:
#   if is_service_available_in_region "lambda" "us-west-2"; then echo "Available"; fi
#
#######################################
function is_service_available_in_region {
    local service="$1"
    local region="${2:-$(get_aws_region)}"

    # Some services are global
    case "$service" in
        iam | cloudfront | route53 | waf)
            return 0
            ;;
    esac

    # Check if service is available in region by attempting to list resources
    case "$service" in
        ec2)
            # Check that the region exists in the aws ec2 describe-regions output
            if aws ec2 describe-regions --output json 2> /dev/null | jq -r '.Regions[].RegionName' 2> /dev/null | grep -qx "$region"; then
                return 0
            else
                return 1
            fi
            ;;
        s3)
            # S3 is global but we can attempt a head-bucket call is not appropriate here; assume S3 generally available
            return 0
            ;;
        lambda)
            # Try a lightweight call to list-functions in the target region
            if aws lambda list-functions --region "$region" --max-items 1 > /dev/null 2>&1; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            # Generic check - try to call a basic list operation
            log "DEBUG" "Service availability check not implemented for: $service"
            return 0
            ;;
    esac
}

#######################################
# parse_arn: Parse ARN components
#
# Description:
#   Parses an AWS ARN into its component parts
#
# Arguments:
#   $1 - AWS ARN
#
# Returns:
#   JSON object with ARN components (to stdout) or exits on error
#
# Usage:
#   components=$(parse_arn "arn:aws:s3:::my-bucket")
#
#######################################
function parse_arn {
    local arn="$1"

    # Validate ARN format
    if [[ ! "$arn" =~ ^arn:aws[^:]*:[^:]*:[^:]*:[^:]*:.+ ]]; then
        log "ERROR" "Invalid ARN format: $arn"
        return 1
    fi

    # Split ARN into components
    IFS=':' read -ra ARN_PARTS <<< "$arn"

    # Create JSON object
    jq -n \
        --arg partition "${ARN_PARTS[1]}" \
        --arg service "${ARN_PARTS[2]}" \
        --arg region "${ARN_PARTS[3]}" \
        --arg account "${ARN_PARTS[4]}" \
        --arg resource "${ARN_PARTS[5]}" \
        '{
            partition: $partition,
            service: $service,
            region: $region,
            account: $account,
            resource: $resource
        }'
}

#######################################
# validate_aws_config: Validate AWS CLI configuration
#
# Description:
#   Validates that AWS CLI is properly configured and accessible
#
# Arguments:
#   None
#
# Returns:
#   None (exits on validation failure)
#
# Usage:
#   validate_aws_config
#
#######################################
function validate_aws_config {
    validate_dependencies "aws" "jq"

    # Test AWS CLI access
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        error_exit "AWS CLI is not properly configured. Run 'aws configure' or set AWS credentials."
    fi

    log "INFO" "AWS CLI configuration validated"
}
