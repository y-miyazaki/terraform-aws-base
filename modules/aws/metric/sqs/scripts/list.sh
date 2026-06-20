#!/bin/bash
#######################################
# Description: List SQS queue names as a JSON object
#
# Usage: ./list.sh [region]
#   region: (Optional) AWS region
#
# Output:
# - JSON object with "list" key (comma-separated queue names)
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
Usage: $(basename "$0") [region]

Description: List SQS queue names as a JSON object.

Arguments:
  region        (Optional) AWS region

Options:
  -h, --help    Display this help message

Example: $(basename "$0")
Example: $(basename "$0") us-east-1
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
    local region="${1:-}" # Optional region parameter

    # Parse arguments
    case "$region" in
        -h | --help)
            show_usage
            ;;
    esac

    # Validate dependencies
    if ! command -v aws > /dev/null 2>&1; then
        echo "ERROR: aws CLI is required" >&2
        exit 1
    fi
    if ! command -v jq > /dev/null 2>&1; then
        echo "ERROR: jq is required" >&2
        exit 1
    fi

    # Build AWS CLI command
    local aws_cmd="aws sqs list-queues --query 'QueueUrls[]' --output json"

    # Add region if provided
    if [[ -n "$region" ]]; then
        aws_cmd="$aws_cmd --region \"$region\""
    fi

    # Get SQS queue URLs
    local list
    list=$(eval "$aws_cmd")

    # Extract queue names from URLs and convert to comma-separated string
    local joined
    joined=$(echo "$list" | jq -r 'if . == null then "" else [.[] | split("/") | last] | join(",") end')

    # Output as JSON - all values must be strings for Terraform external data source
    jq -n --arg l "$joined" '{list: $l}'
}

# Only call main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
