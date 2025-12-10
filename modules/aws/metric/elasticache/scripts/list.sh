#!/bin/bash
#######################################
# Description: List ElastiCache cluster IDs as a JSON object
# Usage: ./list.sh
#   -h, --help    Display this help message
#
# This script queries AWS ElastiCache and outputs cluster IDs in JSON format.
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

#######################################
# show_usage: Display usage information
#
# Description:
#   Display usage information
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    echo "Usage: $(basename "$0")"
    echo ""
    echo "Description: List ElastiCache cluster IDs as a JSON object."
    echo ""
    echo "Options:"
    echo "  -h, --help    Display this help message"
    echo ""
    echo "Example: $(basename "$0")"
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
        shift
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

    # Get ElastiCache cluster IDs
    mapfile -t list < <(aws elasticache describe-cache-clusters --query 'CacheClusters[].CacheClusterId' --output text | tr '\t' '\n')

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
