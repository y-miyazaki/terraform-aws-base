#!/bin/bash
#######################################
# Description: List delegated service principals for the specified AWS account
#
# Usage: ./check_delegated_services.sh <account-id>
#   account-id: AWS account ID to check
#
# Output:
# - JSON object with "principals" key containing a JSON array of service principal strings
# - Used by Terraform external data source
#
# Design Rules:
# - Must output valid JSON for Terraform external data source consumption
# - All values in output must be strings (Terraform external requires string values)
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
#   Exit code 0
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") <account-id>

Description: List delegated service principals for the specified AWS account.

Arguments:
  account-id    AWS account ID to check

Options:
  -h, --help    Display this help message

Example: $(basename "$0") 123456789012
EOF
    exit 0
}

#######################################
# main: Main execution function
#
# Description:
#   Queries AWS Organizations to list delegated service principals
#   for the specified account and outputs the result as JSON.
#
# Arguments:
#   $1 - AWS account ID to check
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   main "123456789012"
#
#######################################
function main {
    # Parse arguments
    if [[ $# -lt 1 ]]; then
        echo "ERROR: account-id is required" >&2
        show_usage
    fi

    case $1 in
        -h | --help)
            show_usage
            ;;
    esac

    local account_id="$1"

    # Validate dependencies
    if ! command -v aws > /dev/null 2>&1; then
        echo "ERROR: aws CLI is required" >&2
        exit 1
    fi
    if ! command -v jq > /dev/null 2>&1; then
        echo "ERROR: jq is required" >&2
        exit 1
    fi

    # Get delegated service principals
    local principals
    principals=$(aws organizations list-delegated-services-for-account \
        --account-id "$account_id" \
        --query 'DelegatedServices[].ServicePrincipal' \
        --output json)

    # External data source requires all values to be strings
    # Convert JSON array to a JSON-safe string value using jq
    jq -n --arg p "$principals" '{principals: $p}'
}

# Only call main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
