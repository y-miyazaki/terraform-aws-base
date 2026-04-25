#!/bin/bash
#######################################
# Description: Check if an ORGANIZATION-type Access Analyzer already exists
#
# Usage: ./check_organization_analyzer.sh [options]
#   options:
#     -h, --help    Display this help message
#
# Output:
# - JSON object with "exists" key ("true" or "false")
# - Used by Terraform external data source
#
# Design Rules:
# - Must output valid JSON for Terraform external data source consumption
# - All string values in output (Terraform external requires string values)
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
Usage: $(basename "$0") [options]

Description: Check if an ORGANIZATION-type Access Analyzer already exists.

Options:
  -h, --help    Display this help message

Example: $(basename "$0")
EOF
    exit 0
}

#######################################
# main: Main execution function
#
# Description:
#   Queries AWS IAM Access Analyzer to check if an ORGANIZATION-type
#   analyzer exists and outputs the result as JSON.
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
    done

    # Validate dependencies
    if ! command -v aws > /dev/null 2>&1; then
        echo "ERROR: aws CLI is required" >&2
        exit 1
    fi

    # Read query input from Terraform external data source (JSON via stdin)
    local input
    input=$(cat)
    local region
    region=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('region',''))" 2> /dev/null || echo "")
    local analyzer_name
    analyzer_name=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('analyzer_name',''))" 2> /dev/null || echo "")

    # Build region flag if provided
    local region_flag=()
    if [[ -n "$region" ]]; then
        region_flag=(--region "$region")
    fi

    # Check if an ORGANIZATION-type analyzer exists (excluding Terraform-managed one)
    local count
    count=$(aws accessanalyzer list-analyzers --type ORGANIZATION "${region_flag[@]}" \
        --query "length(analyzers[?name!='${analyzer_name}'])" --output text)

    if [[ "$count" -gt 0 ]]; then
        echo '{"exists": "true"}'
    else
        echo '{"exists": "false"}'
    fi
}

# Only call main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
