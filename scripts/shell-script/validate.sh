#!/bin/bash
#######################################
# Description: Comprehensive validation tool for all shell scripts in the workspace.
#
# Usage: ./validate.sh [options]
#   options:
#     -h, --help     Display this help message
#     -v, --verbose  Enable verbose output
#     -f, --fix      Auto-fix issues where possible
#     -q, --quiet    Suppress non-error output
#
# Design Rules:
#   - Use strict mode in scripts (set -euo pipefail) where appropriate
#   - Source common utilities from `scripts/lib/all.sh` (error_exit, log, etc.)
#   - Prefer quoting variables, local variables in functions and single responsibility
#   - Tests must be provided with Bats and run by this validator
#
# Dependencies:
#   - bash (expected at /bin/bash)
#   - shellcheck
#   - shfmt
#   - bats (bats-core) or bats
#   - jq
#
# Examples:
#   ./scripts/validate.sh
#   ./scripts/validate.sh --dry-run --verbose
#
# Output:
# - Validation results for each script to stdout
# - Exit code 0 if all checks pass, non-zero otherwise
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
AUTO_FIX=false
QUIET=false
CHECK_FUNCTION_DOCS=false
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# Global variable for script search paths
SEARCH_PATHS=()

# Counters for statistics
TOTAL_SCRIPTS=0
PASSED_SCRIPTS=0
FAILED_SCRIPTS=0
WARNINGS_COUNT=0

# Arrays for tracking results
declare -a PASSED_SCRIPTS_LIST=()
declare -a FAILED_SCRIPTS_LIST=()
declare -a WARNING_SCRIPTS_LIST=()
declare -a BATS_FAILED_TESTS=()
BATS_SUMMARY=""
BATS_EXIT_CODE=0

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
Usage: $(basename "$0") [options] [path1 path2 ...]

Description: Comprehensive validation tool for all shell scripts in the workspace.

Options:
  -h, --help     Display this help message
  -v, --verbose  Enable verbose output and detailed analysis
  -f, --fix      Auto-fix issues where possible (formatting, permissions)
  -q, --quiet    Suppress non-error output (only show summary)
  --check-function-docs
                 Opt-in: enforce Google Shell Style Guide function headers with
                 explicit Globals/Arguments/Outputs/Returns (None when N/A).
                 See https://google.github.io/styleguide/shellguide.html#s4.2-function-comments

Design Rules:
  - Use 'set -euo pipefail' in scripts where appropriate
  - Source shared helpers from scripts/lib/all.sh (error_exit, log, validate_dependencies)
  - Prefer quoting variables and using local variables in functions
  - Keep functions small and single-responsibility

Dependencies:
  - bash (POSIX bash, /bin/bash)
  - shellcheck (for static analysis)
  - shfmt (for formatting)
  - bats or bats-core (for Bats tests)
  - jq (for JSON processing)

Features:
  - Recursive script discovery
  - Syntax validation (bash -n)
  - Shellcheck static analysis
  - Permission validation
  - Shebang validation
  - Function dependency analysis
  - Performance analysis

Examples:
  $(basename "$0")           # Run all validations
  $(basename "$0") -v        # Verbose output with detailed analysis
  $(basename "$0") -f        # Auto-fix fixable issues
  $(basename "$0") -q        # Quiet mode, show only summary
  $(basename "$0") --dry-run # Preview actions without executing external commands
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and options
#
# Globals:
#   VERBOSE - Enable verbose output
#   AUTO_FIX - Enable auto-fix mode
#   QUIET - Suppress non-error output
#   CHECK_FUNCTION_DOCS - Enable function doc block section checks
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   None
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
            -f | --fix)
                AUTO_FIX=true
                shift
                ;;
            -q | --quiet)
                QUIET=true
                shift
                ;;
            --check-function-docs)
                CHECK_FUNCTION_DOCS=true
                shift
                ;;
            # NOTE: Bats tests are always run; no external option needed
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Collect target directories or files
                SEARCH_PATHS+=("$1")
                shift
                ;;
        esac
    done
}

#######################################
# analyze_functions: Function to analyze script functions
#
# Description:
#   Function to analyze script functions
#
# Globals:
#   VERBOSE - Enable verbose output
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   analyze_functions "/path/to/script.sh"
#
#######################################
function analyze_functions {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    if [[ $VERBOSE != "true" ]]; then
        return 0
    fi

    custom_log "DEBUG" "Analyzing functions in: $script_name"

    local functions
    functions=$(grep -n "^function\|^[a-zA-Z_][a-zA-Z0-9_]*\s*()" "$script" 2> /dev/null | head -10)

    if [[ -n $functions ]]; then
        custom_log "INFO" "Functions found in $script_name:"
        echo "$functions" | while IFS= read -r func; do
            echo "  $func"
        done
    else
        custom_log "DEBUG" "No functions found in: $script_name"
    fi
}

#######################################
# auto_fix_formatting: Function to auto-fix script formatting with shfmt
#
# Description:
#   Function to auto-fix script formatting with shfmt
#
# Globals:
#   AUTO_FIX - Enable auto-fix mode
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   auto_fix_formatting "/path/to/script.sh"
#
#######################################
function auto_fix_formatting {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    if [[ $AUTO_FIX != "true" ]]; then
        return 0
    fi

    custom_log "DEBUG" "Auto-fixing formatting for: $script_name"

    if command -v shfmt &> /dev/null; then
        if shfmt -w -s -i 4 -ci -bn -sr "$script" 2> /dev/null; then
            custom_log "INFO" "✅ Formatted with shfmt: $script_name"
            return 0
        else
            custom_log "WARN" "⚠️  shfmt formatting failed: $script_name"
            return 1
        fi
    else
        custom_log "DEBUG" "shfmt not available, skipping formatting: $script_name"
        return 0
    fi
}

#######################################
# auto_fix_shellcheck: Function to auto-fix shellcheck issues
#
# Description:
#   Function to auto-fix shellcheck issues
#
# Globals:
#   AUTO_FIX - Enable auto-fix mode
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   auto_fix_shellcheck "/path/to/script.sh"
#
#######################################
function auto_fix_shellcheck {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    if [[ $AUTO_FIX != "true" ]]; then
        return 0
    fi

    custom_log "DEBUG" "Auto-fixing shellcheck issues for: $script_name"

    # Get shellcheck suggestions in diff format for auto-fixable issues
    local shellcheck_fixes
    if shellcheck_fixes=$(shellcheck -e SC1091 -f diff "$script" 2> /dev/null); then
        if [[ -n $shellcheck_fixes ]]; then
            # Apply the diff patches
            if echo "$shellcheck_fixes" | patch -p1 --silent 2> /dev/null; then
                custom_log "INFO" "✅ Applied shellcheck fixes: $script_name"
                return 0
            else
                custom_log "WARN" "⚠️  Failed to apply shellcheck fixes: $script_name"
                return 1
            fi
        fi
    fi

    return 0
}

#######################################
# check_complexity: Function to check script complexity
#
# Description:
#   Function to check script complexity
#
# Globals:
#   VERBOSE - Enable verbose output
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   check_complexity "/path/to/script.sh"
#
#######################################
function check_complexity {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    if [[ $VERBOSE != "true" ]]; then
        return 0
    fi

    custom_log "DEBUG" "Checking complexity for: $script_name"

    local line_count
    line_count=$(wc -l < "$script" 2> /dev/null)

    local function_count
    function_count=$(grep -c "^function\|^[a-zA-Z_][a-zA-Z0-9_]*\s*()" "$script" 2> /dev/null)

    local complexity_score=0

    # Line count scoring
    if [[ $line_count -gt 500 ]]; then
        complexity_score=$((complexity_score + 3))
    elif [[ $line_count -gt 200 ]]; then
        complexity_score=$((complexity_score + 2))
    elif [[ $line_count -gt 100 ]]; then
        complexity_score=$((complexity_score + 1))
    fi

    # Function count scoring
    if [[ $function_count -gt 20 ]]; then
        complexity_score=$((complexity_score + 2))
    elif [[ $function_count -gt 10 ]]; then
        complexity_score=$((complexity_score + 1))
    fi

    custom_log "INFO" "Complexity analysis for $script_name:"
    custom_log "INFO" "  Lines: $line_count, Functions: $function_count, Score: $complexity_score"

    if [[ $complexity_score -ge 4 ]]; then
        custom_log "WARN" "  High complexity script detected"
    fi
}

#######################################
# custom_echo_section: Override echo_section for quiet mode support
#
# Description:
#   Override echo_section for quiet mode support
#
# Globals:
#   QUIET - Suppress non-error output
#
# Arguments:
#   $1 - Section title
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   custom_echo_section "Section Title"
#
#######################################
function custom_echo_section {
    if [[ $QUIET != "true" ]]; then
        echo_section "$1"
    fi
}

#######################################
# custom_log: Override log function to handle warning counter and quiet mode
#
# Description:
#   Override log function to handle warning counter and quiet mode
#
# Globals:
#   QUIET - Suppress non-error output
#   WARNINGS_COUNT - Counter for warnings
#
# Arguments:
#   $1 - Log level
#   $2 - Message
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   custom_log "INFO" "Message"
#
#######################################
function custom_log {
    local level=$1
    local message=$2

    # Handle quiet mode
    if [[ $QUIET == "true" ]] && [[ $level == "INFO" || $level == "DEBUG" ]]; then
        return 0
    fi

    # Call the library log function
    log "$level" "$message"

    # Increment warning counter for WARN level
    if [[ $level == "WARN" ]]; then
        WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
    fi
}

#######################################
# find_bats_tests: Function to find Bats tests in the repository
#
# Description:
#   Function to find Bats tests in the repository
#
# Globals:
#   WORKSPACE_ROOT - Workspace root directory
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   Newline-separated .bats file paths
#
# Usage:
#   find_bats_tests
#
#######################################
function find_bats_tests {
    local bats_files=()
    while IFS= read -r -d '' file; do
        bats_files+=("$file")
    done < <(find "$WORKSPACE_ROOT" -type f -name "*.bats" -print0 2> /dev/null)

    for f in "${bats_files[@]}"; do
        echo "$f"
    done
}

#######################################
# find_shell_scripts: Function to find all shell scripts recursively
#
# Description:
#   Function to find all shell scripts recursively
#
# Globals:
#   SEARCH_PATHS - Array of search paths
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   List of shell script paths
#
# Usage:
#   find_shell_scripts
#
#######################################
function find_shell_scripts {
    local scripts=()

    for search_path in "${SEARCH_PATHS[@]}"; do
        local resolved_search_path
        if [[ $search_path == /* ]]; then
            resolved_search_path="$(normalize_path "$search_path")"
        else
            resolved_search_path="$(normalize_path "$WORKSPACE_ROOT/$search_path")"
        fi

        if [[ -f $resolved_search_path ]]; then
            # Direct file path specified
            custom_log "DEBUG" "Adding file: $resolved_search_path" >&2
            scripts+=("$resolved_search_path")
        elif [[ -d $resolved_search_path ]]; then
            # Send debug log to stderr to avoid interfering with function output
            custom_log "DEBUG" "Searching for scripts in: $resolved_search_path" >&2

            # Find files with .sh extension
            while IFS= read -r -d '' script; do
                # Double-check it's a file (not directory)
                if [[ -f $script ]]; then
                    scripts+=("$(normalize_path "$script")")
                fi
            done < <(find "$resolved_search_path" -type f -name "*.sh" -print0 2> /dev/null)

            # Find files with shell shebang but no .sh extension
            while IFS= read -r -d '' script; do
                if [[ -f $script ]] && head -1 "$script" 2> /dev/null | grep -q "^#!/.*sh"; then
                    # Only add if not already in scripts array
                    local already_added=false
                    for existing in "${scripts[@]}"; do
                        if [[ $existing == "$script" ]]; then
                            already_added=true
                            break
                        fi
                    done
                    if [[ $already_added == "false" ]]; then
                        scripts+=("$(normalize_path "$script")")
                    fi
                fi
            done < <(find "$resolved_search_path" -type f ! -name "*.sh" -executable -print0 2> /dev/null)
        else
            # Send debug log to stderr
            custom_log "DEBUG" "Search path does not exist or is not a directory: $resolved_search_path" >&2
        fi
    done

    # Output only valid files, filtered again to ensure no directories slip through
    for script in "${scripts[@]}"; do
        if [[ -f $script && ! -d $script ]]; then
            echo "$script"
        fi
    done | sort -u
}

#######################################
# generate_recommendations: Function to generate recommendations
#
# Description:
#   Function to generate recommendations
#
# Globals:
#   VERBOSE - Enable verbose output
#   FAILED_SCRIPTS - Counter for failed scripts
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   generate_recommendations
#
#######################################
function generate_recommendations {
    if [[ $VERBOSE != "true" ]]; then
        return 0
    fi

    custom_echo_section "Recommendations"

    echo "🔧 Improvement suggestions:"
    echo ""

    if [[ $FAILED_SCRIPTS -gt 0 ]]; then
        echo "🔨 To auto-fix common issues, run:"
        echo "  $(basename "$0") --fix"
        echo ""
    fi

    echo "📚 Best practices:"
    echo "  - Use 'set -euo pipefail' for strict error handling"
    echo "  - Quote variables to prevent word splitting"
    echo "  - Use local variables in functions"
    echo "  - Add comprehensive documentation headers"
    echo "  - Implement proper error handling and logging"
}

#######################################
# generate_summary_report: Function to generate summary report
#
# Description:
#   Function to generate summary report
#
# Globals:
#   TOTAL_SCRIPTS - Total scripts counter
#   PASSED_SCRIPTS - Passed scripts counter
#   FAILED_SCRIPTS - Failed scripts counter
#   WARNINGS_COUNT - Warnings counter
#   PASSED_SCRIPTS_LIST - List of passed scripts
#   FAILED_SCRIPTS_LIST - List of failed scripts
#   WARNING_SCRIPTS_LIST - List of warning scripts
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
#   generate_summary_report
#
#######################################
function generate_summary_report {
    custom_echo_section "Validation Summary Report"

    echo "📊 Statistics:"
    echo "  Total scripts validated: $TOTAL_SCRIPTS"
    echo "  Scripts passed: $PASSED_SCRIPTS"
    echo "  Scripts failed: $FAILED_SCRIPTS"
    if [[ ${#BATS_FAILED_TESTS[@]} -gt 0 ]]; then
        echo "  Bats test failures: ${#BATS_FAILED_TESTS[@]}"
    elif [[ ${BATS_EXIT_CODE:-0} -ne 0 ]]; then
        echo "  Bats exit code: ${BATS_EXIT_CODE}"
    fi
    echo "  Warnings issued: $WARNINGS_COUNT"
    echo ""

    if [[ ${#PASSED_SCRIPTS_LIST[@]} -gt 0 ]]; then
        echo "✅ Scripts that passed all validations:"
        for script in "${PASSED_SCRIPTS_LIST[@]}"; do
            echo "  - $script"
        done
        echo ""
    fi

    if [[ ${#FAILED_SCRIPTS_LIST[@]} -gt 0 ]]; then
        echo "❌ Scripts that failed validation:"
        for script in "${FAILED_SCRIPTS_LIST[@]}"; do
            echo "  - $script"
        done
        echo ""
    fi

    if [[ ${#BATS_FAILED_TESTS[@]} -gt 0 ]]; then
        echo "❌ Bats test failures (${#BATS_FAILED_TESTS[@]}):"
        for test in "${BATS_FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
        if [[ -n $BATS_SUMMARY ]]; then
            echo "  Summary: $BATS_SUMMARY"
        fi
        echo ""
    elif [[ ${BATS_EXIT_CODE:-0} -ne 0 ]]; then
        echo "❌ Bats tests did not complete successfully (exit ${BATS_EXIT_CODE})"
        if [[ -n $BATS_SUMMARY ]]; then
            echo "  Summary: $BATS_SUMMARY"
        else
            echo "  Summary: no TAP summary captured (run may have been interrupted)"
        fi
        echo ""
    fi

    if [[ ${#WARNING_SCRIPTS_LIST[@]} -gt 0 ]]; then
        echo "⚠️  Scripts with warnings:"
        for script in "${WARNING_SCRIPTS_LIST[@]}"; do
            echo "  - $script"
        done
        echo ""
    fi

    # Overall result
    if [[ $FAILED_SCRIPTS -eq 0 && ${#BATS_FAILED_TESTS[@]} -eq 0 && ${BATS_EXIT_CODE:-0} -eq 0 ]]; then
        if [[ $WARNINGS_COUNT -eq 0 ]]; then
            echo "🎉 All scripts passed validation with no warnings!"
        else
            echo "✅ All scripts passed validation (with $WARNINGS_COUNT warnings)"
        fi
    else
        local failure_parts=()
        if [[ $FAILED_SCRIPTS -gt 0 ]]; then
            failure_parts+=("$FAILED_SCRIPTS script(s)")
        fi
        if [[ ${#BATS_FAILED_TESTS[@]} -gt 0 ]]; then
            failure_parts+=("${#BATS_FAILED_TESTS[@]} bats test(s)")
        elif [[ ${BATS_EXIT_CODE:-0} -ne 0 ]]; then
            failure_parts+=("incomplete bats run (exit ${BATS_EXIT_CODE})")
        fi
        local joined=""
        if [[ ${#failure_parts[@]} -eq 2 ]]; then
            joined="${failure_parts[0]} and ${failure_parts[1]}"
        elif [[ ${#failure_parts[@]} -eq 1 ]]; then
            joined="${failure_parts[0]}"
        fi
        echo "❌ Validation failed: $joined"
    fi
}

#######################################
# print_bats_output: Print bats results (full or failures-only)
#
# Description:
#   In verbose mode, prints full bats output. Otherwise prints only failing
#   test blocks and the final summary line.
#
# Globals:
#   VERBOSE - Enable verbose output
#   BATS_FAILED_TESTS - Populated with "file: test name" entries on failure
#   BATS_SUMMARY - Final "N tests, ..." summary line
#
# Arguments:
#   $1 - Path to captured bats TAP output file
#   $2 - Bats exit code
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   print_bats_output "/tmp/bats.out" 1
#
#######################################
function print_bats_output {
    local output_file="$1"
    local bats_exit="$2"

    collect_bats_failures_from_tap "$output_file"

    if [[ $VERBOSE == "true" ]]; then
        cat "$output_file"
        return
    fi

    if [[ $bats_exit -eq 0 ]]; then
        if [[ -n $BATS_SUMMARY ]]; then
            echo "$BATS_SUMMARY"
        else
            echo "Bats tests passed"
        fi
        return
    fi

    local in_failure=false
    while IFS= read -r line || [[ -n $line ]]; do
        case "$line" in
            not\ ok\ *)
                in_failure=true
                echo "$line"
                ;;
            ok\ *)
                in_failure=false
                ;;
            \#*)
                if [[ $in_failure == "true" ]]; then
                    echo "$line"
                fi
                ;;
        esac
    done < "$output_file"

    if [[ -n $BATS_SUMMARY ]]; then
        echo ""
        echo "$BATS_SUMMARY"
    fi
}

#######################################
# collect_bats_failures_from_tap: Populate BATS_FAILED_TESTS from TAP output
#
# Description:
#   Parses bats TAP-format output and records failing tests.
#
# Globals:
#   BATS_FAILED_TESTS - Populated with "file: test name" entries
#   BATS_SUMMARY - Human-readable test count summary
#
# Arguments:
#   $1 - Path to captured bats TAP output file
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   collect_bats_failures_from_tap "/tmp/bats.out"
#
#######################################
function collect_bats_failures_from_tap {
    local output_file="$1"
    local current_test=""
    local current_file=""
    local ok_count=0
    local fail_count=0
    local skip_count=0
    local total_count=0

    BATS_FAILED_TESTS=()
    BATS_SUMMARY=""

    while IFS= read -r line || [[ -n $line ]]; do
        case "$line" in
            1..*)
                total_count="${line#1..}"
                ;;
            ok\ *)
                ok_count=$((ok_count + 1))
                if [[ $line == *"# skip"* ]]; then
                    skip_count=$((skip_count + 1))
                fi
                ;;
            not\ ok\ *)
                fail_count=$((fail_count + 1))
                current_test="${line#not ok }"
                current_test="${current_test#* }"
                ;;
            \#\ \(in\ test\ file\ *)
                current_file="${line#\# (in test file }"
                current_file="${current_file%%, line*}"
                if [[ -n $current_test && -n $current_file ]]; then
                    BATS_FAILED_TESTS+=("${current_file}: ${current_test}")
                    current_test=""
                fi
                ;;
        esac
    done < "$output_file"

    if [[ $total_count -gt 0 ]]; then
        if [[ $fail_count -eq 0 ]]; then
            if [[ $skip_count -gt 0 ]]; then
                BATS_SUMMARY="${total_count} tests, 0 failures, ${skip_count} skipped"
            else
                BATS_SUMMARY="${total_count} tests passed"
            fi
        else
            if [[ $skip_count -gt 0 ]]; then
                BATS_SUMMARY="${total_count} tests, ${fail_count} failures, ${skip_count} skipped"
            else
                BATS_SUMMARY="${total_count} tests, ${fail_count} failures"
            fi
        fi
    fi
}

#######################################
# run_bats_tests: Run bats test files given as arguments
#
# Description:
#   Run bats test files given as arguments
#
# Globals:
#   WORKSPACE_ROOT - Workspace root directory
#
# Arguments:
#   $@ - List of test files
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   run_bats_tests "test1.bats" "test2.bats"
#
#######################################
function run_bats_tests {
    local tests=("$@")

    if [[ ${#tests[@]} -eq 0 ]]; then
        custom_log "DEBUG" "No bats tests found"
        return 0
    fi

    # Detect bats binary (bats or bats-core)
    local bats_bin=""
    if command -v bats &> /dev/null; then
        bats_bin="bats"
    elif command -v bats-core &> /dev/null; then
        bats_bin="bats-core"
    fi

    if [[ -z $bats_bin ]]; then
        custom_log "WARN" "Bats not found; skipping Bats tests"
        return 0
    fi

    custom_log "INFO" "Running Bats tests with: $bats_bin"

    local bats_output
    bats_output=$(mktemp)
    local bats_exit=0

    # Prefer running the test folder directly if present; run with -r to recurse into subdirectories
    if [[ -d "$WORKSPACE_ROOT/test/bats" ]]; then
        pushd "$WORKSPACE_ROOT" > /dev/null || return 1
        if "$bats_bin" -r "test/bats" --formatter tap > "$bats_output" 2>&1; then
            bats_exit=0
        else
            bats_exit=$?
        fi
        popd > /dev/null || true
    elif "$bats_bin" "${tests[@]}" --formatter tap > "$bats_output" 2>&1; then
        bats_exit=0
    else
        bats_exit=$?
    fi

    print_bats_output "$bats_output" "$bats_exit"
    rm -f "$bats_output"

    BATS_EXIT_CODE=$bats_exit

    if [[ $bats_exit -eq 0 ]]; then
        custom_log "INFO" "Bats tests passed"
        return 0
    elif [[ ${#BATS_FAILED_TESTS[@]} -gt 0 ]]; then
        custom_log "ERROR" "Bats tests failed (${#BATS_FAILED_TESTS[@]} failure(s))"
        return 1
    else
        custom_log "ERROR" "Bats tests exited with status ${bats_exit} (no failing tests recorded; run may have been interrupted)"
        return 1
    fi
}

#######################################
# run_shellcheck: Function to run shellcheck
#
# Description:
#   Function to run shellcheck
#
# Globals:
#   VERBOSE - Enable verbose output
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   run_shellcheck "/path/to/script.sh"
#
#######################################
function run_shellcheck {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    custom_log "DEBUG" "Running shellcheck for: $script_name"

    local shellcheck_output
    if shellcheck_output=$(shellcheck -e SC1091 -f gcc "$script" 2>&1); then
        custom_log "DEBUG" "✅ Shellcheck passed: $script_name"
        return 0
    else
        custom_log "WARN" "⚠️  Shellcheck issues found: $script"
        if [[ $VERBOSE == "true" ]]; then
            echo "Shellcheck output:"
            # shellcheck disable=SC2001
            echo "$shellcheck_output" | sed 's/^/  /'
        fi
        return 1
    fi
}

#######################################
# validate_permissions: Function to validate file permissions
#
# Description:
#   Function to validate file permissions
#
# Globals:
#   AUTO_FIX - Enable auto-fix mode
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_permissions "/path/to/script.sh"
#
#######################################
function validate_permissions {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    custom_log "DEBUG" "Validating permissions for: $script_name"

    if [[ $script == *.bats ]]; then
        custom_log "DEBUG" "Skipping executable check for Bats file: $script_name"
        return 0
    fi

    if [[ -x $script ]]; then
        custom_log "DEBUG" "✅ Script is executable: $script_name"
        return 0
    else
        custom_log "WARN" "⚠️  Script is not executable: $script_name"
        if [[ $AUTO_FIX == "true" ]]; then
            custom_log "INFO" "Auto-fixing permissions for: $script_name"
            chmod +x "$script"
            custom_log "INFO" "✅ Made executable: $script_name"
        fi
        return 1
    fi
}

#######################################
# validate_script: Function to validate a single script
#
# Description:
#   Function to validate a single script
#
# Globals:
#   WORKSPACE_ROOT - Workspace root directory
#   TOTAL_SCRIPTS - Total scripts counter
#   PASSED_SCRIPTS - Passed scripts counter
#   FAILED_SCRIPTS - Failed scripts counter
#   PASSED_SCRIPTS_LIST - List of passed scripts
#   FAILED_SCRIPTS_LIST - List of failed scripts
#   WARNING_SCRIPTS_LIST - List of warning scripts
#   VERBOSE - Enable verbose output
#   AUTO_FIX - Enable auto-fix mode
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_script "/path/to/script.sh"
#
#######################################
function validate_script {
    local script
    script="$(normalize_path "$1")"
    local script_name
    script_name="$(basename "$script")"
    local relative_path
    # shellcheck disable=SC2295
    relative_path="${script#$WORKSPACE_ROOT/}"
    local validation_passed=true

    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))

    custom_log "INFO" "Validating script: $relative_path"

    # Skip if it's a directory (should not happen after filtering, but safety check)
    if [[ -d $script ]]; then
        custom_log "DEBUG" "Skipping directory: $script_name"
        TOTAL_SCRIPTS=$((TOTAL_SCRIPTS - 1)) # Don't count directories
        return 0
    fi

    # Check if file exists and is readable
    if [[ ! -f $script ]] || [[ ! -r $script ]]; then
        custom_log "ERROR" "❌ Script not accessible: $script_name"
        FAILED_SCRIPTS_LIST+=("$relative_path (not accessible)")
        FAILED_SCRIPTS=$((FAILED_SCRIPTS + 1))
        return 1
    fi

    # Apply auto-formatting with shfmt if in fix mode
    auto_fix_formatting "$script"

    # Validate shebang
    if ! validate_shebang "$script"; then
        validation_passed=false
    fi

    # Validate permissions
    if ! validate_permissions "$script"; then
        validation_passed=false
    fi

    # Validate syntax
    if ! validate_syntax "$script"; then
        validation_passed=false
    fi

    # Run shellcheck
    local shellcheck_passed=true
    if ! run_shellcheck "$script"; then
        shellcheck_passed=false
        validation_passed=false
    fi

    # Optional project function doc block checks
    if ! validate_function_docs "$script"; then
        validation_passed=false
    fi

    # Analyze functions (verbose mode only)
    analyze_functions "$script"

    # Check complexity (verbose mode only)
    check_complexity "$script"

    # Update counters and arrays
    if [[ $validation_passed == "true" ]]; then
        custom_log "INFO" "✅ All validations passed: $script_name"
        PASSED_SCRIPTS_LIST+=("$relative_path")
        PASSED_SCRIPTS=$((PASSED_SCRIPTS + 1))
    else
        custom_log "ERROR" "❌ Validation failed: $script"
        FAILED_SCRIPTS_LIST+=("$relative_path")
        FAILED_SCRIPTS=$((FAILED_SCRIPTS + 1))
    fi

    # Track warnings separately
    if [[ $shellcheck_passed == "false" ]] && [[ $validation_passed == "true" ]]; then
        WARNING_SCRIPTS_LIST+=("$relative_path (shellcheck warnings)")
    fi
}

#######################################
# validate_shebang: Function to validate shebang
#
# Description:
#   Function to validate shebang
#
# Globals:
#   AUTO_FIX - Enable auto-fix mode
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_shebang "/path/to/script.sh"
#
#######################################
function validate_shebang {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    custom_log "DEBUG" "Validating shebang for: $script_name"

    local first_line
    first_line=$(head -1 "$script" 2> /dev/null)

    if [[ $first_line =~ ^#!/.*sh ]] || [[ $first_line =~ ^#!/.*bats ]]; then
        custom_log "DEBUG" "✅ Valid shebang: $script_name ($first_line)"
        return 0
    elif [[ $first_line =~ ^#! ]]; then
        custom_log "WARN" "⚠️  Non-shell shebang: $script_name ($first_line)"
        return 1
    else
        custom_log "WARN" "⚠️  Missing or invalid shebang: $script_name"
        if [[ $AUTO_FIX == "true" ]]; then
            custom_log "INFO" "Auto-fixing shebang for: $script_name"
            # Create backup and add shebang with error handling
            if ! cp "$script" "$script.bak"; then
                custom_log "ERROR" "Failed to create backup: $script_name"
                return 1
            fi
            if ! echo "#!/bin/bash" > "$script.tmp"; then
                custom_log "ERROR" "Failed to write temp file: $script_name"
                rm -f "$script.bak"
                return 1
            fi
            if ! cat "$script.bak" >> "$script.tmp"; then
                custom_log "ERROR" "Failed to append content: $script_name"
                rm -f "$script.bak" "$script.tmp"
                return 1
            fi
            if ! mv "$script.tmp" "$script"; then
                custom_log "ERROR" "Failed to replace original file: $script_name"
                rm -f "$script.tmp"
                # Restore from backup
                mv "$script.bak" "$script" 2> /dev/null
                return 1
            fi
            rm -f "$script.bak"
            custom_log "INFO" "✅ Added shebang to: $script_name"
        fi
        return 1
    fi
}

#######################################
# extract_function_doc_block: Read doc comment block immediately above a function
#
# Description:
#   Returns lines from the nearest preceding separator through the line before
#   the function definition.
#
# Globals:
#   None
#
# Arguments:
#   $1 - Script path
#   $2 - Function definition line number
#
# Outputs:
#   Doc block lines to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   extract_function_doc_block "/path/to/script.sh" 42
#
#######################################
function extract_function_doc_block {
    local script="$1"
    local func_line="$2"
    local i=$((func_line - 1))
    local end=$i
    local start=1
    local line

    while [[ $i -ge 1 ]]; do
        line="$(sed -n "${i}p" "$script")"
        if [[ -z ${line//[[:space:]]/} ]]; then
            i=$((i - 1))
            continue
        fi
        if [[ ${line} == "#######################################" ]]; then
            end=$i
            i=$((i - 1))
            break
        fi
        break
    done

    while [[ $i -ge 1 ]]; do
        line="$(sed -n "${i}p" "$script")"
        if [[ ${line} == "#######################################" ]]; then
            start=$i
            break
        fi
        i=$((i - 1))
    done

    sed -n "${start},${end}p" "$script"
}

#######################################
# function_doc_section_issues: Report missing Google-style function doc sections
#
# Description:
#   Validates Globals, Arguments, Outputs, and Returns with explicit body lines.
#
# Globals:
#   None
#
# Arguments:
#   $1 - Doc block text
#   $2 - Function signature reference (for error messages)
#
# Outputs:
#   Issue strings to stdout (one per line)
#
# Returns:
#   0 always
#
# Usage:
#   function_doc_section_issues "${doc_chunk}" "function foo {"
#
#######################################
function function_doc_section_issues {
    local doc_chunk="$1"
    local func_ref="$2"

    awk -v func_ref="${func_ref}" '
        BEGIN {
            n = split("Globals Arguments Outputs Returns", sections, " ")
        }
        {
            line_count++
            lines[line_count] = $0
        }
        function section_body_missing(sec,    i, in_sec) {
            in_sec = 0
            for (i = 1; i <= line_count; i++) {
                if (lines[i] ~ "^# " sec ":[[:space:]]*$") {
                    in_sec = 1
                    continue
                }
                if (in_sec == 1) {
                    if (lines[i] ~ /^# [A-Za-z][A-Za-z ]*:[[:space:]]*$/) {
                        return 1
                    }
                    if (lines[i] ~ /^#[[:space:]]+[^[:space:]#]/) {
                        return 0
                    }
                }
            }
            return 1
        }
        END {
            for (i = 1; i <= n; i++) {
                sec = sections[i]
                found = 0
                for (j = 1; j <= line_count; j++) {
                    if (lines[j] ~ "^# " sec ":[[:space:]]*$") {
                        found = 1
                        break
                    }
                }
                if (!found) {
                    print "missing " sec " section"
                    continue
                }
                if (section_body_missing(sec)) {
                    print sec " section has no body (use None)"
                }
            }
        }
    ' <<< "${doc_chunk}"
}

#######################################
# format_function_doc_issue: Format a function doc issue for terminal navigation
#
# Globals:
#   None
#
# Arguments:
#   $1 - Script path
#   $2 - Line number
#   $3 - Issue message
#
# Outputs:
#   file:line: message to stdout
#
# Returns:
#   0 on success
#######################################
function normalize_path {
    local path="$1"

    if [[ -z $path ]]; then
        return 1
    fi

    if [[ -e $path ]]; then
        realpath "$path"
        return 0
    fi

    local dir base
    dir="$(dirname "$path")"
    base="$(basename "$path")"
    if [[ -d $dir ]]; then
        printf '%s/%s' "$(realpath "$dir")" "$base"
    else
        realpath -m "$path"
    fi
}

function format_function_doc_issue {
    local script
    script="$(normalize_path "$1")"
    printf '%s:%s: %s' "$script" "$2" "$3"
}

#######################################
# validate_function_docs: Opt-in Google-style function documentation checks
#
# Description:
#   When CHECK_FUNCTION_DOCS is true, verify each function has a preceding doc
#   block with Globals, Arguments, Outputs, and Returns (explicit None allowed).
#
# Globals:
#   CHECK_FUNCTION_DOCS - Enable function doc block section checks
#   VERBOSE - Enable verbose output
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_function_docs "/path/to/script.sh"
#
#######################################
function validate_function_docs {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    if [[ $CHECK_FUNCTION_DOCS != "true" ]]; then
        return 0
    fi

    if [[ $script == *.bats ]]; then
        return 0
    fi

    custom_log "DEBUG" "Validating function doc blocks for: $script_name"

    local line_num func_sig doc_chunk issue
    local -a missing=()
    while IFS= read -r line_num; do
        [[ -z ${line_num} ]] && continue
        func_sig="$(sed -n "${line_num}p" "$script")"
        doc_chunk="$(extract_function_doc_block "$script" "$line_num")"

        if ! grep -E '^# .+' <<< "${doc_chunk}" | grep -qvE '^# (Globals|Arguments|Outputs|Returns):'; then
            missing+=("$(format_function_doc_issue "$script" "$line_num" "missing function description line")")
            continue
        fi

        while IFS= read -r issue; do
            [[ -z ${issue} ]] && continue
            missing+=("$(format_function_doc_issue "$script" "$line_num" "$issue")")
        done < <(function_doc_section_issues "${doc_chunk}" "${func_sig}")
    done < <(grep -nE '^function [a-zA-Z_][a-zA-Z0-9_]*(\(\))? \{' "$script" 2> /dev/null | cut -d: -f1 || true)

    if [[ ${#missing[@]} -gt 0 ]]; then
        custom_log "ERROR" "❌ Function doc block validation failed: $script_name"
        printf '%s\n' "${missing[@]}" >&2
        return 1
    fi

    custom_log "DEBUG" "✅ Function doc block validation passed: $script_name"
    return 0
}

#######################################
# validate_syntax: Function to validate script syntax
#
# Description:
#   Function to validate script syntax
#
# Globals:
#   VERBOSE - Enable verbose output
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_syntax "/path/to/script.sh"
#
#######################################
function validate_syntax {
    local script="$1"
    local script_name
    script_name="$(basename "$script")"

    custom_log "DEBUG" "Validating syntax for: $script_name"

    if [[ $script == *.bats ]]; then
        custom_log "DEBUG" "Skipping bash syntax validation for Bats file: $script_name"
        return 0
    fi

    if bash -n "$script" 2> /dev/null; then
        custom_log "DEBUG" "✅ Syntax validation passed: $script_name"
        return 0
    else
        local error_output
        error_output=$(bash -n "$script" 2>&1)
        custom_log "ERROR" "❌ Syntax validation failed: $script_name"
        if [[ $VERBOSE == "true" ]]; then
            echo "Syntax errors:"
            # shellcheck disable=SC2001
            echo "$error_output" | sed 's/^/  /'
        fi
        return 1
    fi
}

#######################################
# main: Main process
#
# Description:
#   Main process
#
# Globals:
#   WORKSPACE_ROOT - Workspace root directory
#   AUTO_FIX - Enable auto-fix mode
#   VERBOSE - Enable verbose output
#   QUIET - Suppress non-error output
#   FAILED_SCRIPTS - Counter for failed scripts
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # If no search paths provided, default to workspace root
    if [[ ${#SEARCH_PATHS[@]} -eq 0 ]]; then
        SEARCH_PATHS=("$WORKSPACE_ROOT")
    fi

    # Validate dependencies
    validate_dependencies "bash" "find" "grep" "sed" "shellcheck" "shfmt"

    # Ensure a bats test runner exists (bats or bats-core)
    if ! command -v bats &> /dev/null && ! command -v bats-core &> /dev/null; then
        error_exit "Missing required test runner: install 'bats' or 'bats-core' to run tests"
    fi

    # Log script start
    custom_echo_section "Comprehensive Script Validation Tool"
    custom_log "INFO" "Workspace root: $WORKSPACE_ROOT"
    custom_log "INFO" "Auto-fix mode: $AUTO_FIX"
    custom_log "INFO" "Verbose mode: $VERBOSE"
    custom_log "INFO" "Quiet mode: $QUIET"
    custom_log "INFO" "Function doc checks: $CHECK_FUNCTION_DOCS"

    # Find all shell scripts
    custom_echo_section "Script Discovery"
    local scripts
    readarray -t scripts < <(find_shell_scripts)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        custom_log "WARN" "No shell scripts found in the workspace"
        exit 0
    fi

    custom_log "INFO" "Found ${#scripts[@]} shell scripts to validate"

    # Validate each script
    custom_echo_section "Script Validation"
    for script in "${scripts[@]}"; do
        validate_script "$script"
    done

    # Run Bats tests (if enabled or if auto-detected)
    custom_echo_section "Bats Tests"
    mapfile -t bats_files < <(find_bats_tests)
    if [[ ${#bats_files[@]} -gt 0 ]]; then
        # Run Bats tests; failures are tracked in BATS_FAILED_TESTS
        run_bats_tests "${bats_files[@]}" || true
    else
        custom_log "INFO" "No bats tests found to run"
    fi

    # Generate summary report (after running tests so failures are included)
    generate_summary_report

    # Generate recommendations
    generate_recommendations

    custom_echo_section "Validation Complete"

    # Exit with appropriate code
    if [[ $FAILED_SCRIPTS -gt 0 ]] || [[ ${#BATS_FAILED_TESTS[@]} -gt 0 ]] || [[ ${BATS_EXIT_CODE:-0} -ne 0 ]]; then
        exit 1
    fi
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
