#!/bin/bash
#######################################
# Description:
#   Devcontainer updateContentCommand: install the tools the repository content pins.
#   - Apply mise trust, run mise install, and set the pinned node as the mise global node
#   - Run apm install (when apm.yml exists)
#   - Lazy-install aqua tools and apply the aqua policy
#   - Install gh extensions
#   - Install pre-commit hooks
#   - Create the Terraform plugin cache directory and initialize tflint
#
# Usage:
#   bash env/common/scripts/update_content.sh [-h|--help]
#
# Design Rules:
#   - Runs after on_create.sh and before post_create.sh (post_create needs the mise and apm results).
#   - Every step depends on repository files (mise.toml, apm.yml, aqua.yaml, ...), so it is safe to re-run.
#   - install_mise precedes the later steps because pre-commit, aqua, and tflint come from mise.
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
Usage: update_content.sh [-h|--help]

Description:
    Devcontainer updateContentCommand. Installs the tools pinned by the repository
    (mise, apm, aqua, gh extensions, pre-commit, tflint). Every step is optional and best effort.

Environment:
    CONTAINER_WORKSPACE_FOLDER  Workspace folder (default: /workspace)

Options:
    -h, --help  Show this help

Examples:
    bash env/common/scripts/update_content.sh
EOF
    exit 0
}

#######################################
# main: Run the updateContent steps in order
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

    install_mise
    install_mise_global_node
    install_apm
    install_aqua
    install_gh_extension
    install_pre_commit
    prepare_terraform
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
