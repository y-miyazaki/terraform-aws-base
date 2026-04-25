#!/bin/bash
#######################################
# Description: List EventBridge Scheduler schedule group names as a JSON object
#
# Usage: ./list.sh [options]
#   options:
#   -h, --help    Display this help message
#
# Output:
# - JSON object with "list_schedule_group" key (comma-separated schedule group names)
# - Used by Terraform external data source
#
# Design Rules:
# - Must output valid JSON for Terraform external data source consumption
# - All values in output must be strings
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
show_usage() {
    cat << USAGE
Usage: $(basename "$0") [OPTIONS]

Description:
  List EventBridge Scheduler schedule group names as a JSON object.

Options:
  -h, --help    Display this help message

Output Format:
  JSON object with key "list_schedule_group" containing comma-separated schedule group names.
  Example: {"list_schedule_group": "default,my-group"}

USAGE
    exit 0
}

#######################################
# list_schedule_groups: List schedule group names
#
# Description:
#   Query AWS EventBridge Scheduler to get all schedule group names
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Comma-separated list of schedule group names
#
# Usage:
#   list_schedule_groups
#
#######################################
list_schedule_groups() {
    # Get all schedule groups and extract names
    aws scheduler list-schedule-groups --query 'ScheduleGroups[].Name' --output text 2> /dev/null | tr '\t' ',' || echo ""
}

#######################################
# main: Main function
#
# Description:
#   Main function to process arguments and execute logic
#
# Arguments:
#   $@: Command line arguments
#
# Global Variables:
#   None
#
# Returns:
#   0 on success, 1 on error
#
# Usage:
#   main "$@"
#
#######################################
main() {
    # Process arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_usage
                ;;
        esac
    done

    # Get schedule group list
    local schedule_groups
    schedule_groups=$(list_schedule_groups)

    # Output as JSON (required format for Terraform external data source)
    printf '{"list_schedule_group": "%s"}\n' "$schedule_groups"
}

# Execute main function
main "$@"
