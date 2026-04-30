#!/bin/bash
#######################################
# Description: Deploy Lambda functions using AWS SAM
#
# Usage: ./aws_deploy_sam.sh [options] [action]
#   actions:
#     deploy   Deploy Lambda stack via SAM (default)
#     delete   Delete Lambda stack
#     validate Validate SAM template
#   options:
#     -h, --help             Display this help message
#     -e, --env ENV          Target environment: dev, qa, stg, prd (default: dev)
#     -p, --path PATH        Path to Lambda project directory (required)
#     -r, --region REGION    AWS region (default: auto-detected via aws configure get region)
#
# Output:
# - Lambda deployment status to stdout
# - Exit code 0 on success, non-zero on failure
#
# Design Rules:
# - Uses AWS SAM CLI for Lambda deployment
# - Validates AWS credentials and region before deployment
# - Supports deploy, delete, and validate actions
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
ACTION="deploy"
AWS_REGION="${AWS_REGION:-}"
ENV="dev"
LAMBDA_PATH=""

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including actions, options, and examples
#
# Arguments:
#   None
#
# Returns:
#   None (outputs to stdout, then exits with status 0)
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options] [action]

Description: Deploy Lambda functions using AWS SAM

Actions:
  deploy   Deploy Lambda stack via SAM (default)
  delete   Delete Lambda stack
  validate Validate SAM template

Options:
  -h, --help             Display this help message
  -e, --env ENV          Target environment: dev, qa, stg, prd (default: dev)
  -p, --path PATH        Path to Lambda project directory (required)
  -r, --region REGION    AWS region (default: auto-detected via aws configure)

Examples:
  $(basename "$0") -p lambda
  $(basename "$0") -p lambda -e prd deploy
  $(basename "$0") --path lambda --env dev validate
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and validates required options
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   ACTION      - Set to the provided action (deploy, validate, delete)
#   AWS_REGION  - Set to the provided AWS region
#   ENV         - Set to the provided target environment
#   LAMBDA_PATH - Set to the provided Lambda project directory path
#
# Returns:
#   Exits with error if required options are missing or unknown arguments are given
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
            -e | --env)
                ENV="$2"
                shift 2
                ;;
            -p | --path)
                LAMBDA_PATH="$2"
                shift 2
                ;;
            -r | --region)
                AWS_REGION="$2"
                shift 2
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            deploy | delete | validate)
                ACTION="$1"
                shift
                ;;
            *)
                error_exit "Unexpected argument: $1"
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "${LAMBDA_PATH}" ]]; then
        echo "Error: --path is required" >&2
        show_usage
    fi
}

#######################################
# main: Main process
#
# Description:
#   Main function to execute the Lambda deployment workflow
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   ACTION      - Action to perform (deploy, validate, delete)
#   AWS_REGION  - AWS region
#   ENV         - Target environment name
#   LAMBDA_PATH - Path to Lambda project directory
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # Validate required dependencies
    validate_dependencies "aws" "sam"

    # Check AWS credentials before any AWS CLI usage
    check_aws_credentials || error_exit "AWS credentials are not set or invalid."

    # Auto-detect AWS_REGION from AWS CLI if not provided
    AWS_REGION="${AWS_REGION:-$(get_aws_region)}"

    # Resolve Lambda path to absolute path
    local abs_path
    abs_path="$(cd "${LAMBDA_PATH}" 2> /dev/null && pwd)" \
        || error_exit "Lambda path does not exist: ${LAMBDA_PATH}"

    echo_section "${ACTION}: Lambda in ${abs_path} -> ${ENV}"
    log "INFO" "Region: ${AWS_REGION}"

    # Change to Lambda project directory so SAM can find samconfig.toml and templates
    cd "${abs_path}"

    case "$ACTION" in
        deploy)
            echo_section "Deploying Lambda stack"
            sam deploy --config-env "${ENV}"
            log "INFO" "Deployment completed"
            ;;
        delete)
            echo_section "Deleting Lambda stack"
            sam delete --config-env "${ENV}"
            log "INFO" "Delete completed"
            ;;
        validate)
            echo_section "Building Lambda binaries"
            "${SCRIPT_DIR}/../go/build.sh" cmd lambda arm64
            echo_section "Validating SAM template"
            sam validate --lint
            log "INFO" "Validate completed"
            ;;
        *)
            error_exit "Unknown action: ${ACTION}. Use: deploy, delete, validate"
            ;;
    esac

    echo_section "Process completed successfully"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
