#!/bin/bash
#######################################
# Description: List Redshift cluster identifiers as a JSON object
#
# Usage: ./list.sh [options]
#   options:
#   -h, --help    Display this help message
#
# Output:
# - JSON object with "list" key (comma-separated cluster identifiers)
# - Used by Terraform external data source
#
# Design Rules:
# - Must output valid JSON for Terraform external data source consumption
# - All values in output must be strings
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

Description: List Redshift cluster identifiers as a JSON object.

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

    # Get Redshift cluster identifiers
    mapfile -t list < <(aws redshift describe-clusters | jq -r '.Clusters[].ClusterIdentifier')

    # Output as JSON
    if [[ ${#list[@]} -eq 0 ]]; then
        echo '{"list": ""}'
        exit 0
    fi

    joined=$(printf '%s\n' "${list[@]}" | jq -R . | jq -s 'join(",")')
    echo "{\"list\": \"$joined\"}"
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
