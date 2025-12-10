#!/bin/bash
#######################################
# Description: List SQS Dead Letter Queue ARNs as a JSON object
# Usage: ./list.sh
#   -h, --help    Display this help message
#
# This script queries AWS SQS and outputs Dead Letter Queue ARNs in JSON format.
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
    echo "Description: List SQS Dead Letter Queue ARNs as a JSON object."
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

    # Get SQS Dead Letter Queue ARNs
    mapfile -t list < <(
        aws sqs list-queues | jq -r '.QueueUrls[]' | while read -r url; do
            arn=$(aws sqs get-queue-attributes --queue-url "$url" --attribute-names RedrivePolicy | jq -r '.Attributes.RedrivePolicy' | jq -r '.deadLetterTargetArn // empty')
            if [ -n "$arn" ]; then
                echo "$arn"
            fi
        done
    )

    # Output as JSON
    if [[ ${#list[@]} -eq 0 ]]; then
        echo '{"list": ""}'
        exit 0
    fi

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
