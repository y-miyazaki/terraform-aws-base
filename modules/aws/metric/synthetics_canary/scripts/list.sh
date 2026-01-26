#!/bin/bash
#######################################
# Description: List Synthetics Canary names as a JSON object
#
# Usage: ./list.sh [options]
#   options:
#   -h, --help    Display this help message
#
# This script queries AWS Synthetics and outputs Canary names in JSON format.
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

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

Description: List Synthetics Canary names as a JSON object.

Options:
  -h, --help    Display this help message

Example: $(basename "$0")
EOF
    exit 0
}

#######################################
# main: Main execution function
#
# Description:
#   Main execution function
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
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
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_usage
                ;;
        esac
    done

    # Validate dependencies
    if ! command -v aws > /dev/null 2>&1; then
        echo "ERROR: aws CLI is required" >&2
        exit 1
    fi
    if ! command -v jq > /dev/null 2>&1; then
        echo "ERROR: jq is required" >&2
        exit 1
    fi

    # Get Synthetics Canary names
    mapfile -t list < <(aws synthetics describe-canaries | jq -r '.Canaries[].Name')

    # Output as JSON
    if [[ ${#list[@]} -eq 0 ]]; then
        echo '{"list": ""}'
        exit 0
    fi

    # Join with comma, safely
    joined=$(
        IFS=,
        echo "${list[*]}"
    )
    echo "{\"list\": \"$joined\"}"
}

# Only call main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
