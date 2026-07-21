#!/bin/bash
#######################################
# Description: Retrieves SQS Dead Letter Queue (DLQ) information and outputs them in Terraform configuration format
#
# Usage: ./aws_sqs_dlq.sh [options]
#   options:
#     -h, --help    Display this help message
#
# Output:
# - SQS DLQ information in Terraform configuration format to stdout
#
# Design Rules:
# - Outputs Terraform-compatible HCL format
# - Queries all SQS queues and identifies DLQ relationships
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Writes to stdout
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options]

Description: This script retrieves SQS Dead Letter Queue (DLQ) information and outputs them in a format
             suitable for Terraform configuration.

Options:
  -h, --help    Display this help message

Example: $(basename "$0")
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and options, handling help and unknown options
#
# Globals:
#   None
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
#
# Returns:
#   Exits with error if unknown arguments are provided
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                error_exit "Unexpected argument: $1"
                ;;
        esac
    done
}

#######################################
# generate_terraform_output: Generate Terraform configuration format output
#
# Description:
#   Generates Terraform configuration format output for DLQ information
#
# Globals:
#   None
#
# Arguments:
#   $@ - Array of DLQ names
#
# Outputs:
#   formatted Terraform configuration items as a string
#
# Returns:
#   0 on success
#
# Usage:
#   terraform_output=$(generate_terraform_output "${dlqs[@]}")
#
#######################################
function generate_terraform_output {
    local dlqs=("$@")
    local items=""

    echo_section "Generating Terraform configuration format"

    for dlq in "${dlqs[@]}"; do
        items+="  {\n    QueueName = \"$dlq\"\n  },\n"
    done

    # Remove trailing comma if items is not empty
    if [ -n "$items" ]; then
        items=${items%,*}
    fi

    echo "$items"
}

#######################################
# get_sqs_queues: Retrieve SQS queue URLs from AWS
#
# Description:
#   Retrieves all SQS queue URLs from AWS using the AWS CLI and outputs them
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   queue URLs as newline-separated strings, exits with error on failure
#
# Returns:
#   0 on success
#
# Usage:
#   queue_urls=$(get_sqs_queues)
#
#######################################
function get_sqs_queues {
    echo_section "Retrieving SQS queue information"

    if ! queue_urls=$(aws sqs list-queues | jq -r '.QueueUrls[]'); then
        error_exit "Failed to retrieve SQS queue URLs"
    fi

    echo "$queue_urls"
}

#######################################
# output_result: Output the final result
#
# Description:
#   Outputs the final formatted result in JSON array format
#
# Globals:
#   None
#
# Arguments:
#   $1 - Formatted items string
#
# Outputs:
#   the result to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   output_result "$formatted_items"
#
#######################################
function output_result {
    local formatted_items="$1"

    echo_section "Generating output"
    echo "["
    echo -e "$formatted_items"
    echo "]"
}

#######################################
# process_dlq_information: Process and extract DLQ information
#
# Description:
#   Processes SQS queue URLs to extract Dead Letter Queue information from RedrivePolicy
#
# Globals:
#   None
#
# Arguments:
#   $1 - Newline-separated string of SQS queue URLs
#
# Outputs:
#   unique DLQ names as newline-separated strings
#
# Returns:
#   0 on success
#
# Usage:
#   unique_dlqs=$(process_dlq_information "$queue_urls")
#
#######################################
function process_dlq_information {
    local queue_urls="$1"
    local dlqs=()

    echo_section "Processing Dead Letter Queue information"

    for queue_url in $queue_urls; do
        # Get queue attributes (RedrivePolicy contains DLQ information)
        if redrive_policy=$(aws sqs get-queue-attributes --queue-url "$queue_url" --attribute-names RedrivePolicy 2> /dev/null | jq -r '.Attributes.RedrivePolicy' 2> /dev/null); then
            if [ "$redrive_policy" != "null" ] && [ -n "$redrive_policy" ]; then
                # Extract DLQ ARN from RedrivePolicy
                if dlq_arn=$(echo "$redrive_policy" | jq -r '.deadLetterTargetArn' 2> /dev/null); then
                    if [ "$dlq_arn" != "null" ] && [ -n "$dlq_arn" ]; then
                        # Extract queue name from ARN
                        dlq_name=$(echo "$dlq_arn" | awk -F':' '{print $NF}')

                        # Add DLQ name only if it doesn't already exist in the array
                        dlq_exists=false
                        for existing_dlq in "${dlqs[@]}"; do
                            if [[ $existing_dlq == "$dlq_name" ]]; then
                                dlq_exists=true
                                break
                            fi
                        done

                        if [[ $dlq_exists == "false" ]]; then
                            dlqs+=("$dlq_name")
                        fi
                    fi
                fi
            fi
        fi
    done

    # Return the unique DLQs as a newline-separated string
    printf '%s\n' "${dlqs[@]}"
}

#######################################
# main: Main process
#
# Description:
#   Main function to execute the script logic for retrieving SQS DLQ information
#
# Globals:
#   None
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # Validate required dependencies
    validate_dependencies "aws" "jq"

    # Check AWS credentials before any AWS CLI usage
    check_aws_credentials || error_exit "AWS credentials are not set or invalid."

    # Log script start
    echo_section "Starting SQS DLQ information extraction"
    log "INFO" "Retrieving SQS queue information from AWS"

    # Get SQS queue URLs from AWS
    local queue_urls
    queue_urls=$(get_sqs_queues)

    # Process and extract DLQ information
    local unique_dlqs
    readarray -t unique_dlqs < <(process_dlq_information "$queue_urls")

    # Generate Terraform configuration format
    local terraform_output
    terraform_output=$(generate_terraform_output "${unique_dlqs[@]}")

    # Output the final result
    output_result "$terraform_output"

    echo_section "Process completed successfully"
    log "INFO" "Successfully processed ${#unique_dlqs[@]} unique Dead Letter Queues"
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
