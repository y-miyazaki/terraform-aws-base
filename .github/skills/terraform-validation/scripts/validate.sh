#!/bin/bash
#######################################
# Description: Recursive Terraform validation, formatting check, linting, docs generation and security scanning script.
#
# Usage: ./validate.sh [options] [dir1 dir2 ...]
#   options:
#     -h, --help           Display this help message
#     -v, --verbose        Enable verbose output
#     -d, --generate-docs  Generate README.md using terraform-docs (requires terraform-docs installed)
#     -f, --fix            Automatically fix formatting issues (terraform fmt)
#   arguments:
#     dirN                 One or more target directories to scope validation (optional)
# Design Rules:
#   - If no directories are given, scan entire workspace
#   - Directories are validated recursively for each main.tf found
#   - Uses terraform.sh library functions for consistency
#   - Runs tflint recursively before validation
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
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables and default values
#######################################
TARGET_DIRS=()
GENERATE_DOCS="false"
AUTO_FIX="false"
# shellcheck disable=SC2034
VERBOSE="false"
EXIT_CODE=0

# Flags for individual checks
TFLINT_FAILED=0
VALIDATE_FAILED=0
FMT_FAILED=0
SECURITY_FAILED=0
DOCS_FAILED=0

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
#   None (outputs to stdout)
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options] [dir1 dir2 ...]

Description: Recursive Terraform validation, formatting check, linting, and security scanning.
             If no directory arguments are provided it scans the entire workspace (/workspace).
             If one or more directories are provided, only those paths (recursively) are processed.

Options:
  -h, --help           Display this help message
  -v, --verbose        Enable verbose output
  -d, --generate-docs  Generate README.md using terraform-docs (requires terraform-docs installed)
  -f, --fix            Automatically fix formatting issues (terraform fmt)

Examples:
  $0                         # scan whole workspace
  $0 modules/aws/security    # scan only that subtree
  $0 modules/aws/vpc modules/aws/iam  # scan multiple targets
  $0 -d modules/aws/vpc      # scan and generate docs
EOF
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
            -v | --verbose)
                # shellcheck disable=SC2034
                VERBOSE="true"
                ;;
            -d | --generate-docs)
                GENERATE_DOCS="true"
                ;;
            -f | --fix)
                AUTO_FIX="true"
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
# run_tflint_check: Run tflint recursively
#
# Description:
#   Runs tflint recursively on all Terraform directories
#
# Arguments:
#   None
#
# Global Variables:
#   TARGET_DIRS - Array of target directories (if scoped)
#
# Returns:
#   Exits with error if tflint finds issues
#
# Usage:
#   run_tflint_check
#
#######################################
function run_tflint_check {
    echo_section "Running tflint (recursive)"

    local failed=0
    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        for target in "${TARGET_DIRS[@]}"; do
            if [[ -d "$target" ]]; then
                pushd "$target" > /dev/null || continue
                log "INFO" "Running tflint in: $target"
                if ! terraform_lint "recursive"; then
                    failed=1
                fi
                popd > /dev/null || true
            else
                log "WARN" "Skipping non-existent directory for tflint: $target"
            fi
        done
    else
        log "INFO" "Running tflint recursively in entire workspace"
        if ! terraform_lint "recursive"; then
            failed=1
        fi
    fi

    if [[ $failed -eq 1 ]]; then
        log "ERROR" "tflint found issues"
        TFLINT_FAILED=1
        EXIT_CODE=1
    else
        log "INFO" "tflint passed"
    fi
}

#######################################
# run_formatting_check: Run terraform fmt recursively
#
# Description:
#   Checks that all Terraform files are properly formatted using terraform fmt -recursive
#
# Arguments:
#   None
#
# Global Variables:
#   TARGET_DIRS - Array of target directories (if scoped)
#
# Returns:
#   Exits with error if formatting issues are found
#
# Usage:
#   run_formatting_check
#
#######################################
function run_formatting_check {
    if [[ "$AUTO_FIX" == "true" ]]; then
        echo_section "Auto-fixing Terraform formatting"
    else
        echo_section "Checking Terraform formatting"
    fi
    local failed=0

    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        for target in "${TARGET_DIRS[@]}"; do
            if [[ -d "$target" ]]; then
                pushd "$target" > /dev/null || continue
                if [[ "$AUTO_FIX" == "true" ]]; then
                    log "INFO" "Applying formatting in: $target"
                    if ! terraform_format; then
                        failed=1
                    fi
                else
                    log "INFO" "Checking formatting in: $target"
                    if ! terraform_format "check"; then
                        failed=1
                    fi
                fi
                popd > /dev/null || true
            else
                log "WARN" "Skipping non-existent directory for formatting check: $target"
            fi
        done
    else
        if [[ "$AUTO_FIX" == "true" ]]; then
            log "INFO" "Applying formatting in entire workspace"
            if ! terraform_format; then
                failed=1
            fi
        else
            log "INFO" "Checking formatting in entire workspace"
            if ! terraform_format "check"; then
                failed=1
            fi
        fi
    fi

    if [[ $failed -eq 1 ]]; then
        log "ERROR" "Terraform formatting check failed"
        FMT_FAILED=1
        EXIT_CODE=1
    else
        log "INFO" "Terraform formatting check passed"
    fi
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
    echo_section "Running security scan with trivy"
    if ! execute_command "trivy fs . --format table"; then
        log "ERROR" "trivy found security issues"
        SECURITY_FAILED=1
        EXIT_CODE=1
    else
        log "INFO" "Security scan passed"
    fi
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
    local failed=0

    log "INFO" ">>> Investigating Terraform directory: $dir"

    if [[ ! -d "$dir" ]]; then
        log "WARN" "Directory disappeared, skipping: $dir"
        return 0
    fi

    pushd "$dir" > /dev/null || return 1

    # Step 1: Initialize Terraform (backend disabled for validation)
    if ! execute_command "terraform init -backend=false"; then
        log "ERROR" "Failed to initialize Terraform for $dir"
        failed=1
    fi

    # Step 2: Validate Terraform configuration
    if [[ $failed -eq 0 ]]; then
        if ! terraform_validate; then
            log "ERROR" "Terraform validation failed for $dir"
            failed=1
        fi
    fi

    # Step 4: Generate documentation (terraform-docs) if requested
    if [[ "$GENERATE_DOCS" == "true" ]]; then
        log "INFO" "Generating documentation (terraform-docs)"
        if ! execute_command "terraform-docs markdown --output-file README.md ./"; then
            log "WARN" "Failed to generate documentation for $dir"
            DOCS_FAILED=1
            # We don't fail the whole script just for docs unless EXIT_CODE should be 1
        fi
    fi

    popd > /dev/null || true
    return $failed
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
    echo_section "Starting recursive Terraform validation (init & validate)"
    local failed=0

    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        for target in "${TARGET_DIRS[@]}"; do
            if [[ ! -d "$target" ]]; then
                continue
            fi
            log "INFO" "Searching for Terraform modules in: $target"
            while IFS= read -r -d '' file; do
                local dir
                dir=$(dirname "$file")
                if ! process_terraform_directory "$dir"; then
                    failed=1
                fi
            done < <(find "$target" ! -path '*/.terraform/*' -type f -name 'main.tf' -print0)
        done
    else
        log "INFO" "Searching for Terraform modules in entire workspace"
        while IFS= read -r -d '' file; do
            local dir
            dir=$(dirname "$file")
            if ! process_terraform_directory "$dir"; then
                failed=1
            fi
        done < <(find . ! -path '*/.terraform/*' -type f -name 'main.tf' -print0)
    fi

    if [[ $failed -eq 1 ]]; then
        VALIDATE_FAILED=1
        EXIT_CODE=1
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
    start_time=$(date +%s)

    # Validate required dependencies
    local required_tools=("terraform" "tflint" "trivy")
    if [[ "$GENERATE_DOCS" == "true" ]]; then
        required_tools+=("terraform-docs")
    fi
    validate_dependencies "${required_tools[@]}"

    echo_section "Starting Terraform code quality checks"

    # Run checks
    run_tflint_check
    run_recursive_validation
    run_formatting_check
    run_security_scan

    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    if [[ "$EXIT_CODE" -eq 0 ]]; then
        echo_section "All checks completed successfully in ${elapsed} seconds"
        log "INFO" "✅ All validations passed"
    else
        echo_section "Result (completed in ${elapsed} seconds)"
        [[ "$TFLINT_FAILED" == "1" ]] && echo "❌ tflint" >&2 || echo "✅ tflint" >&2
        [[ "$VALIDATE_FAILED" == "1" ]] && echo "❌ terraform validate" >&2 || echo "✅ terraform validate" >&2
        [[ "$FMT_FAILED" == "1" ]] && echo "❌ terraform fmt" >&2 || echo "✅ terraform fmt" >&2
        [[ "$SECURITY_FAILED" == "1" ]] && echo "❌ security scan (trivy)" >&2 || echo "✅ security scan (trivy)" >&2
        [[ "$DOCS_FAILED" == "1" ]] && echo "⚠️  terraform-docs" >&2
        log "ERROR" "❌ Some validations failed"
    fi

    exit $EXIT_CODE
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
