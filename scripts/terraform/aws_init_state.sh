#!/bin/bash
#######################################
# Description: Create an S3 bucket for Terraform remote state with secure defaults
# Usage: ./aws_init_state.sh -r {region} -b {bucket name} [-s]
#   options:
#     -b {bucket name}   S3 bucket name (required)
#     -r {region}        AWS region for S3 bucket (required)
#     -s                 Add random hash suffix to bucket name for uniqueness
#     -h                 Show help
# Design Rules:
#   - Idempotent: safe to re-run if bucket already exists
#   - Secure defaults: block public access, versioning, encryption, lifecycle
#   - Clear logging and error handling
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
IS_BUCKET_AUTO_HASH=0
BUCKET=""
REGION=""
AWS_ID=""

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Arguments:
#   $1 - Optional error message to display before help
#
# Global Variables:
#   None
#
# Returns:
#   Exits with status 0 after displaying help, or calls error_exit if error message provided
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    local error_msg="${1:-}"

    if [ -n "$error_msg" ]; then
        error_exit "$error_msg"
    fi

    show_help_header "$(basename "$0")" "Create S3 bucket for Terraform state management" "-r {region} -b {bucket name} [options]"
    echo "This script creates an S3 bucket for Terraform state management with proper security settings."
    echo "You can optionally add a random hash suffix to the bucket name for uniqueness."
    echo ""
    echo "Options:"
    echo "  -b {bucket name}          S3 bucket name"
    echo "  -r {region}               AWS region for S3 bucket"
    echo "  -s                        Add random hash suffix to bucket name"
    echo "  -h                        Show this help message"
    show_help_footer
    echo "Examples:"
    echo "  $(basename "$0") -r us-east-1 -b my-terraform-state"
    echo "  $(basename "$0") -r ap-northeast-1 -b terraform-state -s"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments using getopts and validates required parameters
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   BUCKET - Set to the provided bucket name
#   REGION - Set to the provided AWS region
#   IS_BUCKET_AUTO_HASH - Set to 1 if hash suffix is requested
#
# Returns:
#   Exits with error if required parameters are missing
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while getopts b:r:sh opt; do
        case $opt in
            b) BUCKET=$OPTARG ;;
            r) REGION=$OPTARG ;;
            s) IS_BUCKET_AUTO_HASH=1 ;;
            h) show_usage ;;
            \?) show_usage "Invalid option: -$OPTARG" ;;
        esac
    done

    # Validate required parameters
    if [ -z "${BUCKET}" ]; then
        show_usage "Bucket name (-b) is required"
    fi

    if [ -z "${REGION}" ]; then
        show_usage "Region (-r) is required"
    fi
}

#######################################
# apply_bucket_policy: Apply bucket policy for Terraform state
#
# Description:
#   Applies a bucket policy template to restrict access to Terraform state files
#
# Arguments:
#   None
#
# Global Variables:
#   SCRIPT_DIR - Script directory path
#   BUCKET - S3 bucket name
#   AWS_ID - AWS account ID
#
# Returns:
#   Exits with error if policy application fails
#
# Usage:
#   apply_bucket_policy
#
#######################################
function apply_bucket_policy {
    echo_section "Applying bucket policy"

    local policy_template="${SCRIPT_DIR}/files/aws_init_state/terraform_state_policy.template.json"

    if [ -f "${policy_template}" ]; then
        log "INFO" "Creating bucket policy from template"
        local policy
        policy=$(sed "s/BUCKET_NAME/${BUCKET}/g; s/AWS_ACCOUNT_ID/${AWS_ID}/g" "${policy_template}")

        if ! echo "$policy" | aws s3api put-bucket-policy --bucket "${BUCKET}" --policy file:///dev/stdin; then
            error_exit "Failed to apply bucket policy"
        fi

        log "INFO" "Bucket policy applied successfully"
    else
        log "WARN" "Policy template not found: ${policy_template}"
        log "WARN" "Skipping bucket policy application"
    fi
}

#######################################
# configure_bucket_security: Configure bucket security settings
#
# Description:
#   Configures security settings including public access block, versioning, encryption, and lifecycle
#
# Arguments:
#   None
#
# Global Variables:
#   BUCKET - S3 bucket name
#
# Returns:
#   Exits with error if any configuration fails
#
# Usage:
#   configure_bucket_security
#
#######################################
function configure_bucket_security {
    echo_section "Configuring bucket security settings"

    # Block public access
    log "INFO" "Setting public access block"
    if ! aws s3api put-public-access-block --bucket "${BUCKET}" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"; then
        error_exit "Failed to set public access block"
    fi

    # Enable versioning
    log "INFO" "Enabling bucket versioning"
    if ! aws s3api put-bucket-versioning --bucket "${BUCKET}" \
        --versioning-configuration Status=Enabled; then
        error_exit "Failed to enable versioning"
    fi

    # Configure default encryption
    log "INFO" "Setting default encryption"
    if ! aws s3api put-bucket-encryption --bucket "${BUCKET}" \
        --server-side-encryption-configuration '{
      "Rules": [
        {
          "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
          }
        }
      ]
    }'; then
        error_exit "Failed to set bucket encryption"
    fi

    # Configure lifecycle management
    log "INFO" "Setting lifecycle configuration"
    if ! aws s3api put-bucket-lifecycle-configuration --bucket "${BUCKET}" \
        --lifecycle-configuration '{
        "Rules": [
            {
                "ID": "default",
                "Status": "Enabled",
                "Filter": {
                    "Prefix": ""
                },
                "AbortIncompleteMultipartUpload": {
                    "DaysAfterInitiation": 7
                }
            }
        ]
    }'; then
        error_exit "Failed to set lifecycle configuration"
    fi
}

#######################################
# create_s3_bucket: Create S3 bucket with region handling
#
# Description:
#   Creates an S3 bucket, handling the special case for us-east-1 region
#
# Arguments:
#   None
#
# Global Variables:
#   BUCKET - S3 bucket name
#   REGION - AWS region
#
# Returns:
#   Continues execution even if bucket creation fails (may already exist)
#
# Usage:
#   create_s3_bucket
#
#######################################
function create_s3_bucket {
    echo_section "Creating S3 bucket: $BUCKET"
    local create_args=(--bucket "${BUCKET}")

    # us-east-1 does not accept explicit LocationConstraint
    if [ "${REGION}" != "us-east-1" ]; then
        create_args+=(--create-bucket-configuration "LocationConstraint=${REGION}")
    fi

    if ! aws s3api create-bucket "${create_args[@]}" 2> /dev/null; then
        log "WARN" "Bucket creation may have failed or bucket already exists. Proceeding with configuration."
    else
        log "INFO" "S3 bucket created successfully"
    fi
}

#######################################
# display_completion_summary: Display completion summary
#
# Description:
#   Displays a summary of the completed setup including Terraform backend configuration
#
# Arguments:
#   None
#
# Global Variables:
#   BUCKET - S3 bucket name
#   REGION - AWS region
#   AWS_ID - AWS account ID
#
# Returns:
#   Outputs completion information to stdout
#
# Usage:
#   display_completion_summary
#
#######################################
function display_completion_summary {
    echo_section "Setup Complete"
    echo "✅ Terraform state bucket configured successfully"
    echo ""
    echo "Bucket name:    ${BUCKET}"
    echo "AWS region:     ${REGION}"
    echo "AWS account:    ${AWS_ID}"
    echo ""
    echo "To use this state bucket in Terraform, add the following backend configuration:"
    echo ""
    cat << EOF
terraform {
  backend "s3" {
    bucket  = "${BUCKET}"
    key     = "path/to/terraform.tfstate"
    region  = "${REGION}"
    encrypt = true
  }
}
EOF
}

#######################################
# generate_bucket_name: Generate unique bucket name
#
# Description:
#   Appends a random hash suffix to the bucket name for uniqueness if requested
#
# Arguments:
#   None
#
# Global Variables:
#   IS_BUCKET_AUTO_HASH - Flag indicating if hash should be added
#   BUCKET - S3 bucket name (modified in place)
#
# Returns:
#   Modifies BUCKET variable if hash is requested
#
# Usage:
#   generate_bucket_name
#
#######################################
function generate_bucket_name {
    if [ $IS_BUCKET_AUTO_HASH -eq 1 ]; then
        echo_section "Generating unique bucket name"
        local random_hash
        random_hash=$(awk -v min=10000000 -v max=100000000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
        BUCKET="${BUCKET}-${random_hash}"
        log "INFO" "Generated bucket name: $BUCKET"
    fi
}

#######################################
# get_aws_account_info: Get AWS account information
#
# Description:
#   Retrieves the AWS account ID using the get_aws_account_id function
#
# Arguments:
#   None
#
# Global Variables:
#   AWS_ID - Set to the retrieved AWS account ID
#
# Returns:
#   Exits with error if account ID cannot be retrieved
#
# Usage:
#   get_aws_account_info
#
#######################################
function get_aws_account_info {
    echo_section "Retrieving AWS Account information"
    if ! AWS_ID=$(get_aws_account_id); then
        error_exit "Failed to retrieve AWS Account ID. Check your AWS credentials."
    fi
    log "INFO" "AWS Account ID: ${AWS_ID}"
}

#######################################
# verify_bucket_config: Verify bucket configuration
#
# Description:
#   Verifies the bucket configuration by checking location, versioning, and encryption
#
# Arguments:
#   None
#
# Global Variables:
#   BUCKET - S3 bucket name
#
# Returns:
#   Outputs verification information, logs warnings if checks fail
#
# Usage:
#   verify_bucket_config
#
#######################################
function verify_bucket_config {
    echo_section "Verifying bucket configuration"

    log "INFO" "Bucket location:"
    aws s3api get-bucket-location --bucket "${BUCKET}" || log "WARN" "Could not retrieve bucket location"

    log "INFO" "Bucket versioning:"
    aws s3api get-bucket-versioning --bucket "${BUCKET}" || log "WARN" "Could not retrieve versioning"

    log "INFO" "Bucket encryption:"
    aws s3api get-bucket-encryption --bucket "${BUCKET}" || log "WARN" "Could not retrieve encryption"
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the script logic for creating Terraform state bucket
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   BUCKET - S3 bucket name
#   REGION - AWS region
#   IS_BUCKET_AUTO_HASH - Flag for hash suffix
#   AWS_ID - AWS account ID
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse command line arguments
    parse_arguments "$@"

    # Validate dependencies
    validate_dependencies "aws" "jq"

    # Check AWS credentials before any AWS CLI usage
    if ! check_aws_credentials; then
        error_exit "AWS credentials are not set or invalid."
    fi

    # Generate unique bucket name if requested
    generate_bucket_name

    # Get AWS account information
    get_aws_account_info

    # Create S3 bucket
    create_s3_bucket

    # Configure bucket security settings
    configure_bucket_security

    # Verify bucket configuration
    verify_bucket_config

    # Apply bucket policy
    apply_bucket_policy

    # Display completion summary
    display_completion_summary
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
