#!/bin/bash
#######################################
# Description: Comprehensive Go code quality and testing script for Go projects
#
# Usage: ./validate.sh [options] <directory>
#   options:
#     -h, --help     Display this help message
#     -v, --verbose  Enable verbose output
#     -d, --dry-run  Run in dry-run mode (no changes made)
#     -f, --fix      Automatically fix issues where possible
#   arguments:
#     directory      Package or directory to validate
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load common libraries - ALWAYS use this pattern
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
TARGET_PATTERN="./..."
COVERAGE_THRESHOLD=80
EXIT_CODE=0
# 新規: スコープ実行フラグ (特定ディレクトリのみ)
IS_SCOPED=false

# Flags for individual checks
GO_FMT_FAILED=0
GO_VET_FAILED=0
LINT_FAILED=0
TEST_FAILED=0
RACE_FAILED=0
COVERAGE_FAILED=0
SECURITY_FAILED=0
GO_BUILD_FAILED=0

# Counters for issues
LINT_ISSUES_COUNT=0
TEST_FAIL_COUNT=0
COVERAGE_PERCENT=""

# Functions are now provided by common.sh library

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
Usage: $(basename "$0") [options]

Description: Comprehensive Go code quality and testing script for Go projects
             Automatically detects Go directories if no specific target is provided

Options:
  -h, --help     Display this help message
  -v, --verbose  Enable verbose output and benchmark tests
  -d, --dry-run  Run in dry-run mode (no changes made)
  -f, --fix      Automatically fix issues where possible

Arguments:
  directory      Target directory to check (optional)
                 If not provided, auto-detects all Go directories
                 Use './...' to check all packages recursively

Examples:
  $(basename "$0")                                    # Auto-detect all Go directories
  $(basename "$0") -v                                 # Auto-detect with verbose output
  $(basename "$0") -f ./cmd/cloudwatch                # Check specific directory with auto-fix
  $(basename "$0") -v -f ./...                        # Check all packages recursively
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
    if [[ -z "${TARGET_DIR:-}" ]]; then
        TARGET_DIR="."
        log "INFO" "No target specified, will auto-detect Go directories from current location"
    fi
    if [[ "$TARGET_DIR" != "./..." && ! -d "$TARGET_DIR" && "$TARGET_DIR" != "." ]]; then
        error_exit "Target directory does not exist: $TARGET_DIR"
    fi
    if [[ "$TARGET_DIR" != "." && "$TARGET_DIR" != "./..." ]]; then
        IS_SCOPED=true
    fi
}

# Dependencies validation is now handled by common.sh library

#######################################
# determine_target_pattern: Determine target pattern for Go tools
#
# Description:
#   Determines the appropriate target pattern for Go tools based on the input directory
#
# Arguments:
#   $1 - Base directory (optional, defaults to current directory)
#
# Returns:
#   Target pattern string (to stdout)
#
# Usage:
#   pattern=$(determine_target_pattern "/path/to/dir")
#
#######################################
function determine_target_pattern {
    local base_dir=${1:-.}

    # If ./... is specified, use it as-is
    if [[ "$base_dir" == "./..." ]]; then
        echo "./..."
        return 0
    fi

    # If a specific directory is provided and it exists
    if [[ -d "$base_dir" && "$base_dir" != "." ]]; then
        local go_files_count
        go_files_count=$(has_go_files "$base_dir")
        if [[ "$go_files_count" -gt 0 ]]; then
            echo "$base_dir/..."
            return 0
        fi
    fi

    # For current directory, check if there are Go files
    local go_files_count
    go_files_count=$(find . -name "*.go" -not -path "./vendor/*" -not -path "./.*" | wc -l)

    if [[ "$go_files_count" -eq 0 ]]; then
        error_exit "No Go files found in $base_dir or its subdirectories"
    fi

    # Use ./... for recursive processing from current directory
    echo "./..."
}

#######################################
# run_benchmark_tests: Run benchmark tests
#
# Description:
#   Runs benchmark tests if they exist in the codebase
#
# Arguments:
#   None
#
# Returns:
#   None
#
# Usage:
#   run_benchmark_tests
#
#######################################
function run_benchmark_tests {
    echo_section "Running benchmark tests"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run benchmark tests"
        return 0
    fi

    # Check if there are any benchmark tests
    local has_benchmarks
    has_benchmarks=$(find . -name "*_test.go" -not -path "./vendor/*" -not -path "./.*" -exec grep -l "func Benchmark" {} + 2> /dev/null | head -1 || true)

    if [[ -n "$has_benchmarks" ]]; then
        log "INFO" "Running benchmark tests..."
        if go test -bench=. -benchmem "$TARGET_PATTERN" > /dev/null 2>&1; then
            log "INFO" "Benchmark tests completed"
            if [[ "$VERBOSE" == "true" ]]; then
                go test -bench=. -benchmem "$TARGET_PATTERN"
            fi
        else
            log "WARN" "Some benchmark tests failed"
        fi
    else
        log "INFO" "No benchmark tests found"
    fi
}

#######################################
# run_coverage_tests: Run coverage tests
#
# Description:
#   Runs go test with coverage analysis and checks against threshold
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and COVERAGE_FAILED on failure)
#
# Usage:
#   run_coverage_tests
#
#######################################
function run_coverage_tests {
    echo_section "Running coverage tests"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run coverage tests for $TARGET_PATTERN"
        return 0
    fi

    local coverage_file
    coverage_file=$(mktemp /tmp/coverage.XXXXXX.out) || {
        log "ERROR" "Failed to create temporary coverage file"
        EXIT_CODE=1
        return 1
    }
    if go test -coverprofile="$coverage_file" "$TARGET_PATTERN"; then
        local coverage_percent
        local coverage_output
        coverage_output=$(go tool cover -func="$coverage_file" | grep total | awk '{print $3}')
        coverage_percent=${coverage_output%\%}
        COVERAGE_PERCENT="$coverage_percent"

        if [[ -n "$coverage_percent" ]]; then
            echo "Coverage: ${coverage_percent}%"

            # Compare coverage using awk for better compatibility
            if awk "BEGIN {exit !($coverage_percent >= $COVERAGE_THRESHOLD)}"; then
                log "INFO" "Coverage ($coverage_percent%) meets threshold ($COVERAGE_THRESHOLD%)"
            else
                log "WARN" "Coverage ($coverage_percent%) below threshold ($COVERAGE_THRESHOLD%)"
                EXIT_CODE=1
                COVERAGE_FAILED=1
            fi

            if [[ "$VERBOSE" == "true" ]]; then
                echo "Detailed coverage report:"
                go tool cover -func="$coverage_file"
            fi
        else
            log "WARN" "Could not determine coverage percentage"
        fi

        # Cleanup
        rm -f "$coverage_file"
    else
        log "ERROR" "Coverage tests failed"
        EXIT_CODE=1
        COVERAGE_FAILED=1
    fi
}

#######################################
# run_go_build: Run go build
#
# Description:
#   Runs go build to check if the code compiles successfully
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and GO_BUILD_FAILED on failure)
#
# Usage:
#   run_go_build
#
#######################################
function run_go_build {
    echo_section "Running go build"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go build \"$TARGET_PATTERN\"'"
        return 0
    fi

    # Attempt to build all packages matching the target pattern
    if go build "$TARGET_PATTERN"; then
        log "INFO" "go build succeeded"
    else
        log "ERROR" "go build failed"
        EXIT_CODE=1
        GO_BUILD_FAILED=1
    fi
}

#######################################
# has_go_files: Check if directory contains Go files
#
# Description:
#   Checks if the specified directory contains any Go files
#
# Arguments:
#   $1 - Directory path to check
#
# Returns:
#   Number of Go files found (integer)
#
# Usage:
#   count=$(has_go_files "/path/to/dir")
#
#######################################
function has_go_files {
    local dir=$1
    find "$dir" -name "*.go" 2> /dev/null | wc -l
}

#######################################
# run_go_fmt: Run go fmt
#
# Description:
#   Runs go fmt to format Go code or checks formatting compliance
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and GO_FMT_FAILED on failure)
#
# Usage:
#   run_go_fmt
#
#######################################
function run_go_fmt {
    echo_section "Running go fmt"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go fmt $TARGET_PATTERN'"
        return 0
    fi

    # Use go fmt instead of gofmt for better Go module support
    if [[ "$FIX_MODE" == "true" ]]; then
        log "INFO" "Automatically formatting files..."
        if go fmt "$TARGET_PATTERN"; then
            log "INFO" "Files formatted successfully"
        else
            log "ERROR" "go fmt failed"
            EXIT_CODE=1
            GO_FMT_FAILED=1
        fi
    else
        # Check formatting using gofmt -l to list files that are not formatted
        # Use go list + mapfile instead of direct gofmt to avoid word splitting issues
        # with complex package patterns and ensure proper handling of module directories
        local fmt_output
        # Safely build argument list from go list output to avoid word splitting
        mapfile -t go_dirs < <(go list -f '{{.Dir}}' "$TARGET_PATTERN" 2> /dev/null || true)
        if [[ ${#go_dirs[@]} -eq 0 ]]; then
            fmt_output=""
        else
            fmt_output=$(gofmt -l "${go_dirs[@]}" 2>&1 || true)
        fi
        if [[ -n "$fmt_output" ]]; then
            echo "Files that need formatting (gofmt -l):"
            echo "$fmt_output"
            log "WARN" "Some files need formatting. Use -f flag to auto-fix"
            EXIT_CODE=1
            GO_FMT_FAILED=1
        else
            log "INFO" "All files are properly formatted"
        fi
    fi
}

#######################################
# run_go_mod_tidy: Run go mod tidy
#
# Description:
#   Runs go mod tidy to clean up the go.mod and go.sum files
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE on failure)
#
# Usage:
#   run_go_mod_tidy
#
#######################################
function run_go_mod_tidy {
    echo_section "Running go mod tidy"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go mod tidy'"
        return 0
    fi

    # 特定ディレクトリ指定時はそのディレクトリ内に go.mod がある場合のみ実行
    local mod_dir="."
    if [[ "$IS_SCOPED" == "true" ]]; then
        if [[ -f "$TARGET_DIR/go.mod" ]]; then
            mod_dir="$TARGET_DIR"
        else
            log "INFO" "Skipping go mod tidy (no go.mod in scoped directory: $TARGET_DIR)"
            return 0
        fi
    fi

    pushd "$mod_dir" > /dev/null || {
        log "ERROR" "Failed to change directory to: $mod_dir"
        EXIT_CODE=1
        return 1
    }
    if go mod tidy; then
        log "INFO" "go mod tidy completed successfully (dir=$mod_dir)"
    else
        log "ERROR" "go mod tidy failed (dir=$mod_dir)"
        EXIT_CODE=1
    fi
    popd > /dev/null || true
}

#######################################
# run_go_vet: Run go vet
#
# Description:
#   Runs go vet to check for common Go programming errors
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and GO_VET_FAILED on failure)
#
# Usage:
#   run_go_vet
#
#######################################
function run_go_vet {
    echo_section "Running go vet"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go vet $TARGET_PATTERN'"
        return 0
    fi

    if go vet "$TARGET_PATTERN"; then
        log "INFO" "go vet passed"
    else
        log "ERROR" "go vet found issues"
        EXIT_CODE=1
        GO_VET_FAILED=1
    fi
}

#######################################
# run_golangci_lint: Run golangci-lint
#
# Description:
#   Runs golangci-lint to perform comprehensive code linting
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and LINT_FAILED on failure)
#
# Usage:
#   run_golangci_lint
#
#######################################
function run_golangci_lint {
    echo_section "Running golangci-lint"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'golangci-lint run $TARGET_PATTERN'"
        return 0
    fi

    local lint_args=("run" "--disable" "gocognit")

    if [[ "$FIX_MODE" == "true" ]]; then
        lint_args+=("--fix")
    fi

    if [[ "$VERBOSE" == "true" ]]; then
        lint_args+=("-v")
    fi

    lint_args+=("$TARGET_PATTERN")

    local lint_output
    lint_output=$(mktemp /tmp/golint_output.XXXXXX.txt) || {
        log "ERROR" "Failed to create temporary lint output file"
        EXIT_CODE=1
        return 1
    }

    if golangci-lint "${lint_args[@]}" 2>&1 | tee "$lint_output"; then
        log "INFO" "golangci-lint passed"
        LINT_ISSUES_COUNT=0
    else
        log "ERROR" "golangci-lint found issues"
        EXIT_CODE=1
        LINT_FAILED=1
        # Count issues
        if [[ -f "$lint_output" ]]; then
            LINT_ISSUES_COUNT=$(grep -cE '^\S+\.go:' "$lint_output" 2> /dev/null || echo 0)
            # Normalize to first token (avoid any unexpected whitespace/newlines)
            LINT_ISSUES_COUNT=$(echo "$LINT_ISSUES_COUNT" | awk '{print $1}')
        else
            LINT_ISSUES_COUNT=0
        fi
        # Ensure it's a valid number
        if ! [[ "$LINT_ISSUES_COUNT" =~ ^[0-9]+$ ]]; then
            LINT_ISSUES_COUNT=0
        fi
    fi
    rm -f "$lint_output"
}

#######################################
# run_security_checks: Run security checks
#
# Description:
#   Runs security vulnerability checks using govulncheck
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and SECURITY_FAILED on failure)
#
# Usage:
#   run_security_checks
#
#######################################
function run_security_checks {
    echo_section "Running security checks"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run security checks"
        return 0
    fi

    local search_root="."
    if [[ "$IS_SCOPED" == "true" ]]; then
        search_root="$TARGET_DIR"
    fi

    # Check for govulncheck
    if command -v govulncheck &> /dev/null; then
        log "INFO" "Running govulncheck... (root=$search_root)"
        if govulncheck "$TARGET_PATTERN"; then
            log "INFO" "No known vulnerabilities found"
        else
            log "WARN" "Potential vulnerabilities found"
            EXIT_CODE=1
            SECURITY_FAILED=1
        fi
    else
        log "WARN" "govulncheck not installed, skipping vulnerability check"
        log "INFO" "Install with: go install golang.org/x/vuln/cmd/govulncheck@latest"
    fi
}

#######################################
# run_tests: Run tests
#
# Description:
#   Runs go test to execute unit tests
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and TEST_FAILED on failure)
#
# Usage:
#   run_tests
#
#######################################
function run_tests {
    echo_section "Running go test"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go test -v $TARGET_PATTERN'"
        return 0
    fi

    local test_args=("-v")

    if [[ "$VERBOSE" == "true" ]]; then
        test_args+=("-x")
    fi

    test_args+=("$TARGET_PATTERN")

    local test_output
    test_output=$(mktemp /tmp/gotest_output.XXXXXX.txt) || {
        log "ERROR" "Failed to create temporary test output file"
        EXIT_CODE=1
        return 1
    }

    if go test "${test_args[@]}" 2>&1 | tee "$test_output"; then
        log "INFO" "All tests passed"
        TEST_FAIL_COUNT=0
    else
        log "ERROR" "Some tests failed"
        EXIT_CODE=1
        TEST_FAILED=1
        # Count failed tests
        TEST_FAIL_COUNT=$(grep -c '^--- FAIL:' "$test_output" 2> /dev/null || echo 0)
        # Normalize to a single integer token to prevent arithmetic parsing errors
        TEST_FAIL_COUNT=$(echo "$TEST_FAIL_COUNT" | awk '{print $1}')
    fi
    rm -f "$test_output"
}

#######################################
# run_race_tests: Run race condition tests
#
# Description:
#   Runs go test with race detection enabled
#
# Arguments:
#   None
#
# Returns:
#   None (sets EXIT_CODE and RACE_FAILED on failure)
#
# Usage:
#   run_race_tests
#
#######################################
function run_race_tests {
    echo_section "Running race condition tests"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'CGO_ENABLED=1 go test -race $TARGET_PATTERN'"
        return 0
    fi

    if CGO_ENABLED=1 go test -race "$TARGET_PATTERN"; then
        log "INFO" "Race condition tests passed"
    else
        log "ERROR" "Race condition tests failed"
        EXIT_CODE=1
        RACE_FAILED=1
    fi
}

#######################################
# main: Main execution function
#
# Description:
#   Main entry point that orchestrates all code quality checks
#
# Arguments:
#   $@ - All command line arguments passed to the script
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
    validate_dependencies "go" "golangci-lint"
    TARGET_PATTERN=$(determine_target_pattern "$TARGET_DIR")
    echo_section "Starting Go code quality checks"
    log "INFO" "Target input: $TARGET_DIR"
    log "INFO" "Target pattern: $TARGET_PATTERN"
    log "INFO" "Scoped mode: $IS_SCOPED"
    log "INFO" "Verbose mode: $VERBOSE"
    log "INFO" "Dry-run mode: $DRY_RUN"
    log "INFO" "Fix mode: $FIX_MODE"
    run_go_mod_tidy
    run_go_fmt
    run_go_vet
    run_go_build
    run_golangci_lint
    run_tests
    run_race_tests
    run_coverage_tests
    run_security_checks
    if [[ "$VERBOSE" == "true" ]]; then
        run_benchmark_tests
    fi
    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    if [[ "$EXIT_CODE" -eq 0 ]]; then
        echo_section "All checks completed successfully in ${elapsed} seconds"
        log "INFO" "✅ All validations passed"
    else
        echo_section "Result (completed in ${elapsed} seconds)"
        echo "Result:" >&2
        [[ "$GO_FMT_FAILED" == "1" ]] && echo "❌ go fmt" >&2 || echo "✅ go fmt" >&2
        # Report go vet status
        [[ "$GO_VET_FAILED" == "1" ]] && echo "❌ go vet" >&2 || echo "✅ go vet" >&2

        # Report go build status next to keep result order consistent with run_* calls
        [[ "$GO_BUILD_FAILED" == "1" ]] && echo "❌ go build" >&2 || echo "✅ go build" >&2
        if [[ "$LINT_FAILED" == "1" ]]; then
            echo -n "❌ golangci-lint" >&2
            # Use safe arithmetic comparison with default 0 to avoid bash syntax errors
            local issue_count="${LINT_ISSUES_COUNT:-0}"
            if [[ "$issue_count" != "0" && "$issue_count" -gt 0 ]]; then
                echo " (${LINT_ISSUES_COUNT} issues)" >&2
            else
                echo "" >&2
            fi
        else
            echo "✅ golangci-lint" >&2
        fi
        if [[ "$TEST_FAILED" == "1" ]]; then
            echo -n "❌ go test" >&2
            # Use safe arithmetic comparison with default 0
            if ((${TEST_FAIL_COUNT:-0} > 0)); then
                echo " (${TEST_FAIL_COUNT} failed)" >&2
            else
                echo "" >&2
            fi
        else
            echo "✅ go test" >&2
        fi
        [[ "$RACE_FAILED" == "1" ]] && echo "❌ go test -race" >&2 || echo "✅ go test -race" >&2
        if [[ "$COVERAGE_FAILED" == "1" ]]; then
            if [[ -n "$COVERAGE_PERCENT" ]]; then
                echo "❌ go test -cover ($COVERAGE_PERCENT%)" >&2
            else
                echo "❌ go test -cover" >&2
            fi
        else
            if [[ -n "$COVERAGE_PERCENT" ]]; then
                echo "✅ go test -cover ($COVERAGE_PERCENT%)" >&2
            else
                echo "✅ go test -cover" >&2
            fi
        fi
        [[ "$SECURITY_FAILED" == "1" ]] && echo "❌ security checks (govulncheck)" >&2 || echo "✅ security checks (govulncheck)" >&2
        log "ERROR" "❌ Some validations failed"
    fi

    exit $EXIT_CODE
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
