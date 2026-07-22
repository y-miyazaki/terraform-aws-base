#!/bin/bash
#######################################
# Description: Post-tool-use hook for terraform fmt.
#              Formats all Terraform files recursively and exits 2 on failure
#              for agent environments.
#
# Usage: Called by apm hook runner (not invoked directly).
#
# Design Rules:
#   - Exit 0 if tool not found (silent skip)
#   - Exit 2 on format failure (agent error signal)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

#######################################
# main: Entry point
#
# Description:
#   Runs terraform fmt -recursive on the repository root.
#   Exits 0 on skip/success, exits 2 on format failure.
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
#   0 on success or skip, 2 on failure
#
# Usage:
#   main
#
#######################################
function main {
    command -v jq > /dev/null 2>&1 || exit 0
    command -v terraform > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    terraform fmt -recursive || exit 2
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
