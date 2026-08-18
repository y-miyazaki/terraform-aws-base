#!/bin/bash
#######################################
# Description: Validation tool for GitHub Actions workflows using ORD-01 map order checks, actionlint, ghalint, and zizmor.
#
# Usage: ./validate.sh [options]
#   options:
#     -h, --help     Display this help message
#     -v, --verbose  Enable verbose output
#     -q, --quiet    Suppress non-error output
#
# Design Rules:
#   - Use strict mode in scripts (set -euo pipefail) where appropriate
#   - Source common utilities from scripts/lib/all.sh (error_exit, log, etc.)
#   - Prefer quoting variables, local variables in functions and single responsibility
#   - Tests must be provided with Bats and run by this validator
#
# Dependencies:
#   - python3
#   - actionlint
#   - ghalint
#   - zizmor
#
# Examples:
#   ./scripts/validate.sh
#   ./scripts/validate.sh --verbose
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables
#######################################
VERBOSE=false
QUIET=false
WORKFLOWS_DIR=".github/workflows"

#######################################
# Functions
#######################################

#######################################
# resolve_repository_root: Return the git repository root directory
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Repository root path on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   repo_root="$(resolve_repository_root)"
#
#######################################
function resolve_repository_root {
    git rev-parse --show-toplevel 2> /dev/null || pwd
}

#######################################
# collect_yaml_map_order_targets: Collect workflow and action YAML paths for ORD-01
#
# Description:
#   Builds the file list for yaml_map_order.py. Default scope is tracked workflow
#   YAML plus action.yml files under .github/actions. A custom workflows-dir limits
#   checks to YAML files under that directory only.
#
# Globals:
#   WORKFLOWS_DIR - Path to workflows directory
#
# Arguments:
#   $1 - Name reference to output array
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   local -a targets=()
#   collect_yaml_map_order_targets targets
#
#######################################
function collect_yaml_map_order_targets {
    # shellcheck disable=SC2178 # nameref to caller array by name
    local -n _out=$1
    local file pattern repo_root

    _out=()
    repo_root="$(resolve_repository_root)"

    if [[ ${WORKFLOWS_DIR} != ".github/workflows" ]]; then
        while IFS= read -r file; do
            [[ -n ${file} ]] && _out+=("${file}")
        done < <(find "${WORKFLOWS_DIR}" -type f \( -name '*.yml' -o -name '*.yaml' \) 2> /dev/null | LC_ALL=C sort)
        return 0
    fi

    pattern='^\.github/(workflows/.*\.(ya?ml)|actions/.*/action\.(ya?ml))$'
    while IFS= read -r file; do
        [[ -z ${file} ]] && continue
        if [[ ${file} =~ ${pattern} ]]; then
            _out+=("${repo_root}/${file}")
        fi
    done < <(cd "${repo_root}" && repo_emit_tracked_paths '\.(ya?ml)$')
}

#######################################
# validate_yaml_map_key_order: Validate alphabetical map key order (ORD-01)
#
# Description:
#   Runs yaml_map_order.py check against workflow and action YAML files.
#
# Globals:
#   VERBOSE - Enable verbose output
#   WORKFLOWS_DIR - Path to workflows directory
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   validate_yaml_map_key_order
#
#######################################
function validate_yaml_map_key_order {
    echo_section "Checking YAML map key order (ORD-01)"
    local start_time checker
    local -a targets=()
    start_time=$(date +%s)
    checker="${SCRIPT_DIR}/lib/yaml_map_order.py"

    validate_file_exists "${checker}" "YAML map order checker"
    collect_yaml_map_order_targets targets

    if [[ ${#targets[@]} -eq 0 ]]; then
        if [[ $VERBOSE == true ]]; then
            log INFO "No workflow or action YAML files found for ORD-01 check"
        fi
        end_echo_section "ORD-01 check completed" "$start_time"
        return 0
    fi

    if [[ $VERBOSE == true ]]; then
        log INFO "Checking ${#targets[@]} YAML file(s) for alphabetical map key order"
    fi

    if ! python3 "${checker}" check "${targets[@]}"; then
        error_exit "YAML map key order validation failed (ORD-01)"
    fi

    end_echo_section "ORD-01 check completed" "$start_time"
}

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
Usage: $0 [options] [workflows-dir]

Validation tool for GitHub Actions workflows using ORD-01 map order checks, actionlint, ghalint, and zizmor.

Arguments:
  workflows-dir    Path to .github/workflows directory (default: .github/workflows)

Options:
  -h, --help     Display this help message
  -v, --verbose  Enable verbose output
  -q, --quiet    Suppress non-error output

Examples:
  $0
  $0 --verbose
  $0 /path/to/.github/workflows
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables
#
# Globals:
#   VERBOSE - Enable verbose output
#   QUIET - Suppress non-error output
#   WORKFLOWS_DIR - Path to workflows directory
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
                VERBOSE=true
                shift
                ;;
            -q | --quiet)
                QUIET=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1. Use -h for help."
                ;;
            *)
                # Set workflows directory
                WORKFLOWS_DIR="$1"
                shift
                ;;
        esac
    done
}

#######################################
# validate_actionlint: Validate workflows with actionlint
#
# Description:
#   Runs actionlint to validate workflow syntax and best practices
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
#   0 on success, 1 on failure
#
# Usage:
#   validate_actionlint
#
#######################################
function validate_actionlint {
    echo_section "Running actionlint"
    local start_time repo_root
    start_time=$(date +%s)
    repo_root="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"

    if [[ $VERBOSE == true ]]; then
        log INFO "Validating workflow syntax and best practices with actionlint (repo root: ${repo_root})"
    fi

    # actionlint loads .github/actionlint.yaml from the repository root; running
    # from the skill directory otherwise misses path-specific ignore rules.
    if ! (cd "${repo_root}" && actionlint); then
        error_exit "actionlint validation failed"
    fi

    end_echo_section "actionlint completed" "$start_time"
}

#######################################
# validate_ghalint: Validate workflows with ghalint
#
# Description:
#   Runs ghalint to validate workflow security and configuration
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
#   0 on success, 1 on failure
#
# Usage:
#   validate_ghalint
#
#######################################
function validate_ghalint {
    echo_section "Running ghalint"
    local start_time repo_root workflows_path
    start_time=$(date +%s)
    repo_root="$(resolve_repository_root)"
    workflows_path="${repo_root}/${WORKFLOWS_DIR}"

    if [[ $VERBOSE == true ]]; then
        log INFO "Validating workflow security and configuration with ghalint"
    fi

    if ! ghalint run "${workflows_path}"; then
        error_exit "ghalint validation failed"
    fi

    end_echo_section "ghalint completed" "$start_time"
}

#######################################
# is_zizmor_online_audit_failure: Detect GitHub API connectivity failures
#
# Description:
#   Returns success when zizmor failed before producing findings because an
#   online audit could not reach the GitHub API (for example impostor-commit).
#
# Globals:
#   None
#
# Arguments:
#   $1 - result: Captured zizmor stdout/stderr
#
# Outputs:
#   None
#
# Returns:
#   0 when the failure looks like an online-audit connectivity issue, 1 otherwise
#
# Usage:
#   is_zizmor_online_audit_failure "$result"
#
#######################################
function is_zizmor_online_audit_failure {
    local result="$1"

    if ! echo "$result" | grep -q 'fatal: no audit was performed'; then
        return 1
    fi

    if echo "$result" | grep -qE 'request error while accessing GitHub API|couldn'\''t list tags for|tcp connect error|Connection timed out|client error \(Connect\)'; then
        return 0
    fi

    return 1
}

#######################################
# validate_zizmor: Scan workflows with zizmor
#
# Description:
#   Runs zizmor to scan for GitHub Actions security issues
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
#   0 on success, 1 on failure
#
# Usage:
#   validate_zizmor
#
#######################################
function validate_zizmor {
    echo_section "Running zizmor"
    local start_time
    start_time=$(date +%s)

    if [[ $VERBOSE == true ]]; then
        log INFO "Scanning for GitHub Actions security issues with zizmor"
    fi

    local repo_root result exit_code zizmor_args=()
    repo_root="$(resolve_repository_root)"

    if [[ ${ZIZMOR_OFFLINE:-} == 1 || ${ZIZMOR_OFFLINE:-} == true ]]; then
        zizmor_args+=(--offline)
    elif [[ ${ZIZMOR_NO_ONLINE_AUDITS:-} == 1 || ${ZIZMOR_NO_ONLINE_AUDITS:-} == true ]]; then
        zizmor_args+=(--no-online-audits)
    fi

    set +e
    result=$(zizmor "${zizmor_args[@]}" "$repo_root" 2>&1)
    exit_code=$?
    set -e

    if ((exit_code != 0)) \
        && ((${#zizmor_args[@]} == 0)) \
        && is_zizmor_online_audit_failure "$result"; then
        if [[ $VERBOSE == true ]]; then
            log WARN "zizmor online audits unavailable; retrying with --no-online-audits"
        fi
        set +e
        result=$(zizmor --no-online-audits "$repo_root" 2>&1)
        exit_code=$?
        set -e
    fi

    if ((exit_code != 0)); then
        echo "$result" >&2
        error_exit "zizmor validation failed"
    fi

    if [[ $VERBOSE == true ]] && [[ -n $result ]]; then
        echo "$result"
    fi

    end_echo_section "zizmor completed" "$start_time"
}

#######################################
# Main script
#######################################

#######################################
# main: Main process
#
# Description:
#   Main process for GitHub Actions validation
#
# Globals:
#   VERBOSE - Enable verbose output
#   QUIET - Suppress non-error output
#   WORKFLOWS_DIR - Path to workflows directory
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
    parse_arguments "$@"

    # Validate required dependencies
    require_dependencies "python3" "actionlint" "ghalint" "zizmor"

    # Run validations
    echo_section "Starting GitHub Actions Validation"

    validate_yaml_map_key_order
    validate_actionlint
    validate_ghalint
    validate_zizmor

    echo_section "All validations completed successfully"

    if [[ $QUIET == false ]]; then
        log INFO "GitHub Actions workflows are valid and secure"
    fi
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
