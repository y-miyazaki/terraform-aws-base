#!/bin/bash
#######################################
# Description: Delete all QuickSight namespaces for the current AWS account
#
# Usage: ./aws_delete_quicksight_namespace.sh [options]
#   options:
#     -d, --dry-run Only list the namespaces that would be deleted
#     -h, --help    Display this help message
#     -y, --yes     Skip the confirmation prompt
#
# Design Rules:
#   - Destructive: deletes every QuickSight namespace in the account, so a confirmation is required.
#   - --dry-run only lists the namespaces; --yes skips the confirmation prompt (required when stdin is not a terminal).
#   - Stops on the first failed deletion and exits non-zero.
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
AWS_ACCOUNT_ID=""
ASSUME_YES=false
DRY_RUN=false

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

Description: Delete all QuickSight namespaces for the current AWS account.

Options:
  -d, --dry-run     Only list the namespaces that would be deleted
  -h, --help        Display this help message
  -y, --yes         Skip the confirmation prompt (required when stdin is not a terminal)

Example: $(basename "$0") --dry-run
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and handles help option
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
#   None (exits on error or help)
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h | --help)
                show_usage
                ;;
            -y | --yes)
                ASSUME_YES=true
                shift
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
# delete_quicksight_namespaces: Delete all QuickSight namespaces
#
# Description:
#   Retrieves all QuickSight namespaces for the current AWS account and deletes each one
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   delete_quicksight_namespaces
#
#######################################
function delete_quicksight_namespaces {
    echo_section "Deleting QuickSight Namespaces"
    log "INFO" "Target AWS account: $AWS_ACCOUNT_ID"

    local -a namespaces
    mapfile -t namespaces < <(aws quicksight list-namespaces --aws-account-id "$AWS_ACCOUNT_ID" --output json | jq -r '.Namespaces[].Name')

    if ((${#namespaces[@]} == 0)); then
        log "INFO" "No namespaces found"
        return 0
    fi

    log "INFO" "Namespaces to delete: ${namespaces[*]}"
    if [[ $DRY_RUN == true ]]; then
        log "INFO" "DRY RUN - no namespaces were deleted"
        return 0
    fi

    if [[ $ASSUME_YES != true ]]; then
        [[ -t 0 ]] || error_exit "Confirmation required: re-run with --yes when stdin is not a terminal"
        local answer
        read -r -p "Type the AWS account ID (${AWS_ACCOUNT_ID}) to confirm deletion: " answer
        [[ $answer == "$AWS_ACCOUNT_ID" ]] || error_exit "Confirmation failed. Aborting."
    fi

    local namespace
    for namespace in "${namespaces[@]}"; do
        log "INFO" "Deleting namespace: $namespace"
        aws quicksight delete-namespace --aws-account-id "$AWS_ACCOUNT_ID" --namespace "$namespace" \
            || error_exit "Failed to delete namespace: $namespace"
    done

    log "INFO" "All namespaces have been deleted"
}

#######################################
# main: Main process
#
# Description:
#   Main entry point that orchestrates the QuickSight namespace deletion process
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
    require_dependencies "aws" "jq"

    # Check AWS credentials before any AWS CLI usage
    check_aws_credentials || error_exit "AWS credentials are not set or invalid."

    # Get AWS account ID after credential validation
    AWS_ACCOUNT_ID=$(get_aws_account_id) || error_exit "Failed to get AWS account ID"

    # Log script start
    echo_section "Starting QuickSight namespace deletion"
    log "INFO" "Target AWS account: $AWS_ACCOUNT_ID"

    # Delete all QuickSight namespaces
    delete_quicksight_namespaces

    echo_section "Process completed successfully"
    log "INFO" "QuickSight namespace deletion completed"
}

# Only call main function if script is executed directly, not sourced
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
