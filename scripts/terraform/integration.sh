#!/bin/bash
#######################################
# Description: Terraform integration testing script (init, validate, plan, lint, security)
# Usage: ./integration.sh [directory]
#   directory: Target directory (optional, defaults to current)
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
    show_help_header "$(basename "$0")" "Terraform integration testing (init, validate, plan)" "[directory]"
    echo "This script performs Terraform initialization, validation and planning for a directory."
    echo ""
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
## Additional helper functions (alphabetical):
## run_additional_checks, run_terraform_workflow, validate_and_prepare
## Keep alphabetical order for helper functions
#######################################

#######################################
# run_additional_checks: Run additional linting and security checks
#
# Description:
#   Runs additional checks including tflint linting and trivy security scanning
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Logs warnings if issues are found but does not exit
#
# Usage:
#   run_additional_checks
#
#######################################
function run_additional_checks {
    echo_section "Additional Linting and Security Checks"

    # Run tflint if available
    if command -v tflint &> /dev/null; then
        log "INFO" "Running tflint with module support..."
        if ! execute_command "tflint --module"; then
            log "WARN" "tflint found issues that should be addressed."
        fi
    else
        log "WARN" "tflint not available, skipping linting"
    fi

    # Run trivy security scan
    if command -v trivy &> /dev/null; then
        log "INFO" "Running trivy security scan..."
        if ! execute_command "trivy fs . --format table"; then
            log "WARN" "trivy found security issues that should be addressed."
        fi
    else
        log "WARN" "trivy not available, skipping security scan"
    fi
}

#######################################
# run_terraform_workflow: Run terraform workflow
#
# Description:
#   Runs the Terraform workflow for planning (without applying changes)
#
# Arguments:
#   None
#
# Global Variables:
#   ENV - Environment for workflow
#
# Returns:
#   None
#
# Usage:
#   run_terraform_workflow
#
#######################################
function run_terraform_workflow {
    # Run Terraform workflow (plan only)
    terraform_workflow "$ENV" "plan"
}
#######################################
# validate_and_prepare: Validate environment and prepare
#
# Description:
#   Validates Terraform environment and dependencies, then changes to target directory
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

    # Validate environment and dependencies
    validate_terraform_env
    validate_dependencies "terraform" "tflint" "trivy"

    # Change to target directory
    if ! cd "$dir"; then
        error_exit "Failed to change to directory: $dir"
    fi

    log "INFO" "Starting Terraform integration testing in directory: $(pwd)"
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the script logic for Terraform integration testing
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

    # Run terraform workflow
    run_terraform_workflow

    # Run additional checks
    run_additional_checks

    echo_section "Integration testing completed"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
