#!/bin/bash
#######################################
# Description:
#   Devcontainer postCreateCommand: one-time user configuration after the tools are installed.
#   - Copy the Claude and Cursor statusline scripts into the home directory
#   - Set up the GitHub credential helper for repositories with GitHub remotes
#
# Usage:
#   bash env/common/scripts/post_create.sh [-h|--help]
#
# Design Rules:
#   - Runs after update_content.sh, so the tools it configures are already installed.
#   - These steps write user-level state once; they do not belong in the per-start or per-content hooks.
#   - Steps live in lib/init_steps.sh; this script only picks and orders them.
#
# Output:
#   "[warn] ..." lines on stderr for failed steps.
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
Usage: post_create.sh [-h|--help]

Description:
    Devcontainer postCreateCommand. Writes user-level configuration once after the tools are installed
    (statuslines, GitHub credential helper). Every step is optional and best effort.

Environment:
    CONTAINER_WORKSPACE_FOLDER  Workspace folder (default: /workspace)

Options:
    -h, --help  Show this help

Examples:
    bash env/common/scripts/post_create.sh
EOF
    exit 0
}

#######################################
# main: Run the postCreate steps in order
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

    configure_claude_statusline
    configure_cursor_statusline
    configure_github_credentials
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
