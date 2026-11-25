#!/bin/bash
#######################################
# Description: Terraform integration testing script (init, validate, plan, lint, security)
#
# Usage: ./integration.sh [directory]
#   arguments:
#     directory: Target directory (optional, defaults to current)
#
# Design Rules:
#   - ENV and TF_PLUGIN_CACHE_DIR are required environment variables.
#   - tflint and trivy findings are reported as warnings; the integration steps themselves fail the run.
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including required environment variables and examples
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Writes help to stdout
#
# Returns:
#   Exits with status 1
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [directory]

Description: Terraform integration testing (init, validate, plan)
             This script performs Terraform initialization, validation and planning for a directory.

Arguments:
  directory       Target directory (optional, defaults to current)

Required environment variables:
  TF_PLUGIN_CACHE_DIR     - Terraform plugin cache directory
  ENV                     - Environment (e.g., dev, staging, prod)

Examples:
  ENV=dev $0 ./terraform/base
  ENV=prod $0 ./terraform/application
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Writes help to stdout when -h or --help is given
#
# Returns:
#   0 on success; exits 0 after showing help
#######################################
function parse_arguments {
    case "${1:-}" in
        -h | --help)
            show_usage
            ;;
        -*)
            error_exit "Unknown option: $1"
            ;;
    esac
}

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
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
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
        # Plugins from .tflint.hcl must be installed first or the run fails on a clean runner
        if ! execute_command tflint --init; then
            log "WARN" "tflint --init failed; linting may be incomplete."
        fi
        log "INFO" "Running tflint with module support (--call-module-type=all)..."
        if ! execute_command tflint --call-module-type=all; then
            log "WARN" "tflint found issues that should be addressed."
        fi
    else
        log "WARN" "tflint not available, skipping linting"
    fi

    # Run trivy security scan
    if command -v trivy &> /dev/null; then
        log "INFO" "Running trivy security scan..."
        if ! execute_command trivy fs . --format table; then
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
# Globals:
#   ENV - Environment for workflow
#
# Arguments:
#   None
#
# Outputs:
#   None
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
# Globals:
#   ENV - Environment variable
#   TF_PLUGIN_CACHE_DIR - Terraform plugin cache directory
#
# Arguments:
#   $1 - Target directory path
#
# Outputs:
#   None
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
    require_dependencies "terraform" "tflint" "trivy"

    # Change to target directory
    if ! cd "$dir"; then
        error_exit "Failed to change to directory: $dir"
    fi

    log "INFO" "Starting Terraform integration testing in directory: $(pwd)"
}

#######################################
# main: Main process
#
# Description:
#   Main function to execute the script logic for Terraform integration testing
#
# Globals:
#   None
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
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
    parse_arguments "$@"

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
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
