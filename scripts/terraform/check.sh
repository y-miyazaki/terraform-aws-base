#!/bin/bash
#######################################
# Description: Recursive Terraform validation, linting, docs generation and security scanning script.
# Usage: ./check.sh [options] [dir1 dir2 ...]
#   options:
#     -h, --help    Display this help message
#   arguments:
#     dirN          One or more target directories to scope validation (optional)
# Design Rules:
#   - If no directories are given, scan entire workspace
#   - Directories are validated recursively for each main.tf found
#   - Follows common parse_arguments pattern used in other scripts
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

#--------------------------------------------------------------
# New: Target directories array (optional arguments)
#--------------------------------------------------------------
TARGET_DIRS=()

#######################################
# show_usage: Display script usage information
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
#   Exits with status 0 after displaying help
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    show_help_header "$(basename "$0")" "Recursive Terraform validation and checking" "[options] [dir1 dir2 ...]"
    echo "This script recursively checks Terraform modules."
    echo "If no directory arguments are provided it scans the entire workspace (/workspace)."
    echo "If one or more directories are provided, only those paths (recursively) are processed."
    echo ""
    echo "Examples:"
    echo "  $0                         # scan whole workspace"
    echo "  $0 modules/aws/security    # scan only that subtree"
    echo "  $0 modules/aws/vpc modules/aws/iam  # scan multiple targets"
    show_help_footer
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and collects target directories
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   TARGET_DIRS - Array of target directories to process
#
# Returns:
#   Exits with error if unknown options are provided
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
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Collect target directories
                TARGET_DIRS+=("$1")
                ;;
        esac
        shift
    done
}

#######################################
# check_optional_tools: Check optional tools availability
#
# Description:
#   Checks if optional tools (tflint, terraform-docs, trivy) are available
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Logs warnings for unavailable tools
#
# Usage:
#   check_optional_tools
#
#######################################
function check_optional_tools {
    local optional_tools=("tflint" "terraform-docs" "trivy")
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log "WARN" "$tool is not installed or not in PATH. Related features will be skipped."
        fi
    done
}

#######################################
# process_terraform_directory: Process single terraform directory
#
# Description:
#   Processes a single Terraform directory with validation, linting, and documentation generation
#
# Arguments:
#   $1 - Directory path to process
#
# Global Variables:
#   None
#
# Returns:
#   Exits with error if any validation step fails
#
# Usage:
#   process_terraform_directory "$dir"
#
#######################################
function process_terraform_directory {
    local dir="$1"

    echo_section "Processing directory: $dir"

    if [[ ! -d "$dir" ]]; then
        log "WARN" "Directory disappeared, skipping: $dir"
        return 0
    fi

    pushd "$dir" > /dev/null || error_exit "Failed to enter directory $dir"

    log "INFO" "Validating in directory: $(pwd)"

    # Step 1: Run tflint first (no init required)
    if command -v tflint &> /dev/null; then
        log "INFO" "Running tflint (pre-init check) in $(pwd)"
        if ! execute_command "tflint"; then
            error_exit "tflint found issues in $dir"
        fi
    fi

    # Step 2: Initialize Terraform (backend disabled for validation)
    log "INFO" "Initializing Terraform (backend disabled)"
    if ! execute_command "terraform init -backend=false"; then
        error_exit "Failed to initialize Terraform for $dir"
    fi

    # Step 3: Validate Terraform configuration
    log "INFO" "Validating Terraform configuration"
    terraform_validate

    # Step 4: Generate documentation (terraform-docs) if available
    if command -v terraform-docs &> /dev/null; then
        log "INFO" "Generating documentation (terraform-docs)"
        if ! execute_command "terraform-docs markdown --output-file README.md ./"; then
            error_exit "Failed to generate documentation for $dir"
        fi
    fi

    log "INFO" "Completed processing: $dir"
    popd > /dev/null || true
}

#######################################
# run_recursive_validation: Run recursive terraform validation
#
# Description:
#   Runs validation on all Terraform directories found, either scoped or full workspace
#
# Arguments:
#   None
#
# Global Variables:
#   TARGET_DIRS - Array of target directories (if scoped)
#
# Returns:
#   None
#
# Usage:
#   run_recursive_validation
#
#######################################
function run_recursive_validation {
    echo_section "Starting recursive Terraform validation"
    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        log "INFO" "Scoped mode: processing ${#TARGET_DIRS[@]} directories"
        for target in "${TARGET_DIRS[@]}"; do
            if [[ ! -d "$target" ]]; then
                log "WARN" "Skipping non-existent directory: $target"
                continue
            fi
            find "$target" ! -path '*/.terraform/*' -type f -name 'main.tf' -print0 | while IFS= read -r -d '' file; do
                local dir
                dir=$(dirname "$file")
                process_terraform_directory "$dir"
            done
        done
        return 0
    fi
    find /workspace/ ! -path '*/.terraform/*' -type f -name 'main.tf' -print0 | while IFS= read -r -d '' file; do
        local dir
        dir=$(dirname "$file")
        process_terraform_directory "$dir"
    done
}

#######################################
# run_security_scan: Run security scan
#
# Description:
#   Runs security scan using trivy if available
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Exits with error if security issues are found
#
# Usage:
#   run_security_scan
#
#######################################
function run_security_scan {
    # Run security scan with trivy
    if command -v trivy &> /dev/null; then
        echo_section "Running security scan with trivy"
        if ! execute_command "trivy fs . --format table"; then
            error_exit "trivy found security issues that must be addressed."
        fi
    else
        log "INFO" "Skipping trivy security scan (not installed)"
    fi
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the script logic for recursive Terraform validation
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   TARGET_DIRS - Array of target directories to process
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

    # Validate dependencies
    validate_dependencies "terraform"

    # Check optional tools
    check_optional_tools

    # Run recursive validation (scoped or full)
    run_recursive_validation

    # Run security scan (always from root)
    run_security_scan

    echo_section "Recursive Terraform check completed"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
