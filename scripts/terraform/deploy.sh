#!/bin/bash
#######################################
# Description: Deploy Terraform configuration with validation and approval
# Usage: ./deploy.sh [directory]
#   directory       Target directory (optional, defaults to current)
#
# Required environment variables:
#   TF_PLUGIN_CACHE_DIR     - Terraform plugin cache directory
#   ENV                     - Environment (e.g., dev, staging, prod)
#
# Examples:
#   ENV=dev ./deploy.sh ./terraform/base
#   ENV=prod ./deploy.sh ./terraform/application
#
# Design Rules:
#   - Validates required environment variables before execution
#   - Uses terraform_workflow from common library for consistency
#   - Automatically approves deployment (use with caution)
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
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including required environment variables and examples
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Exits with status 1 after displaying help
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    show_help_header "$(basename "$0")" "Deploy Terraform configuration" "[directory]"
    echo "Arguments:"
    echo "  directory       Target directory (optional, defaults to current)"
    echo ""
    show_help_footer
    echo "Required environment variables:"
    echo "  TF_PLUGIN_CACHE_DIR     - Terraform plugin cache directory"
    echo "  ENV                     - Environment (e.g., dev, staging, prod)"
    echo ""
    echo "Examples:"
    echo "  ENV=dev $0 ./terraform/base"
    echo "  ENV=prod $0 ./terraform/application"
    exit 1
}

# Show usage if -h or --help is provided
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_usage
fi

#######################################
# run_terraform_deployment: Run terraform deployment
#
# Description:
#   Runs the complete Terraform workflow for deployment with auto-approval
#
# Arguments:
#   None
#
# Global Variables:
#   ENV - Environment for deployment
#
# Returns:
#   None
#
# Usage:
#   run_terraform_deployment
#
#######################################
function run_terraform_deployment {
    # Run complete Terraform workflow
    terraform_workflow "$ENV" "apply" "auto-approve"
}

#######################################
# validate_and_prepare: Validate environment and prepare
#
# Description:
#   Validates required environment variables and dependencies, then changes to target directory
#
# Arguments:
#   $1 - Target directory path
#
# Global Variables:
#   ENV - Environment variable
#   TF_PLUGIN_CACHE_DIR - Terraform plugin cache directory
#
# Returns:
#   Exits with error if validation fails or directory change fails
#
# Usage:
#   validate_and_prepare "$dir"
#
#######################################
function validate_and_prepare {
    local dir="$1"

    # Validate environment variables and dependencies
    validate_env_vars "ENV" "TF_PLUGIN_CACHE_DIR"
    validate_dependencies "terraform"

    # Change to target directory
    if ! cd "$dir"; then
        error_exit "Failed to change to directory: $dir"
    fi

    log "INFO" "Starting Terraform deployment in directory: $(pwd)"
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the script logic for Terraform deployment
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   None
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Set target directory
    local dir=${1:-./}

    # Validate environment and prepare
    validate_and_prepare "$dir"

    # Run terraform deployment
    run_terraform_deployment
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
