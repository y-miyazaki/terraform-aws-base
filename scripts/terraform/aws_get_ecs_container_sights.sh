#!/bin/bash
#######################################
# Description: Retrieves ECS task definition families and outputs them in Terraform configuration format
# Usage: ./aws_ecs_container_sights.sh [options]
#   options:
#     -h, --help    Display this help message
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script
#
# Arguments:
#   None
#
# Returns:
#   None (exits with status 0)
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "This script retrieves ECS task definition families and outputs them in a format"
    echo "suitable for Terraform configuration."
    echo ""
    echo "Options:"
    echo "  -h, --help    Display this help message"
    echo ""
    echo "Example: $(basename "$0")"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and handles help option
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Returns:
#   None (exits on error or help)
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
# extract_unique_families: Extract unique task definition families
#
# Description:
#   Processes task definition ARNs and extracts unique family names
#
# Arguments:
#   $1 - Space-separated string of task definition ARNs
#
# Returns:
#   Newline-separated list of unique family names
#
# Usage:
#   families=$(extract_unique_families "$task_definitions")
#
#######################################
function extract_unique_families {
    local task_definitions="$1"
    local unique_families=()

    echo_section "Processing task definition families"

    for task_definition in $task_definitions; do
        # Extract task definition family
        local family
        family=$(echo "$task_definition" | awk -F'/' '{print $NF}' | awk -F':' '{print $1}')

        # Add family only if it doesn't already exist in the array
        local family_exists=false
        for existing_family in "${unique_families[@]}"; do
            if [[ "$existing_family" == "$family" ]]; then
                family_exists=true
                break
            fi
        done

        if [[ "$family_exists" == "false" ]]; then
            unique_families+=("$family")
        fi
    done

    # Return the unique families as a space-separated string
    printf '%s\n' "${unique_families[@]}"
}

#######################################
# generate_terraform_output: Generate Terraform configuration format output
#
# Description:
#   Formats task definition families into Terraform configuration format
#
# Arguments:
#   $@ - Array of task definition family names
#
# Returns:
#   String containing formatted Terraform configuration items
#
# Usage:
#   output=$(generate_terraform_output "${families[@]}")
#
#######################################
function generate_terraform_output {
    local families=("$@")
    local items=""

    echo_section "Generating Terraform configuration format"

    for family in "${families[@]}"; do
        items+="  {\n    ClusterName = \"\"\n    TaskDefinitionFamily = \"$family\"\n  },\n"
    done

    # Remove trailing comma if items is not empty
    if [ -n "$items" ]; then
        items=${items%,*}
    fi

    echo "$items"
}

#######################################
# get_task_definitions: Retrieve ECS task definitions from AWS
#
# Description:
#   Retrieves all ECS task definition ARNs from AWS using AWS CLI
#
# Arguments:
#   None
#
# Returns:
#   String containing space-separated task definition ARNs
#
# Usage:
#   task_definitions=$(get_task_definitions)
#
#######################################
function get_task_definitions {
    echo_section "Retrieving ECS task definitions"

    if ! task_definitions=$(aws ecs list-task-definitions --output json | jq -r '.taskDefinitionArns[]'); then
        error_exit "Failed to retrieve ECS task definitions"
    fi

    echo "$task_definitions"
}

#######################################
# output_result: Output the final result
#
# Description:
#   Outputs the formatted Terraform configuration in JSON array format
#
# Arguments:
#   $1 - Formatted Terraform configuration items string
#
# Returns:
#   None (outputs to stdout)
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
# main: Main execution function
#
# Description:
#   Main entry point that orchestrates the ECS task definition family extraction process
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Returns:
#   None (exits with appropriate status code)
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
    if ! check_aws_credentials; then
        error_exit "AWS credentials are not set or invalid."
    fi

    # Log script start
    echo_section "Starting ECS task definition family extraction"
    log "INFO" "Retrieving ECS task definitions from AWS"

    # Get task definitions from AWS
    local task_definitions
    task_definitions=$(get_task_definitions)

    # Extract unique families
    local unique_families
    readarray -t unique_families < <(extract_unique_families "$task_definitions")

    # Generate Terraform configuration format
    local terraform_output
    terraform_output=$(generate_terraform_output "${unique_families[@]}")

    # Output the final result
    output_result "$terraform_output"

    echo_section "Process completed successfully"
    log "INFO" "Successfully processed ${#unique_families[@]} unique task definition families"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
