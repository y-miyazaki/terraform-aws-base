#!/bin/bash
#######################################
# Description: Recursive Terraform validation, formatting check, linting, docs generation and security scanning script.
#
# Usage: ./validate.sh [options] [dir1 dir2 ...]
#   options:
#     -h, --help           Display this help message
#     -v, --verbose        Enable verbose output
#     -g, --generate-docs  Generate README.md using terraform-docs (requires terraform-docs installed)
#     -f, --fix            Automatically fix formatting issues (terraform fmt); with -o also argument order
#     -o, --check-order    Check alphabetical argument order (ORD-01) with terraform_attr_order.py (requires python3)
#         --changed-only   Validate only modules (nearest directory with .tf files) of Terraform files with uncommitted git changes
#   arguments:
#     dirN                 One or more target directories to scope validation (optional)
# Design Rules:
#   - If no directories are given, scan entire workspace
#   - Directories are validated recursively for each main.tf found
#   - Uses terraform.sh library functions for consistency
#   - Runs tflint recursively before validation
#   - Checks alphabetical argument order (ORD-01) only when --check-order is given
#   - Follows common parse_arguments pattern used in other scripts
#
# Output:
# - Exit code 0 if all checks pass, non-zero otherwise
# - Detailed check results to stderr
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
TARGET_DIRS=()
GENERATE_DOCS="false"
AUTO_FIX="false"
CHECK_ORDER="false"
# true when --changed-only limits TARGET_DIRS to directories with uncommitted git changes
CHANGED_ONLY="false"
# shellcheck disable=SC2034
VERBOSE="false"
EXIT_CODE=0

# Flags for individual checks
TFLINT_FAILED=0
VALIDATE_FAILED=0
FMT_FAILED=0
ORDER_FAILED=0
SECURITY_FAILED=0
DOCS_FAILED=0

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Writes to stdout
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options] [dir1 dir2 ...]

Description: Recursive Terraform validation, formatting check, linting, and security scanning.
             If no directory arguments are provided it scans the entire workspace (current directory).
             If one or more directories are provided, only those paths (recursively) are processed.

Options:
  -h, --help           Display this help message
  -v, --verbose        Enable verbose output
  -g, --generate-docs  Generate README.md using terraform-docs (requires terraform-docs installed)
                       (-d is a deprecated alias; -d is reserved for --dry-run in the other validate scripts)
  -f, --fix            Automatically fix formatting issues (terraform fmt); with -o also argument order
  -o, --check-order    Check alphabetical argument order (ORD-01) with terraform_attr_order.py (requires python3)
      --changed-only   Only modules (nearest directory with .tf files, scanned recursively) of .tf/.tfvars/.hcl
                       files with uncommitted git changes (staged, unstaged, untracked);
                       directory arguments narrow the set; a module at the current directory means the
                       whole tree; init/validate run only where main.tf exists

Examples:
  $0                         # scan whole workspace
  $0 modules/aws/security    # scan only that subtree
  $0 modules/aws/vpc modules/aws/iam  # scan multiple targets
  $0 -g modules/aws/vpc      # scan and generate docs
  $0 --changed-only          # scan only directories with git changes
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and collects target directories
#
# Globals:
#   TARGET_DIRS - Array of target directories to process
#   CHANGED_ONLY - Limit TARGET_DIRS to directories with uncommitted git changes
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
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
            -g | --generate-docs)
                GENERATE_DOCS="true"
                ;;
            -d)
                # Deprecated alias: -d means --dry-run in the other scripts
                log "WARN" "-d is deprecated for --generate-docs; use -g or --generate-docs"
                GENERATE_DOCS="true"
                ;;
            -f | --fix)
                AUTO_FIX="true"
                ;;
            -o | --check-order)
                CHECK_ORDER="true"
                ;;
            --changed-only)
                CHANGED_ONLY="true"
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

    if [[ $CHANGED_ONLY == "true" ]]; then
        local target_dir
        for target_dir in ${TARGET_DIRS[@]+"${TARGET_DIRS[@]}"}; do
            if [[ ! -d $target_dir ]]; then
                error_exit "Target directory does not exist: $target_dir"
            fi
        done
        local -a changed_files=()
        # The scope list is expanded before mapfile truncates changed_files
        mapfile -t changed_files < <(REPO_PATHS_INCLUDE_DELETED=true repo_emit_changed_paths '\.(tf|tfvars|hcl)$' ${TARGET_DIRS[@]+"${TARGET_DIRS[@]}"})
        TARGET_DIRS=()
        mapfile -t TARGET_DIRS < <(resolve_changed_module_dirs ${changed_files[@]+"${changed_files[@]}"})
        if [[ ${#TARGET_DIRS[@]} -eq 0 ]]; then
            log "INFO" "--changed-only: no changed Terraform modules"
            print_validation_result terraform 0 "changed_only=SKIP|no changed Terraform modules" || true
            exit 0
        fi
    fi
}

#######################################
# process_terraform_directory: Process single terraform directory
#
# Description:
#   Processes a single Terraform directory with validation, linting, and documentation generation
#
# Globals:
#   None
#
# Arguments:
#   $1 - Directory path to process
#
# Outputs:
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

    if [[ ! -d $dir ]]; then
        log "WARN" "Directory disappeared, skipping: $dir"
        return 0
    fi

    pushd "$dir" > /dev/null || return 1

    # Step 1: Initialize Terraform (backend disabled for validation)
    if ! execute_command_string "terraform init -backend=false"; then
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

    # Step 3: Generate documentation (terraform-docs) if requested
    if [[ $GENERATE_DOCS == "true" ]]; then
        log "INFO" "Generating documentation (terraform-docs)"
        if ! execute_command_string "terraform-docs markdown table --output-file README.md ./"; then
            log "WARN" "Failed to generate documentation for $dir"
            DOCS_FAILED=1
            # We don't fail the whole script just for docs unless EXIT_CODE should be 1
        fi
    fi

    popd > /dev/null || true
    return $failed
}

#######################################
# resolve_changed_module_dirs: Map changed Terraform files to their module directories
#
# Description:
#   For each file, walks up from its directory to the nearest one that contains a .tf file;
#   that directory is the Terraform module. A module does not need a main.tf: fmt, tflint and
#   trivy work on any such directory, while init/validate still run only where main.tf exists.
#   When the nearest module is the current directory itself, "." is returned and the checks
#   cover the whole tree (the repository root is the module). Files with no module above them
#   are skipped with a warning. A removed file whose directory is gone selects the nearest
#   surviving ancestor module, which is where a reference to the removed module would live. Directories nested under another result are dropped because
#   every check already recurses into subdirectories.
#
# Globals:
#   None
#
# Arguments:
#   $@ - Changed file paths relative to the current directory
#
# Outputs:
#   Module directories to stdout, one per line, sorted and unique
#
# Returns:
#   0 on success
#
# Usage:
#   mapfile -t dirs < <(resolve_changed_module_dirs "${files[@]}")
#
#######################################
function resolve_changed_module_dirs {
    local file dir
    local -a modules=()
    for file in "$@"; do
        if dir="$(repo_nearest_ancestor_with "$(dirname "$file")" '*.tf')"; then
            modules+=("$dir")
        else
            log "WARN" "--changed-only: no Terraform module above $file, skipping" >&2
        fi
    done
    [[ ${#modules[@]} -eq 0 ]] && return 0

    local -a unique=()
    mapfile -t unique < <(printf '%s\n' "${modules[@]}" | sort -u)
    local m other nested
    for m in "${unique[@]}"; do
        nested=false
        for other in "${unique[@]}"; do
            if [[ $other != "$m" && ($other == "." || $m == "$other/"*) ]]; then
                nested=true
                break
            fi
        done
        if [[ $nested == "false" ]]; then
            printf '%s\n' "$m"
        fi
    done
}

#######################################
# run_attribute_order_check: Check alphabetical argument order (ORD-01)
#
# Description:
#   Runs terraform_attr_order.py on resource/data/module blocks. With --fix the files are rewritten in place.
#
# Globals:
#   TARGET_DIRS - Array of target directories (if scoped)
#   AUTO_FIX - Rewrite files instead of only checking
#   SCRIPT_DIR - Directory of this script
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None (sets ORDER_FAILED and EXIT_CODE on violations)
#
# Usage:
#   run_attribute_order_check
#
#######################################
function run_attribute_order_check {
    if [[ $AUTO_FIX == "true" ]]; then
        echo_section "Auto-fixing Terraform argument order (ORD-01)"
    else
        echo_section "Checking Terraform argument order (ORD-01)"
    fi

    local -a targets=(".")
    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        targets=("${TARGET_DIRS[@]}")
    fi

    local -a options=()
    if [[ $AUTO_FIX == "true" ]]; then
        options+=("--fix")
    fi

    if ! python3 "${SCRIPT_DIR}/terraform_attr_order.py" ${options[@]+"${options[@]}"} "${targets[@]}"; then
        log "ERROR" "Terraform argument order check failed"
        ORDER_FAILED=1
        EXIT_CODE=1
    else
        log "INFO" "Terraform argument order check passed"
    fi
}

#######################################
# run_formatting_check: Run terraform fmt recursively
#
# Description:
#   Checks that all Terraform files are properly formatted using terraform fmt -recursive
#
# Globals:
#   TARGET_DIRS - Array of target directories (if scoped)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   Exits with error if formatting issues are found
#
# Usage:
#   run_formatting_check
#
#######################################
function run_formatting_check {
    if [[ $AUTO_FIX == "true" ]]; then
        echo_section "Auto-fixing Terraform formatting"
    else
        echo_section "Checking Terraform formatting"
    fi
    local failed=0

    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        for target in "${TARGET_DIRS[@]}"; do
            if [[ -d $target ]]; then
                pushd "$target" > /dev/null || continue
                if [[ $AUTO_FIX == "true" ]]; then
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
        if [[ $AUTO_FIX == "true" ]]; then
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
# run_recursive_validation: Run recursive terraform validation
#
# Description:
#   Runs validation on all Terraform directories found, either scoped or full workspace
#
# Globals:
#   TARGET_DIRS - Array of target directories (if scoped)
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
#   run_recursive_validation
#
#######################################
function run_recursive_validation {
    echo_section "Starting recursive Terraform validation (init & validate)"
    local failed=0

    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        for target in "${TARGET_DIRS[@]}"; do
            if [[ ! -d $target ]]; then
                log "WARN" "Skipping non-existent directory for validation: $target"
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
# run_security_scan: Run security scan
#
# Description:
#   Runs security scan using trivy if available
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
#   Exits with error if security issues are found
#
# Usage:
#   run_security_scan
#
#######################################
function run_security_scan {
    echo_section "Running security scan with trivy"

    # Scope the scan to the target directories (default: the whole tree), like tflint and fmt
    local -a targets=(".")
    if [[ ${#TARGET_DIRS[@]} -gt 0 ]]; then
        targets=("${TARGET_DIRS[@]}")
    fi

    local target
    local scan_failed=0
    for target in "${targets[@]}"; do
        if [[ ! -d $target ]]; then
            log "WARN" "Skipping security scan for non-existent directory: $target"
            continue
        fi
        if ! execute_command trivy fs "$target" --format table; then
            log "ERROR" "trivy found security issues in $target"
            scan_failed=1
        fi
    done

    if [[ $scan_failed -ne 0 ]]; then
        SECURITY_FAILED=1
        EXIT_CODE=1
    else
        log "INFO" "Security scan passed"
    fi
}

#######################################
# run_tflint_check: Run tflint recursively
#
# Description:
#   Runs tflint recursively on all Terraform directories
#
# Globals:
#   TARGET_DIRS - Array of target directories (if scoped)
#
# Arguments:
#   None
#
# Outputs:
#   None
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
            if [[ -d $target ]]; then
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
# main: Main process
#
# Description:
#   Main function to execute the script logic for recursive Terraform validation
#
# Globals:
#   TARGET_DIRS - Array of target directories to process
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
    start_time=$(date +%s)

    # Validate required dependencies
    local required_tools=("terraform" "tflint" "trivy")
    if [[ $CHECK_ORDER == "true" ]]; then
        required_tools+=("python3")
    fi
    if [[ $GENERATE_DOCS == "true" ]]; then
        required_tools+=("terraform-docs")
    fi
    require_dependencies "${required_tools[@]}"

    echo_section "Starting Terraform code quality checks"

    # Run checks
    run_tflint_check
    run_recursive_validation
    run_formatting_check
    if [[ $CHECK_ORDER == "true" ]]; then
        run_attribute_order_check
    fi
    run_security_scan

    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    local order_status="SKIP"
    if [[ $CHECK_ORDER == "true" ]]; then
        order_status="$(check_status "$ORDER_FAILED")"
    fi
    local docs_status="SKIP"
    if [[ $GENERATE_DOCS == "true" ]]; then
        docs_status="PASS"
        if [[ $DOCS_FAILED == "1" ]]; then
            docs_status="WARN"
        fi
    fi
    print_validation_result terraform "$elapsed" \
        "tflint=$(check_status "$TFLINT_FAILED")" \
        "terraform_validate=$(check_status "$VALIDATE_FAILED")" \
        "terraform_fmt=$(check_status "$FMT_FAILED")" \
        "argument_order=${order_status}" \
        "security_scan=$(check_status "$SECURITY_FAILED")" \
        "terraform_docs=${docs_status}" || true

    exit $EXIT_CODE
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
