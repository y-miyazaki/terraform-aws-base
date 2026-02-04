#!/bin/bash
#######################################
# Description: Comprehensive Node.js code quality, security, and testing validation script
#
# Usage: ./validate.sh [options] [directory]
#   options:
#     -h, --help     Display this help message
#     -v, --verbose  Enable verbose output
#     -d, --dry-run  Run in dry-run mode (no changes made)
#     -f, --fix      Automatically fix issues where possible
#   arguments:
#     directory      Target directory to validate (optional)
#                    If not provided, auto-detects all Node.js projects
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
DRY_RUN=false
FIX_MODE=false
TARGET_DIR=""
EXIT_CODE=0
IS_SCOPED=false

# Flags for individual checks
INSTALL_FAILED=0
AUDIT_FAILED=0
LOCKFILE_FAILED=0
SYNC_FAILED=0
TEST_FAILED=0

# Counters for issues
AUDIT_VULNERABILITIES=0
PROJECTS_CHECKED=0
PROJECTS_PASSED=0
PROJECTS_FAILED=0

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
Usage: $(basename "$0") [options] [directory]

Description: Comprehensive Node.js code quality, security, and testing validation script
             Automatically detects Node.js projects if no specific target is provided

Options:
  -h, --help     Display this help message
  -v, --verbose  Enable verbose output
  -d, --dry-run  Run in dry-run mode (no changes made)
  -f, --fix      Automatically fix issues where possible

Arguments:
  directory      Target directory to check (optional)
                 If not provided, auto-detects all Node.js projects

Examples:
  $(basename "$0")                                    # Auto-detect all Node.js projects
  $(basename "$0") -v                                 # Auto-detect with verbose output
  $(basename "$0") -f ./kinesis_data_firehose_cloudwatch_logs_processor  # Check specific project with auto-fix
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables accordingly
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Returns:
#   None (sets global variables)
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
                VERBOSE=true
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -f | --fix)
                FIX_MODE=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                if [[ -z "${TARGET_DIR:-}" ]]; then
                    TARGET_DIR="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Set default target directory
    if [[ -z "${TARGET_DIR:-}" ]]; then
        TARGET_DIR="/workspace/nodejs"
        log "INFO" "No target specified, will auto-detect Node.js projects from $TARGET_DIR"
    else
        if [[ ! -d "$TARGET_DIR" ]]; then
            error_exit "Target directory does not exist: $TARGET_DIR"
        fi
        IS_SCOPED=true
    fi
}

#######################################
# find_nodejs_projects: Find all Node.js projects in target directory
#
# Description:
#   Searches for package.json files (excluding node_modules and other common directories) to identify Node.js projects
#   Only returns directories that are actual project roots (not nested dependencies)
#
# Arguments:
#   $1 - Base directory to search (optional, defaults to TARGET_DIR)
#
# Returns:
#   Array of project directories (to stdout, one per line)
#
# Usage:
#   projects=$(find_nodejs_projects "/path/to/dir")
#
#######################################
function find_nodejs_projects {
    local base_dir=${1:-$TARGET_DIR}

    # Find package.json files, exclude node_modules and other dependency directories
    # Use -maxdepth to limit search depth for top-level projects only
    find "$base_dir" -maxdepth 2 -name "package.json" -type f \
        ! -path "*/node_modules/*" \
        ! -path "*/node_modules.bak/*" \
        ! -path "*/.git/*" \
        ! -path "*/dist/*" \
        ! -path "*/build/*" | while read -r pkg_json; do
        dirname "$pkg_json"
    done
}

#######################################
# check_package_lockfile: Check if package-lock.json exists and is in sync
#
# Description:
#   Validates the existence of package-lock.json and checks synchronization with package.json
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   0 if lockfile exists and is in sync, 1 otherwise
#
# Usage:
#   check_package_lockfile "/path/to/project"
#
#######################################
function check_package_lockfile {
    local project_dir=$1
    local status=0

    if [[ ! -f "$project_dir/package-lock.json" ]]; then
        log "WARN" "  ⚠️  package-lock.json not found"
        log "WARN" "      This could indicate security risk - packages may install different versions"
        LOCKFILE_FAILED=1
        status=1
    else
        log "INFO" "  ✅ package-lock.json found"
    fi

    return $status
}

#######################################
# check_package_sync: Check if package.json and package-lock.json are in sync
#
# Description:
#   Uses npm ci --dry-run to verify synchronization between package files
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   0 if files are in sync, 1 otherwise
#
# Usage:
#   check_package_sync "/path/to/project"
#
#######################################
function check_package_sync {
    local project_dir=$1

    log "INFO" "  📦 Verifying package.json and package-lock.json sync..."

    if [[ ! -f "$project_dir/package-lock.json" ]]; then
        log "WARN" "  ⚠️  Skipping sync check (no package-lock.json)"
        return 1
    fi

    pushd "$project_dir" > /dev/null || return 1

    if npm ci --dry-run > /dev/null 2>&1; then
        log "INFO" "  ✅ Package files are in sync"
        popd > /dev/null
        return 0
    else
        log "WARN" "  ⚠️  package.json and package-lock.json may be out of sync"
        SYNC_FAILED=1
        popd > /dev/null
        return 1
    fi
}

#######################################
# run_npm_install: Install dependencies
#
# Description:
#   Installs npm dependencies for the project
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   run_npm_install "/path/to/project"
#
#######################################
function run_npm_install {
    local project_dir=$1

    log "INFO" "  📥 Installing dependencies..."

    pushd "$project_dir" > /dev/null || return 1

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm install"
        popd > /dev/null
        return 0
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        if npm install; then
            log "INFO" "  ✅ Dependencies installed"
            popd > /dev/null
            return 0
        else
            log "ERROR" "  ❌ Failed to install dependencies"
            INSTALL_FAILED=1
            EXIT_CODE=1
            popd > /dev/null
            return 1
        fi
    else
        if npm install > /dev/null 2>&1; then
            log "INFO" "  ✅ Dependencies installed"
            popd > /dev/null
            return 0
        else
            log "ERROR" "  ❌ Failed to install dependencies"
            INSTALL_FAILED=1
            EXIT_CODE=1
            popd > /dev/null
            return 1
        fi
    fi
}

#######################################
# run_security_audit: Run npm audit for security vulnerabilities
#
# Description:
#   Checks for known security vulnerabilities in dependencies
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   0 if no vulnerabilities found, 1 otherwise
#
# Usage:
#   run_security_audit "/path/to/project"
#
#######################################
function run_security_audit {
    local project_dir=$1

    log "INFO" "  🛡️  Running security audit..."

    pushd "$project_dir" > /dev/null || return 1

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm audit"
        popd > /dev/null
        return 0
    fi

    local audit_output
    local audit_status

    audit_output=$(npm audit --audit-level=moderate 2>&1) || audit_status=$?

    if [[ ${audit_status:-0} -eq 0 ]]; then
        log "INFO" "  ✅ No security vulnerabilities found"
        popd > /dev/null
        return 0
    else
        # Count vulnerabilities
        local vuln_count
        vuln_count=$(echo "$audit_output" | grep -E "^[0-9]+ vulnerabilities" | awk '{print $1}' || echo "0")

        if [[ "$vuln_count" -gt 0 ]]; then
            log "ERROR" "  ❌ Security vulnerabilities found: $vuln_count"
            AUDIT_VULNERABILITIES=$((AUDIT_VULNERABILITIES + vuln_count))

            if [[ "$VERBOSE" == "true" ]]; then
                echo "$audit_output"
            fi

            if [[ "$FIX_MODE" == "true" ]]; then
                log "INFO" "  🔧 Attempting to fix vulnerabilities..."
                if npm audit fix; then
                    log "INFO" "  ✅ Vulnerabilities fixed"
                else
                    log "WARN" "  ⚠️  Some vulnerabilities could not be auto-fixed"
                fi
            fi
        else
            log "WARN" "  ⚠️  Security vulnerabilities found - review npm audit output"
            if [[ "$VERBOSE" == "true" ]]; then
                echo "$audit_output"
            fi
        fi

        AUDIT_FAILED=1
        EXIT_CODE=1
        popd > /dev/null
        return 1
    fi
}

#######################################
# run_outdated_check: Check for outdated packages
#
# Description:
#   Checks if any packages have newer versions available
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   Always returns 0 (informational only)
#
# Usage:
#   run_outdated_check "/path/to/project"
#
#######################################
function run_outdated_check {
    local project_dir=$1

    log "INFO" "  📅 Checking for outdated packages..."

    pushd "$project_dir" > /dev/null || return 1

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm outdated"
        popd > /dev/null
        return 0
    fi

    local outdated_output
    if outdated_output=$(npm outdated 2>&1); then
        log "INFO" "  ✅ All packages are up to date"
    else
        if [[ "$VERBOSE" == "true" ]]; then
            log "INFO" "  ℹ️  Some packages have updates available:"
            echo "$outdated_output"
        else
            log "INFO" "  ℹ️  Some packages have updates available (run with -v for details)"
        fi
    fi

    popd > /dev/null
    return 0
}

#######################################
# run_tests: Run npm test
#
# Description:
#   Executes the test suite defined in package.json
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   0 if tests pass, 1 if tests fail or not defined
#
# Usage:
#   run_tests "/path/to/project"
#
#######################################
function run_tests {
    local project_dir=$1

    log "INFO" "  🧪 Running tests..."

    pushd "$project_dir" > /dev/null || return 1

    # Check if test script exists
    if ! grep -q '"test"' package.json 2> /dev/null; then
        log "WARN" "  ⚠️  No test script defined in package.json"
        popd > /dev/null
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm test"
        popd > /dev/null
        return 0
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        if npm test; then
            log "INFO" "  ✅ All tests passed"
            popd > /dev/null
            return 0
        else
            log "ERROR" "  ❌ Tests failed"
            TEST_FAILED=1
            EXIT_CODE=1
            popd > /dev/null
            return 1
        fi
    else
        if npm test > /dev/null 2>&1; then
            log "INFO" "  ✅ All tests passed"
            popd > /dev/null
            return 0
        else
            log "ERROR" "  ❌ Tests failed"
            TEST_FAILED=1
            EXIT_CODE=1
            popd > /dev/null
            return 1
        fi
    fi
}

#######################################
# validate_project: Validate a single Node.js project
#
# Description:
#   Performs all validation checks on a single Node.js project
#
# Arguments:
#   $1 - Project directory
#
# Returns:
#   0 if all checks pass, 1 if any check fails
#
# Usage:
#   validate_project "/path/to/project"
#
#######################################
function validate_project {
    local project_dir=$1
    local project_name
    project_name=$(basename "$project_dir")
    local project_status=0

    echo_section "Validating: $project_name"
    log "INFO" "📂 Project: $project_dir"

    PROJECTS_CHECKED=$((PROJECTS_CHECKED + 1))

    # Check if package.json exists
    if [[ ! -f "$project_dir/package.json" ]]; then
        log "ERROR" "❌ package.json not found in $project_dir"
        PROJECTS_FAILED=$((PROJECTS_FAILED + 1))
        return 1
    fi

    # Reset per-project flags
    local project_lockfile_failed=0
    local project_sync_failed=0
    local project_install_failed=0
    local project_audit_failed=0
    local project_test_failed=0

    # Run checks
    check_package_lockfile "$project_dir" || project_lockfile_failed=1
    check_package_sync "$project_dir" || project_sync_failed=1
    run_npm_install "$project_dir" || project_install_failed=1

    # Only run remaining checks if install succeeded
    if [[ $project_install_failed -eq 0 ]]; then
        run_security_audit "$project_dir" || project_audit_failed=1
        run_outdated_check "$project_dir"
        run_tests "$project_dir" || project_test_failed=1
    else
        log "WARN" "⚠️  Skipping remaining checks due to install failure"
        project_status=1
    fi

    # Determine overall project status
    if [[ $project_lockfile_failed -eq 1 ]] || [[ $project_sync_failed -eq 1 ]] \
        || [[ $project_install_failed -eq 1 ]] || [[ $project_audit_failed -eq 1 ]] \
        || [[ $project_test_failed -eq 1 ]]; then
        project_status=1
        PROJECTS_FAILED=$((PROJECTS_FAILED + 1))
        log "ERROR" "❌ Project validation failed: $project_name"
    else
        PROJECTS_PASSED=$((PROJECTS_PASSED + 1))
        log "INFO" "✅ Project validation passed: $project_name"
    fi

    return $project_status
}

#######################################
# main: Main validation function
#
# Description:
#   Main entry point for the validation script
#   Coordinates all validation activities
#
# Arguments:
#   $@ - All command line arguments
#
# Returns:
#   None (exits with appropriate status code)
#
# Usage:
#   main "$@"
#
#######################################
function main {
    parse_arguments "$@"

    start_time=$(date +%s)

    # Validate required dependencies
    validate_dependencies "node" "npm"

    echo_section "Starting Node.js code quality checks"
    log "INFO" "Target directory: $TARGET_DIR"
    log "INFO" "Scoped mode: $IS_SCOPED"
    log "INFO" "Verbose mode: $VERBOSE"
    log "INFO" "Dry-run mode: $DRY_RUN"
    log "INFO" "Fix mode: $FIX_MODE"

    # Find all Node.js projects
    local projects
    mapfile -t projects < <(find_nodejs_projects "$TARGET_DIR")

    if [[ ${#projects[@]} -eq 0 ]]; then
        log "WARN" "No Node.js projects found in $TARGET_DIR"
        exit 0
    fi

    log "INFO" "Found ${#projects[@]} Node.js project(s)"

    # Validate each project
    for project in "${projects[@]}"; do
        validate_project "$project" || true
    done

    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    # Print summary
    echo_section "Validation Summary"
    echo "Projects checked: $PROJECTS_CHECKED"
    echo "Projects passed:  $PROJECTS_PASSED"
    echo "Projects failed:  $PROJECTS_FAILED"
    echo ""

    if [[ $AUDIT_VULNERABILITIES -gt 0 ]]; then
        echo "Total vulnerabilities found: $AUDIT_VULNERABILITIES"
        echo ""
    fi

    if [[ "$EXIT_CODE" -eq 0 ]]; then
        echo_section "All checks completed successfully in ${elapsed} seconds"
        log "INFO" "✅ All validations passed"
    else
        echo_section "Result (completed in ${elapsed} seconds)"
        echo "Result:" >&2
        [[ "$INSTALL_FAILED" == "1" ]] && echo "❌ npm install" >&2 || echo "✅ npm install" >&2
        [[ "$LOCKFILE_FAILED" == "1" ]] && echo "❌ package-lock.json" >&2 || echo "✅ package-lock.json" >&2
        [[ "$SYNC_FAILED" == "1" ]] && echo "❌ package sync" >&2 || echo "✅ package sync" >&2
        if [[ "$AUDIT_FAILED" == "1" ]]; then
            if [[ $AUDIT_VULNERABILITIES -gt 0 ]]; then
                echo "❌ security audit ($AUDIT_VULNERABILITIES vulnerabilities)" >&2
            else
                echo "❌ security audit" >&2
            fi
        else
            echo "✅ security audit" >&2
        fi
        [[ "$TEST_FAILED" == "1" ]] && echo "❌ tests" >&2 || echo "✅ tests" >&2
        log "ERROR" "❌ Some validations failed"
    fi

    exit $EXIT_CODE
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
