#!/bin/bash
#######################################
# Description:
#   Local wrapper for validate-loop-caller-permissions composite action.
#
# Usage:
#   bash scripts/ci/validate_loop_caller_permissions.sh [--verbose]
#
# Design Rules:
#   - Delegates to .github/actions/validate-loop-caller-permissions/lib/validate.sh
#   - Uses the bundled registry shipped with the composite action
#
# Output:
#   Validation summary from the composite action library
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

#######################################
# Global variables
#######################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ACTION_ROOT="${REPO_ROOT}/.github/actions/validate-loop-caller-permissions"
VALIDATE_SCRIPT="${ACTION_ROOT}/lib/validate.sh"

#######################################
# show_usage: Display script usage
#
# Description:
#   Prints usage information and exits successfully.
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
#   Exits 0
#
#######################################
function show_usage {
    cat << EOF
Usage: $0 [--verbose]

Validate on-loop-* caller workflow permissions against the bundled profile registry.

Options:
  -h, --help     Display this help message
  --verbose      Print per-caller OK lines
EOF
    exit 0
}

#######################################
# parse_arguments: Parse CLI options
#
# Description:
#   Supports --verbose and --help.
#
# Globals:
#   VERBOSE - Set to true when --verbose is passed
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   Exits 1 on unknown options
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -*)
                echo "Unknown option: $1. Use -h for help." >&2
                exit 1
                ;;
            *)
                echo "Unexpected argument: $1" >&2
                exit 1
                ;;
        esac
    done
}

#######################################
# main: Main process
#
# Description:
#   Exports local paths and delegates to the composite action library.
#
# Globals:
#   VERBOSE - Verbose logging flag
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   Exits with delegated validation status
#
#######################################
function main {
    local -a delegate_args=()

    parse_arguments "$@"

    if [[ ! -x ${VALIDATE_SCRIPT} && ! -f ${VALIDATE_SCRIPT} ]]; then
        echo "Validation library not found: ${VALIDATE_SCRIPT}" >&2
        exit 1
    fi

    export REGISTRY_FILE="${ACTION_ROOT}/detect-permissions-profiles.yaml"
    export WORKFLOWS_DIR="${REPO_ROOT}/.github/workflows"
    export VERBOSE="${VERBOSE:-false}"

    if [[ ${VERBOSE} == true ]]; then
        delegate_args+=(--verbose)
    fi

    exec bash "${VALIDATE_SCRIPT}" "${delegate_args[@]}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
