#!/bin/bash
#######################################
# Description: List AWS Batch job queues as JSON
#
# Usage: ./list.sh [options]
#   options:
#     -h, --help    Display this help message
#
# Output:
# - JSON object with "list_job_queue" key (comma-separated job queue names)
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

Description: List AWS Batch job queues as JSON.

Options:
  -h, --help    Display this help message
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

    if ! command -v aws > /dev/null 2>&1; then
        echo "ERROR: aws CLI is required" >&2
        exit 1
    fi
    if ! command -v jq > /dev/null 2>&1; then
        echo "ERROR: jq is required" >&2
        exit 1
    fi

    # List all AWS Batch job queues
    mapfile -t job_queues < <(aws batch describe-job-queues --query 'jobQueues[].jobQueueName' --output text | tr '\t' '\n')

    # Output as JSON with comma-separated list
    if [[ ${#job_queues[@]} -eq 0 ]]; then
        echo '{"list_job_queue": ""}'
        exit 0
    fi

    joined=$(printf '%s\n' "${job_queues[@]}" | jq -R . | jq -s -r 'join(",")')

    jq -n --arg list "$joined" '{list_job_queue: $list}'
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
