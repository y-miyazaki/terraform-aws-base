#!/bin/bash
#######################################
# Description: Post-tool-use hook for tflint.
#              Lints changed Terraform files and exits 2 on failure
#              for agent environments.
#
# Usage: Called by apm hook runner (not invoked directly).
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Exit 2 on lint failure (agent error signal)
#   - POSIX-safe variable scoping (no pipe+while)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for reliable relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

#######################################
# get_changed_dirs: Collect unique directories containing changed Terraform files
#
# Description:
#   Gathers modified/added/untracked Terraform files from git and extracts
#   their parent directories. Each git command is guarded with || true to
#   prevent pipefail from terminating the script.
#
# Arguments:
#   None
#
# Returns:
#   Newline-separated unique directory list to stdout
#
# Usage:
#   mapfile -t dirs < <(get_changed_dirs)
#
#######################################
function get_changed_dirs {
    {
        git diff --name-only --diff-filter=ACMR -- '*.tf' '*.tfvars' '*.hcl' 2> /dev/null || true
        git diff --cached --name-only --diff-filter=ACMR -- '*.tf' '*.tfvars' '*.hcl' 2> /dev/null || true
        git ls-files --others --exclude-standard -- '*.tf' '*.tfvars' '*.hcl' 2> /dev/null || true
    } | awk 'NF' | xargs -I{} dirname {} | sort -u
}

#######################################
# main: Entry point
#
# Description:
#   Runs tflint on each directory containing changed Terraform files.
#   Exits 0 on skip/success, exits 2 on lint failure.
#
# Arguments:
#   None
#
# Returns:
#   0 on success or skip, 2 on lint failure
#
# Usage:
#   main
#
#######################################
function main {
    command -v jq > /dev/null 2>&1 || exit 0
    command -v tflint > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    local dirs=()
    mapfile -t dirs < <(get_changed_dirs)

    if ((${#dirs[@]} == 0)); then
        exit 0
    fi

    local fails=0
    for dir in "${dirs[@]}"; do
        [[ -n "$dir" && -d "$dir" ]] || continue
        tflint --init --chdir "$dir" > /dev/null 2>&1 || true
        tflint --fix --chdir "$dir" || fails=$((fails + 1))
    done

    if [[ "$fails" -gt 0 ]]; then
        exit 2
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
