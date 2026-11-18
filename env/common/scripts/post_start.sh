#!/bin/bash
#######################################
# Description:
#   Devcontainer postStartCommand: refresh state that goes stale between container starts.
#   - Index the repository with codebase-memory-mcp and enable auto-index
#
# Usage:
#   bash env/common/scripts/post_start.sh [-h|--help]
#
# Design Rules:
#   - Runs on every container start, so every step must be idempotent and best effort.
#   - codebase-memory-mcp refuses a root whose path depth is below 2 (for example /workspace) with
#     "path is too broad to index as one root". Lifting that with allow-root --approve-broad needs a
#     release newer than 0.12.1, so indexing falls back to one project per git-tracked top-level
#     directory. The directories come from git, never from a fixed list.
#   - Steps live in lib/init_steps.sh; this script only picks and orders them.
#
# Output:
#   One line per indexed project on stdout; "[warn] ..." lines on stderr for failed steps.
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/init_steps.sh"

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Usage on -h/--help; error on stderr for an unknown argument
#
# Returns:
#   0 on success; exits 1 for an unknown argument
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            *)
                echo "ERROR: Unknown argument: $1" >&2
                exit 1
                ;;
        esac
    done
}

#######################################
# show_usage: Display usage information
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Usage text on stdout
#
# Returns:
#   Exits 0
#######################################
function show_usage {
    cat << 'EOF'
Usage: post_start.sh [-h|--help]

Description:
    Devcontainer postStartCommand. Re-indexes the repository with codebase-memory-mcp
    on every container start. Best effort.

Environment:
    CONTAINER_WORKSPACE_FOLDER  Workspace folder (default: /workspace)

Options:
    -h, --help  Show this help

Examples:
    bash env/common/scripts/post_start.sh
EOF
    exit 0
}

#######################################
# main: Run the postStart steps in order
#
# Globals:
#   REPO_ROOT - Set to the resolved repository root
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   See each step
#
# Returns:
#   0
#######################################
function main {
    parse_arguments "$@"
    # shellcheck disable=SC2034 # read by the step functions in lib/init_steps.sh
    REPO_ROOT="$(resolve_repo_root)"

    index_codebase_memory
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
