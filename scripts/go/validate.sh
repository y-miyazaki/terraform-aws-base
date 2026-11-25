#!/bin/bash
#######################################
# Description: Comprehensive Go code quality and testing script for Go projects
#
# Usage: ./validate.sh [options] [directory]
#   options:
#     -h, --help       Display this help message
#     -v, --verbose    Enable verbose output
#     -d, --dry-run    Run in dry-run mode (no changes made)
#     -f, --fix        Automatically fix issues where possible
#         --skip-tests Skip go test, race, coverage, and benchmark checks
#         --changed-only Validate only packages with uncommitted git changes to .go, go.mod, or go.sum files (per go.mod module)
#   arguments:
#     directory        Package or directory to validate (optional; with --changed-only it narrows the changed set)
#
# Design Rules:
#   - Read-only by default: formatting and go.mod/go.sum changes are applied only with --fix.
#   - --dry-run prints the planned commands without running them.
#   - With a directory argument all checks are scoped to it; otherwise the whole repository is validated.
#   - Exits non-zero when any check fails.
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
TARGET_PATTERNS=("./...")
COVERAGE_THRESHOLD=80
EXIT_CODE=0
TEMP_FILES=()
# When true, limit checks to TARGET_DIR (not "." or "./...")
IS_SCOPED=false
SKIP_TESTS=false
# When true, validate only packages with uncommitted git changes to .go files
CHANGED_ONLY=false

# Flags for individual checks
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
# Number of modules whose checks ran under --changed-only
CHECKED_MODULES=0

# Functions are now provided by common.sh library

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

Description: Comprehensive Go code quality and testing script for Go projects
             Automatically detects Go directories if no specific target is provided

Options:
  -h, --help       Display this help message
  -v, --verbose    Enable verbose output and benchmark tests
  -d, --dry-run    Run in dry-run mode (no changes made)
  -f, --fix        Automatically fix issues where possible
      --skip-tests Skip go test, race, coverage, and benchmark checks
      --changed-only Only packages containing .go files with uncommitted git changes
                   (staged, unstaged, untracked), checked from inside the nearest go.mod
                   module; a changed go.mod/go.sum or a removed package validates its whole module
                   (a removed file in a surviving package selects that package);
                   a directory argument narrows the set

Arguments:
  directory        Target directory to check (optional)
                   If not provided, auto-detects all Go directories
                   Use './...' to check all packages recursively

Examples:
  $(basename "$0")                                    # Auto-detect all Go directories
  $(basename "$0") -v                                 # Auto-detect with verbose output
  $(basename "$0") -f ./cmd/cloudwatch                # Check specific directory with auto-fix
  $(basename "$0") -v -f ./...                        # Check all packages recursively
  $(basename "$0") --skip-tests ./cmd/foo             # Lint/build only
  $(basename "$0") --changed-only                     # Only packages with git changes
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
#   TARGET_DIR - Package or directory to validate
#   IS_SCOPED - Limit checks when TARGET_DIR is not "." or "./..."
#   SKIP_TESTS - Skip go test, race, coverage, and benchmark checks
#   CHANGED_ONLY - Limit checks to packages with uncommitted git changes
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
            -f | --fix)
                FIX_MODE=true
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --changed-only)
                CHANGED_ONLY=true
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
    if [[ -z ${TARGET_DIR:-} ]]; then
        TARGET_DIR="."
        log "INFO" "No target specified, will auto-detect Go directories from current location"
    fi
    if [[ $TARGET_DIR != "./..." && ! -d $TARGET_DIR && $TARGET_DIR != "." ]]; then
        error_exit "Target directory does not exist: $TARGET_DIR"
    fi
    if [[ $TARGET_DIR != "." && $TARGET_DIR != "./..." ]]; then
        IS_SCOPED=true
    fi
}

#######################################
# cleanup_temp_files: Remove temporary files created during validation
#
# Globals:
#   TEMP_FILES - Temporary files to remove
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#######################################
function cleanup_temp_files {
    local f
    for f in "${TEMP_FILES[@]}"; do
        rm -f "$f"
    done
}

#######################################
# determine_changed_patterns: List Go packages with uncommitted changes, grouped by module
#
# Description:
#   Emits "module<TAB>pattern" lines for every changed .go, go.mod, or go.sum file (staged,
#   unstaged, untracked). The module is the nearest directory at or above the file that holds a
#   go.mod; the pattern is relative to it: "." or "./sub" for a changed .go file (one
#   non-recursive package) and "./..." for a changed go.mod or go.sum (the whole module).
#   Files without a go.mod ancestor are skipped with a warning; testdata and vendor are skipped.
#
# Globals:
#   None
#
# Arguments:
#   $1 - Scope directory (optional; "." or "./..." means the whole repository)
#
# Outputs:
#   Tab-separated "module<TAB>pattern" lines to stdout, sorted and unique
#
# Returns:
#   0 on success
#
# Usage:
#   mapfile -t changed < <(determine_changed_patterns ./cmd)
#
#######################################
function determine_changed_patterns {
    local scope=${1:-.}
    local -a scopes=()
    if [[ $scope != "." && $scope != "./..." ]]; then
        scopes=("$scope")
    fi

    local file dir module pattern
    while IFS= read -r file; do
        [[ -z $file ]] && continue
        dir="$(dirname "$file")"
        case "/$dir/" in
            */testdata/* | */vendor/*) continue ;;
        esac
        if ! module="$(repo_nearest_ancestor_with "$dir" go.mod)"; then
            log "WARN" "--changed-only: no go.mod above $file, skipping" >&2
            continue
        fi
        if [[ ${file##*/} == go.mod || ${file##*/} == go.sum || ! -d $dir ]]; then
            # Dependency changes and removed packages can break any package of the module
            pattern="./..."
        elif [[ $dir == "$module" ]]; then
            pattern="."
        elif [[ $module == "." ]]; then
            pattern="./$dir"
        else
            pattern="./${dir#"$module"/}"
        fi
        printf '%s\t%s\n' "$module" "$pattern"
    done < <(REPO_PATHS_INCLUDE_DELETED=true repo_emit_changed_paths '\.go$|(^|/)go\.(mod|sum)$' ${scopes[@]+"${scopes[@]}"}) | sort -u
}

#######################################
# determine_target_pattern: Determine target pattern for Go tools
#
# Description:
#   Determines the appropriate target pattern for Go tools based on the input directory
#
# Globals:
#   None
#
# Arguments:
#   $1 - Base directory (optional, defaults to current directory)
#
# Outputs:
#   Target pattern string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   pattern=$(determine_target_pattern "/path/to/dir")
#
#######################################
function determine_target_pattern {
    local base_dir=${1:-.}

    # If ./... is specified, use it as-is
    if [[ $base_dir == "./..." ]]; then
        echo "./..."
        return 0
    fi

    # A specific directory must contain Go files; never fall back to validating the whole repository
    if [[ $base_dir != "." ]]; then
        if [[ ! -d $base_dir ]]; then
            error_exit "Directory not found: $base_dir"
        fi
        local go_files_count
        go_files_count=$(has_go_files "$base_dir")
        if [[ $go_files_count -gt 0 ]]; then
            if [[ $base_dir == /* ]]; then
                # An absolute path is already a valid package pattern; "./" would make it ".//abs"
                echo "${base_dir%/}/..."
            else
                echo "./${base_dir#./}/..."
            fi
            return 0
        fi
        error_exit "No Go files found in $base_dir or its subdirectories"
    fi

    # For current directory, check if there are Go files
    local go_files_count
    go_files_count=$(find . -name "*.go" -not -path "./vendor/*" -not -path "./.*" | wc -l)

    if [[ $go_files_count -eq 0 ]]; then
        error_exit "No Go files found in $base_dir or its subdirectories"
    fi

    # Use ./... for recursive processing from current directory
    echo "./..."
}

#######################################
# has_go_files: Check if directory contains Go files
#
# Description:
#   Checks if the specified directory contains any Go files
#
# Globals:
#   None
#
# Arguments:
#   $1 - Directory path to check
#
# Outputs:
#   None
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
# run_benchmark_tests: Run benchmark tests
#
# Description:
#   Runs benchmark tests if they exist in the codebase
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
#   None
#
# Usage:
#   run_benchmark_tests
#
#######################################
function run_benchmark_tests {
    echo_section "Running benchmark tests"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run benchmark tests"
        return 0
    fi

    # Check if there are any benchmark tests
    local has_benchmarks
    has_benchmarks=$(find . -name "*_test.go" -not -path "./vendor/*" -not -path "./.*" -exec grep -l "func Benchmark" {} + 2> /dev/null | head -1 || true)

    if [[ -n $has_benchmarks ]]; then
        log "INFO" "Running benchmark tests..."
        if go test -bench=. -benchmem "${TARGET_PATTERNS[@]}" > /dev/null 2>&1; then
            log "INFO" "Benchmark tests completed"
            if [[ $VERBOSE == "true" ]]; then
                go test -bench=. -benchmem "${TARGET_PATTERNS[@]}"
            fi
        else
            log "WARN" "Some benchmark tests failed"
        fi
    else
        log "INFO" "No benchmark tests found"
    fi
}

#######################################
# run_changed_modules: Run all checks once per changed Go module
#
# Description:
#   Groups "module<TAB>pattern" lines by module, then runs run_checks from inside each module
#   directory with the module's patterns. A "./..." pattern replaces the others of its module.
#
# Globals:
#   IS_SCOPED - Must be false: checks run from the module root
#   TARGET_PATTERNS - Set to the patterns of the module being checked
#   LINT_ISSUES_COUNT, TEST_FAIL_COUNT, COVERAGE_PERCENT - Replaced by totals across modules
#   (summed counts, lowest coverage; empty coverage when a module's coverage run failed)
#
# Arguments:
#   $@ - "module<TAB>pattern" lines sorted by module
#
# Outputs:
#   Progress logs and check results
#
# Returns:
#   0 on success
#
# Usage:
#   run_changed_modules "${changed_lines[@]}"
#
#######################################
function run_changed_modules {
    local origin
    origin="$(pwd)"
    local total_lint=0 total_test_fail=0 lowest_coverage="" coverage_run_failed=false any_coverage_failed=0

    local -a modules=()
    local line module
    for line in "$@"; do
        module="${line%%$'\t'*}"
        if [[ ${#modules[@]} -eq 0 || ${modules[-1]} != "$module" ]]; then
            modules+=("$module")
        fi
    done

    for module in "${modules[@]}"; do
        TARGET_PATTERNS=()
        local pattern whole=false
        for line in "$@"; do
            [[ ${line%%$'\t'*} == "$module" ]] || continue
            pattern="${line#*$'\t'}"
            if [[ $pattern == "./..." ]]; then
                whole=true
            fi
            TARGET_PATTERNS+=("$pattern")
        done
        if [[ $whole == "true" ]]; then
            TARGET_PATTERNS=("./...")
        fi
        echo_section "Go module: $module"
        log "INFO" "Target pattern: ${TARGET_PATTERNS[*]}"
        pushd "$origin/$module" > /dev/null || {
            log "ERROR" "Failed to change directory to module: $module"
            EXIT_CODE=1
            continue
        }
        # Keep only packages that contain Go files that apply to this platform and tags, so
        # build-constrained packages do not make lint, test, or vulncheck fail
        # (directories are used as patterns because golangci-lint does not take import paths)
        local -a package_dirs=()
        local package_dir list_output list_status=0 list_err
        if [[ ${TARGET_PATTERNS[*]} != "./..." ]]; then
            list_err="$(mktemp "${TMPDIR:-/tmp}/golist_err.XXXXXX")"
            TEMP_FILES+=("$list_err")
            list_output="$(go list -e -f '{{if or .GoFiles .CgoFiles .InvalidGoFiles .TestGoFiles .XTestGoFiles}}{{.Dir}}{{end}}' "${TARGET_PATTERNS[@]}" 2> "$list_err")" || list_status=$?
            if [[ $list_status -ne 0 ]]; then
                # A broken go.mod or toolchain must surface in the real checks instead of being skipped
                log "WARN" "go list failed in module $module; checking the changed patterns unfiltered: $(cat "$list_err")"
            else
                mapfile -t package_dirs < <(printf '%s\n' "$list_output" | sed '/^$/d')
                TARGET_PATTERNS=()
                if [[ ${#package_dirs[@]} -gt 0 ]]; then
                    for package_dir in "${package_dirs[@]}"; do
                        if [[ $package_dir == "$PWD" ]]; then
                            TARGET_PATTERNS+=(".")
                        else
                            TARGET_PATTERNS+=("./${package_dir#"$PWD"/}")
                        fi
                    done
                fi
            fi
        fi
        if [[ ${#TARGET_PATTERNS[@]} -eq 0 ]]; then
            log "INFO" "No Go files apply to this platform in module $module; skipping"
        else
            LINT_ISSUES_COUNT=0
            TEST_FAIL_COUNT=0
            COVERAGE_PERCENT=""
            COVERAGE_FAILED=0
            run_checks
            CHECKED_MODULES=$((CHECKED_MODULES + 1))
            # Per-run values are overwritten by the next module, so fold them into totals
            total_lint=$((total_lint + ${LINT_ISSUES_COUNT:-0}))
            total_test_fail=$((total_test_fail + ${TEST_FAIL_COUNT:-0}))
            if [[ $COVERAGE_FAILED == "1" ]]; then
                any_coverage_failed=1
            fi
            if [[ -z $COVERAGE_PERCENT ]]; then
                if [[ $COVERAGE_FAILED == "1" ]]; then
                    coverage_run_failed=true
                fi
            elif [[ -z $lowest_coverage ]] || awk -v a="$COVERAGE_PERCENT" -v b="$lowest_coverage" 'BEGIN { exit !(a < b) }'; then
                lowest_coverage="$COVERAGE_PERCENT"
            fi
        fi
        popd > /dev/null || true
    done

    LINT_ISSUES_COUNT=$total_lint
    TEST_FAIL_COUNT=$total_test_fail
    COVERAGE_PERCENT=$lowest_coverage
    COVERAGE_FAILED=$any_coverage_failed
    if [[ $coverage_run_failed == "true" ]]; then
        COVERAGE_PERCENT=""
    fi
}

#######################################
# run_checks: Run every enabled check against TARGET_PATTERNS from the current directory
#
# Description:
#   Runs go mod tidy, build, golangci-lint, the test family (unless skipped), and the
#   security checks in order.
#
# Globals:
#   SKIP_TESTS - Skip go test, race, coverage, and benchmark checks
#   VERBOSE - Also run benchmark tests
#
# Arguments:
#   None
#
# Outputs:
#   Check results
#
# Returns:
#   None (sets the per-check failure flags and EXIT_CODE)
#
# Usage:
#   run_checks
#
#######################################
function run_checks {
    run_go_mod_tidy
    run_go_build
    run_golangci_lint
    if [[ $SKIP_TESTS != "true" ]]; then
        run_tests
        run_race_tests
        run_coverage_tests
        if [[ $VERBOSE == "true" ]]; then
            run_benchmark_tests
        fi
    else
        log "INFO" "Skipping go test, race, coverage, and benchmark checks"
    fi
    run_security_checks
}

#######################################
# run_coverage_tests: Run coverage tests
#
# Description:
#   Runs go test with coverage analysis and checks against threshold
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
#   None (sets COVERAGE_FAILED on threshold miss; does not affect EXIT_CODE)
#
# Usage:
#   run_coverage_tests
#
#######################################
function run_coverage_tests {
    echo_section "Running coverage tests"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run coverage tests for ${TARGET_PATTERNS[*]}"
        return 0
    fi

    local coverage_file
    coverage_file=$(mktemp "${TMPDIR:-/tmp}/coverage.XXXXXX") || {
        log "ERROR" "Failed to create temporary coverage file"
        EXIT_CODE=1
        return 1
    }
    TEMP_FILES+=("$coverage_file")
    if go test -coverprofile="$coverage_file" "${TARGET_PATTERNS[@]}"; then
        local coverage_percent
        local coverage_output
        coverage_output=$(go tool cover -func="$coverage_file" | grep total | awk '{print $3}')
        coverage_percent=${coverage_output%\%}
        COVERAGE_PERCENT="$coverage_percent"

        if [[ -n $coverage_percent ]]; then
            echo "Coverage: ${coverage_percent}%"

            # Compare coverage using awk for better compatibility
            if awk "BEGIN {exit !($coverage_percent >= $COVERAGE_THRESHOLD)}"; then
                log "INFO" "Coverage ($coverage_percent%) meets threshold ($COVERAGE_THRESHOLD%)"
            else
                log "WARN" "Coverage ($coverage_percent%) below threshold ($COVERAGE_THRESHOLD%)"
                COVERAGE_FAILED=1
            fi

            if [[ $VERBOSE == "true" ]]; then
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
#   None (sets EXIT_CODE and GO_BUILD_FAILED on failure)
#
# Usage:
#   run_go_build
#
#######################################
function run_go_build {
    echo_section "Running go build"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go build \"${TARGET_PATTERNS[*]}\"'"
        return 0
    fi

    # With --changed-only, build only packages that have buildable (non-test) Go files;
    # an explicit package that has only tests or is excluded by build constraints makes go build fail
    local -a build_targets=("${TARGET_PATTERNS[@]}")
    if [[ $CHANGED_ONLY == "true" ]]; then
        local list_output
        if list_output="$(go list -e -f '{{if or .GoFiles .CgoFiles .InvalidGoFiles}}{{.ImportPath}}{{end}}' "${TARGET_PATTERNS[@]}" 2> /dev/null)"; then
            mapfile -t build_targets < <(printf '%s\n' "$list_output" | sed '/^$/d')
            if [[ ${#build_targets[@]} -eq 0 ]]; then
                log "INFO" "No buildable packages among the changed packages; skipping go build"
                return 0
            fi
        else
            # go list itself failed: build the unfiltered patterns so the real error is reported
            log "WARN" "go list failed; building the changed patterns unfiltered"
        fi
    fi

    # Attempt to build all packages matching the target pattern
    if go build "${build_targets[@]}"; then
        log "INFO" "go build succeeded"
    else
        log "ERROR" "go build failed"
        EXIT_CODE=1
        GO_BUILD_FAILED=1
    fi
}

#######################################
# run_go_mod_tidy: Run go mod tidy
#
# Description:
#   Runs go mod tidy (with --fix) or go mod tidy -diff (check only) on go.mod and go.sum
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
#   None (sets EXIT_CODE on failure)
#
# Usage:
#   run_go_mod_tidy
#
#######################################
function run_go_mod_tidy {
    echo_section "Running go mod tidy"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go mod tidy'"
        return 0
    fi

    # 特定ディレクトリ指定時はそのディレクトリ内に go.mod がある場合のみ実行
    local mod_dir="."
    if [[ $IS_SCOPED == "true" ]]; then
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
    if [[ $FIX_MODE == "true" ]]; then
        if go mod tidy; then
            log "INFO" "go mod tidy completed successfully (dir=$mod_dir)"
        else
            log "ERROR" "go mod tidy failed (dir=$mod_dir)"
            EXIT_CODE=1
        fi
    elif go help mod tidy 2>&1 | grep -q -- '-diff'; then
        # Check only: validation must not rewrite go.mod / go.sum (-diff needs Go 1.23+)
        if go mod tidy -diff; then
            log "INFO" "go.mod and go.sum are tidy (dir=$mod_dir)"
        else
            log "ERROR" "go.mod/go.sum are not tidy (dir=$mod_dir). Run with --fix or 'go mod tidy'"
            EXIT_CODE=1
        fi
    else
        # Older toolchains: tidy, compare, then always restore the original files
        local backup_dir
        backup_dir="$(mktemp -d)"
        cp go.mod "$backup_dir/go.mod"
        [[ -f go.sum ]] && cp go.sum "$backup_dir/go.sum"
        if go mod tidy && diff -q go.mod "$backup_dir/go.mod" > /dev/null \
            && { [[ ! -f $backup_dir/go.sum ]] || diff -q go.sum "$backup_dir/go.sum" > /dev/null; }; then
            log "INFO" "go.mod and go.sum are tidy (dir=$mod_dir)"
        else
            log "ERROR" "go.mod/go.sum are not tidy (dir=$mod_dir). Run with --fix or 'go mod tidy'"
            EXIT_CODE=1
        fi
        cp "$backup_dir/go.mod" go.mod
        [[ -f $backup_dir/go.sum ]] && cp "$backup_dir/go.sum" go.sum
        rm -rf "$backup_dir"
    fi
    popd > /dev/null || true
}

#######################################
# run_golangci_lint: Run golangci-lint
#
# Description:
#   Runs golangci-lint to perform comprehensive code linting
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
#   None (sets EXIT_CODE and LINT_FAILED on failure)
#
# Usage:
#   run_golangci_lint
#
#######################################
function run_golangci_lint {
    echo_section "Running golangci-lint"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'golangci-lint run ${TARGET_PATTERNS[*]}'"
        return 0
    fi

    local lint_args=("run" "--disable" "gocognit")

    if [[ $FIX_MODE == "true" ]]; then
        lint_args+=("--fix")
    fi

    if [[ $VERBOSE == "true" ]]; then
        lint_args+=("-v")
    fi

    lint_args+=("${TARGET_PATTERNS[@]}")

    local lint_output
    lint_output=$(mktemp "${TMPDIR:-/tmp}/golint_output.XXXXXX") || {
        log "ERROR" "Failed to create temporary lint output file"
        EXIT_CODE=1
        return 1
    }
    TEMP_FILES+=("$lint_output")

    if golangci-lint "${lint_args[@]}" 2>&1 | tee "$lint_output"; then
        log "INFO" "golangci-lint passed"
        LINT_ISSUES_COUNT=0
    else
        log "ERROR" "golangci-lint found issues"
        EXIT_CODE=1
        LINT_FAILED=1
        # Count issues
        if [[ -f $lint_output ]]; then
            LINT_ISSUES_COUNT=$(grep -cE '^\S+\.go:' "$lint_output" 2> /dev/null || true)
            # Normalize to a single integer token even when grep prints 0 and exits 1.
            LINT_ISSUES_COUNT=$(printf '%s\n' "$LINT_ISSUES_COUNT" | awk 'NR == 1 {print $1; exit}')
        else
            LINT_ISSUES_COUNT=0
        fi
        # Ensure it's a valid number
        if ! [[ $LINT_ISSUES_COUNT =~ ^[0-9]+$ ]]; then
            LINT_ISSUES_COUNT=0
        fi
    fi
    rm -f "$lint_output"
}

#######################################
# run_race_tests: Run race condition tests
#
# Description:
#   Runs go test with race detection enabled
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
#   None (sets EXIT_CODE and RACE_FAILED on failure)
#
# Usage:
#   run_race_tests
#
#######################################
function run_race_tests {
    echo_section "Running race condition tests"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'CGO_ENABLED=1 go test -race ${TARGET_PATTERNS[*]}'"
        return 0
    fi

    if CGO_ENABLED=1 go test -race "${TARGET_PATTERNS[@]}"; then
        log "INFO" "Race condition tests passed"
    else
        log "ERROR" "Race condition tests failed"
        EXIT_CODE=1
        RACE_FAILED=1
    fi
}

#######################################
# run_security_checks: Run security checks
#
# Description:
#   Runs security vulnerability checks using govulncheck
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
#   None (sets EXIT_CODE and SECURITY_FAILED on failure)
#
# Usage:
#   run_security_checks
#
#######################################
function run_security_checks {
    echo_section "Running security checks"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run security checks"
        return 0
    fi

    # Check for govulncheck
    if command -v govulncheck &> /dev/null; then
        log "INFO" "Running govulncheck... (target=${TARGET_PATTERNS[*]})"
        if govulncheck "${TARGET_PATTERNS[@]}"; then
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
#   None (sets EXIT_CODE and TEST_FAILED on failure)
#
# Usage:
#   run_tests
#
#######################################
function run_tests {
    echo_section "Running go test"

    if [[ $DRY_RUN == "true" ]]; then
        log "INFO" "DRY-RUN: Would run 'go test -v ${TARGET_PATTERNS[*]}'"
        return 0
    fi

    local test_args=("-v")

    if [[ $VERBOSE == "true" ]]; then
        test_args+=("-x")
    fi

    test_args+=("${TARGET_PATTERNS[@]}")

    local test_output
    test_output=$(mktemp "${TMPDIR:-/tmp}/gotest_output.XXXXXX") || {
        log "ERROR" "Failed to create temporary test output file"
        EXIT_CODE=1
        return 1
    }
    TEMP_FILES+=("$test_output")

    if go test "${test_args[@]}" 2>&1 | tee "$test_output"; then
        log "INFO" "All tests passed"
        TEST_FAIL_COUNT=0
    else
        log "ERROR" "Some tests failed"
        EXIT_CODE=1
        TEST_FAILED=1
        # Count failed tests
        TEST_FAIL_COUNT=$(grep -c '^--- FAIL:' "$test_output" 2> /dev/null || true)
        # Normalize to a single integer token even when grep prints 0 and exits 1.
        TEST_FAIL_COUNT=$(printf '%s\n' "$TEST_FAIL_COUNT" | awk 'NR == 1 {print $1; exit}')
    fi
    rm -f "$test_output"
}

#######################################
# main: Main process
#
# Description:
#   Main entry point that orchestrates all code quality checks
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
#   None (exits with appropriate status code)
#
# Usage:
#   main "$@"
#
#######################################
function main {
    trap cleanup_temp_files EXIT
    parse_arguments "$@"
    start_time=$(date +%s)
    require_dependencies "go" "golangci-lint"
    local -a changed_lines=()
    if [[ $CHANGED_ONLY == "true" ]]; then
        # Checks run from each module root, so a directory argument only scopes the changed set
        IS_SCOPED=false
        mapfile -t changed_lines < <(determine_changed_patterns "$TARGET_DIR")
        if [[ ${#changed_lines[@]} -eq 0 ]]; then
            log "INFO" "--changed-only: no changed Go packages"
            print_validation_result go 0 "changed_only=SKIP|no changed Go packages" || true
            exit 0
        fi
    else
        TARGET_PATTERNS=("$(determine_target_pattern "$TARGET_DIR")")
    fi
    echo_section "Starting Go code quality checks"
    log "INFO" "Target input: $TARGET_DIR"
    if [[ $CHANGED_ONLY != "true" ]]; then
        log "INFO" "Target pattern: ${TARGET_PATTERNS[*]}"
    fi
    log "INFO" "Scoped mode: $IS_SCOPED"
    log "INFO" "Verbose mode: $VERBOSE"
    log "INFO" "Dry-run mode: $DRY_RUN"
    log "INFO" "Fix mode: $FIX_MODE"
    log "INFO" "Skip tests: $SKIP_TESTS"
    log "INFO" "Changed only: $CHANGED_ONLY"
    if [[ $CHANGED_ONLY == "true" ]]; then
        run_changed_modules "${changed_lines[@]}"
        if [[ $CHECKED_MODULES -eq 0 ]]; then
            if [[ $EXIT_CODE -eq 0 ]]; then
                log "INFO" "--changed-only: no changed package applies to this platform"
                print_validation_result go 0 "changed_only=SKIP|no changed package applies to this platform" || true
            fi
            exit $EXIT_CODE
        fi
    else
        run_checks
    fi
    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))

    local lint_detail="" test_detail="" cover_detail=""
    if [[ ${LINT_FAILED} == "1" && ${LINT_ISSUES_COUNT:-0} -gt 0 ]]; then
        lint_detail="|${LINT_ISSUES_COUNT} issues"
    fi
    if [[ ${TEST_FAILED} == "1" && ${TEST_FAIL_COUNT:-0} -gt 0 ]]; then
        test_detail="|${TEST_FAIL_COUNT} failed"
    fi
    if [[ -n $COVERAGE_PERCENT ]]; then
        cover_detail="|${COVERAGE_PERCENT}% (threshold ${COVERAGE_THRESHOLD}%)"
    fi
    local test_status="PASS" race_status="PASS" cover_status="PASS"
    if [[ $SKIP_TESTS == "true" ]]; then
        test_status="SKIP" race_status="SKIP" cover_status="SKIP"
        test_detail="" cover_detail=""
    else
        test_status="$(check_status "$TEST_FAILED")"
        race_status="$(check_status "$RACE_FAILED")"
        # Coverage below threshold is a warning and does not affect the exit code
        # (a failed coverage run leaves COVERAGE_PERCENT empty and does set the exit code)
        cover_status="PASS"
        if [[ $COVERAGE_FAILED == "1" ]]; then
            cover_status="WARN"
            if [[ -z $COVERAGE_PERCENT ]]; then
                cover_status="FAIL"
            fi
        fi
    fi
    print_validation_result go "$elapsed" \
        "go_build=$(check_status "$GO_BUILD_FAILED")" \
        "golangci_lint=$(check_status "$LINT_FAILED")${lint_detail}" \
        "go_test=${test_status}${test_detail}" \
        "go_test_race=${race_status}" \
        "go_test_cover=${cover_status}${cover_detail}" \
        "govulncheck=$(check_status "$SECURITY_FAILED")" || true

    exit $EXIT_CODE
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
