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
#         --changed-only  Validate only projects with uncommitted git changes to JS/TS/JSON files
#   arguments:
#     directory      Target directory to validate (optional)
#                    If not provided, auto-detects all Node.js projects
#
# Design Rules:
#   - Projects are auto-detected (package.json up to depth 2) when no directory is given.
#   - Validation is read-only unless --fix is given; --dry-run prints planned commands only.
#   - A missing or out-of-sync package-lock.json fails the run (non-zero exit).
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
VERBOSE=false
DRY_RUN=false
FIX_MODE=false
TARGET_DIR=""
EXIT_CODE=0
IS_SCOPED=false
# When true, validate only projects containing uncommitted git changes
CHANGED_ONLY=false

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
Usage: $(basename "$0") [options] [directory]

Description: Comprehensive Node.js code quality, security, and testing validation script
             Automatically detects Node.js projects if no specific target is provided

Options:
  -h, --help     Display this help message
  -v, --verbose  Enable verbose output
  -d, --dry-run  Run in dry-run mode (no changes made)
  -f, --fix      Automatically fix issues where possible
      --changed-only  Only projects containing JS/TS/JSON files with uncommitted git changes
                 (staged, unstaged, untracked, deleted)

Arguments:
  directory      Target directory to check (optional)
                 If not provided, auto-detects all Node.js projects

Examples:
  $(basename "$0")                                    # Auto-detect all Node.js projects
  $(basename "$0") -v                                 # Auto-detect with verbose output
  $(basename "$0") -f ./kinesis_data_firehose_cloudwatch_logs_processor  # Check specific project with auto-fix
  $(basename "$0") --changed-only                     # Only projects with git changes
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables accordingly
#
# Globals:
#   CHANGED_ONLY - Limit validation to projects with uncommitted git changes
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
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
            --changed-only)
                CHANGED_ONLY=true
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
                if [[ -z ${TARGET_DIR:-} ]]; then
                    TARGET_DIR="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Set default target directory
    if [[ -z ${TARGET_DIR:-} ]]; then
        TARGET_DIR="$(pwd)"
        log "INFO" "No target specified, will auto-detect Node.js projects from current directory: $TARGET_DIR"
    else
        if [[ ! -d $TARGET_DIR ]]; then
            error_exit "Target directory does not exist: $TARGET_DIR"
        fi
        IS_SCOPED=true
    fi
}

#######################################
# check_package_lockfile: Check if package-lock.json exists and is in sync
#
# Description:
#   Validates the existence of package-lock.json and checks synchronization with package.json
#
# Globals:
#   LOCKFILE_FAILED - Set to 1 on failure
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
#
# Returns:
#   0 if lockfile exists and is in sync, 1 otherwise
#
#######################################
function check_package_lockfile {
    local project_dir=$1
    local status=0

    if [[ ! -f "$project_dir/package-lock.json" ]]; then
        log "WARN" "  ⚠️  package-lock.json not found"
        log "WARN" "      This could indicate security risk - packages may install different versions"
        LOCKFILE_FAILED=1
        EXIT_CODE=1
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
# Globals:
#   SYNC_FAILED - Set to 1 on failure
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
#
# Returns:
#   0 if files are in sync, 1 otherwise
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
        EXIT_CODE=1
        popd > /dev/null
        return 1
    fi
}

#######################################
# filter_changed_projects: Keep only projects containing uncommitted git changes
#
# Description:
#   Reads project directories from the arguments and emits those that own at least one file
#   with uncommitted changes (staged, unstaged, untracked, deleted) to a JavaScript, TypeScript
#   or JSON file. A changed file belongs to the deepest project directory that contains it.
#
# Globals:
#   None
#
# Arguments:
#   $@ - Project directories
#
# Outputs:
#   Project directories with changes to stdout, one per line (input order)
#
# Returns:
#   0 on success
#
# Usage:
#   mapfile -t projects < <(filter_changed_projects "${projects[@]}")
#
#######################################
function filter_changed_projects {
    local -a abs_projects=() orig_projects=("$@")
    local project file best_index i
    for project in "${orig_projects[@]}"; do
        abs_projects+=("$(cd "$project" && pwd)")
    done

    local -a owned=()
    while IFS= read -r file; do
        [[ -z $file ]] && continue
        best_index=-1
        for i in "${!abs_projects[@]}"; do
            if [[ "$PWD/$file" == "${abs_projects[$i]}/"* ]]; then
                if [[ $best_index -lt 0 || ${#abs_projects[$i]} -gt ${#abs_projects[$best_index]} ]]; then
                    best_index=$i
                fi
            fi
        done
        if [[ $best_index -ge 0 ]]; then
            owned[best_index]=1
        fi
    done < <(REPO_PATHS_INCLUDE_DELETED=true repo_emit_changed_paths '\.(js|jsx|mjs|cjs|ts|tsx|mts|cts|json)$')

    for i in "${!abs_projects[@]}"; do
        if [[ -n ${owned[$i]:-} ]]; then
            printf '%s\n' "${orig_projects[$i]}"
        fi
    done
}

#######################################
# find_nodejs_projects: Find all Node.js projects in target directory
#
# Description:
#   Searches for package.json files (excluding node_modules and other common directories) to identify Node.js projects
#   Only returns directories that are actual project roots (not nested dependencies)
#
# Globals:
#   None
#
# Arguments:
#   $1 - Base directory to search (optional, defaults to TARGET_DIR)
#
# Outputs:
#   Array of project directories (to stdout, one per line)
#
# Returns:
#   0 on success
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
        ! -path "*/build/*" -print0 | while IFS= read -r -d '' pkg_json; do
        dirname "$pkg_json"
    done
}

#######################################
# run_npm_install: Install dependencies
#
# Description:
#   Installs npm dependencies for the project (npm ci; npm install with --fix)
#
# Globals:
#   DRY_RUN - Whether running in dry-run mode
#   FIX_MODE - Use npm install instead of npm ci when true
#   VERBOSE - Whether to show npm output
#   INSTALL_FAILED - Set to 1 on failure
#   EXIT_CODE - Set to 1 on failure
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
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

    # npm ci installs exactly what package-lock.json pins and never rewrites it;
    # only --fix may use npm install (which can update the lockfile).
    local -a install_cmd=(npm ci)
    if [[ $FIX_MODE == "true" ]]; then
        install_cmd=(npm install)
    fi

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: ${install_cmd[*]}"
        popd > /dev/null
        return 0
    fi

    local install_status=0
    if [[ $VERBOSE == "true" ]]; then
        "${install_cmd[@]}" || install_status=$?
    else
        "${install_cmd[@]}" > /dev/null 2>&1 || install_status=$?
    fi
    popd > /dev/null

    if [[ $install_status -eq 0 ]]; then
        log "INFO" "  ✅ Dependencies installed (${install_cmd[*]})"
        return 0
    fi
    log "ERROR" "  ❌ Failed to install dependencies (${install_cmd[*]})"
    INSTALL_FAILED=1
    EXIT_CODE=1
    return 1
}

#######################################
# run_outdated_check: Check for outdated packages
#
# Description:
#   Checks if any packages have newer versions available
#
# Globals:
#   DRY_RUN - Whether running in dry-run mode
#   VERBOSE - Whether to show verbose output
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
#
# Returns:
#   Always returns 0 (informational only)
#
#######################################
function run_outdated_check {
    local project_dir=$1

    log "INFO" "  📅 Checking for outdated packages..."

    pushd "$project_dir" > /dev/null || return 1

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm outdated"
        popd > /dev/null
        return 0
    fi

    local outdated_output
    if outdated_output=$(npm outdated 2>&1); then
        log "INFO" "  ✅ All packages are up to date"
    else
        if [[ $VERBOSE == "true" ]]; then
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
# run_security_audit: Run npm audit for security vulnerabilities
#
# Description:
#   Checks for known security vulnerabilities in dependencies
#
# Globals:
#   DRY_RUN - Whether running in dry-run mode
#   FIX_MODE - Whether to attempt auto-fix
#   VERBOSE - Whether to show verbose output
#   AUDIT_VULNERABILITIES - Incremented with vulnerability count
#   AUDIT_FAILED - Set to 1 on failure
#   EXIT_CODE - Set to 1 on failure
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
#
# Returns:
#   0 if no vulnerabilities found, 1 otherwise
#
#######################################
function run_security_audit {
    local project_dir=$1

    log "INFO" "  🛡️  Running security audit..."

    pushd "$project_dir" > /dev/null || return 1

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm audit"
        popd > /dev/null
        return 0
    fi

    local audit_output
    local audit_status=0

    audit_output=$(npm audit --audit-level=moderate 2>&1) || audit_status=$?

    if [[ $audit_status -eq 0 ]]; then
        log "INFO" "  ✅ No security vulnerabilities found"
        popd > /dev/null
        return 0
    fi

    if [[ $FIX_MODE == "true" ]]; then
        log "INFO" "  🔧 Attempting to fix vulnerabilities..."
        local fix_output
        if fix_output=$(npm audit fix 2>&1); then
            if [[ $VERBOSE == "true" ]]; then
                echo "$fix_output"
            fi

            # Re-run audit and accept success when vulnerabilities are resolved.
            local post_fix_output
            local post_fix_status=0
            post_fix_output=$(npm audit --audit-level=moderate 2>&1) || post_fix_status=$?

            if [[ $post_fix_status -eq 0 ]]; then
                log "INFO" "  ✅ Vulnerabilities fixed"
                popd > /dev/null
                return 0
            fi

            audit_output="$post_fix_output"
        else
            log "WARN" "  ⚠️  Some vulnerabilities could not be auto-fixed"
            if [[ $VERBOSE == "true" ]]; then
                echo "$fix_output"
            fi
        fi
    fi

    # Count remaining vulnerabilities from the latest audit output.
    local vuln_count
    vuln_count=$(echo "$audit_output" | grep -E "^[0-9]+ vulnerabilit(y|ies)" | awk '{print $1}' || echo "0")

    if [[ $vuln_count -gt 0 ]]; then
        log "ERROR" "  ❌ Security vulnerabilities found: $vuln_count"
        AUDIT_VULNERABILITIES=$((AUDIT_VULNERABILITIES + vuln_count))
    else
        log "WARN" "  ⚠️  Security audit failed - review npm audit output"
    fi

    if [[ $VERBOSE == "true" ]]; then
        echo "$audit_output"
    fi

    AUDIT_FAILED=1
    EXIT_CODE=1
    popd > /dev/null
    return 1
}

#######################################
# run_tests: Run npm test
#
# Description:
#   Executes the test suite defined in package.json
#
# Globals:
#   None
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
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

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "  🔍 [DRY-RUN] Would run: npm test"
        popd > /dev/null
        return 0
    fi

    if [[ $VERBOSE == "true" ]]; then
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
# Globals:
#   None
#
# Arguments:
#   $1 - Project directory
#
# Outputs:
#   None
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
# main: Main process
#
# Description:
#   Main entry point for the validation script
#   Coordinates all validation activities
#
# Globals:
#   None
#
# Arguments:
#   $@ - All command line arguments
#
# Outputs:
#   None
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
    require_dependencies "node" "npm"

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

    if [[ $CHANGED_ONLY == "true" ]]; then
        mapfile -t projects < <(filter_changed_projects "${projects[@]}")
        if [[ ${#projects[@]} -eq 0 ]]; then
            log "INFO" "--changed-only: no changed Node.js projects"
            print_validation_result nodejs 0 "changed_only=SKIP|no changed Node.js projects" || true
            exit 0
        fi
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

    local audit_detail=""
    if [[ $AUDIT_VULNERABILITIES -gt 0 ]]; then
        audit_detail="|${AUDIT_VULNERABILITIES} vulnerabilities"
    fi
    print_validation_result nodejs "$elapsed" \
        "npm_install=$(check_status "$INSTALL_FAILED")" \
        "package_lock=$(check_status "$LOCKFILE_FAILED")" \
        "package_sync=$(check_status "$SYNC_FAILED")" \
        "security_audit=$(check_status "$AUDIT_FAILED")${audit_detail}" \
        "tests=$(check_status "$TEST_FAILED")" || true

    exit $EXIT_CODE
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
