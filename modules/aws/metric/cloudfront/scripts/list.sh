#!/bin/bash
#######################################
# Description: List CloudFront distribution IDs and domains as a JSON object
#
# Usage: ./list.sh [options]
#   options:
#   -h, --help    Display this help message
#
# This script queries AWS CloudFront and outputs distribution IDs and domains in JSON format.
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

Description: List CloudFront distribution IDs and domains as a JSON object.

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

    # Get CloudFront distribution IDs and domains
    mapfile -t list_distribution < <(aws cloudfront list-distributions | jq -r '.DistributionList.Items[] | .Id')
    mapfile -t list_domain < <(aws cloudfront list-distributions | jq -r '.DistributionList.Items[] | .Aliases.Items[0]')

    # Output as JSON
    joined_dist=$(
        IFS=,
        echo "${list_distribution[*]}"
    )
    joined_domain=$(
        IFS=,
        echo "${list_domain[*]}"
    )
    echo "{\"list_distribution\": \"$joined_dist\", \"list_domain\": \"$joined_domain\"}"
}

# Only call main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
