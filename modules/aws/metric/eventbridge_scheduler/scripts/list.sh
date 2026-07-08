#!/bin/bash
#######################################
# Description: List EventBridge Scheduler schedule groups as a JSON object
#
# Usage: ./list.sh [region]
#   region: (Optional) AWS region
#
# Output:
# - JSON object with "list_schedule_group" key (comma-separated group names)
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

Description: List EventBridge Scheduler schedule groups as a JSON object.

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
#   Queries AWS Batch to list job queue names
#   and outputs the result as JSON.
#
# Arguments:
#   $@ - Command line arguments
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
    local aws_cmd="aws scheduler list-schedule-groups --query 'ScheduleGroups[].Name' --output json"

    # Add region if provided
    if [[ -n $region ]]; then
        aws_cmd="$aws_cmd --region \"$region\""
    fi

    # Get EventBridge Scheduler group names
    local list
    list=$(eval "$aws_cmd")

    # Convert JSON array to comma-separated string
    local joined
    joined=$(echo "$list" | jq -r 'join(",")')

    # Output as JSON - all values must be strings for Terraform external data source
    jq -n --arg l "$joined" '{list_schedule_group: $l}'
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
