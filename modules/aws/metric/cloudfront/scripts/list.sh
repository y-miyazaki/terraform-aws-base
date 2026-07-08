#!/bin/bash
#######################################
# Description: List CloudFront distribution IDs and custom domains as a JSON object
#
# Usage: ./list.sh [region]
#   region: (Optional) AWS region
#
# Output:
# - JSON object with "list_distribution" key (comma-separated distribution IDs)
# - JSON object with "list_domain" key (comma-separated custom domains/CNAME)
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

Description: List CloudFront distribution IDs and custom domains as a JSON object.

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

    # Build AWS CLI command to get distribution IDs and custom domains (CNAME)
    # Note: We extract the first CNAME if available, otherwise use the distribution ID
    local aws_cmd="aws cloudfront list-distributions --query 'DistributionList.Items[].[Id,DomainName,Aliases.Items[0]]' --output json"

    # Add region if provided (CloudFront is global, but we keep the parameter for consistency)
    if [[ -n $region ]]; then
        aws_cmd="$aws_cmd --region \"$region\""
    fi

    # Get CloudFront distribution IDs, domains, and CNAMEs
    local distributions
    distributions=$(eval "$aws_cmd")

    # Handle null/empty result (no distributions)
    if [[ -z $distributions ]] || [[ $distributions == "null" ]]; then
        jq -n '{list_distribution: "", list_domain: ""}'
        return 0
    fi

    # Extract IDs and custom domains (CNAME or fall back to CloudFront domain)
    local ids
    local domains
    ids=$(echo "$distributions" | jq -r 'if . == null or length == 0 then "" else [.[] | .[0]] | join(",") end')
    # Use CNAME (first alias) if available, otherwise use the CloudFront domain
    domains=$(echo "$distributions" | jq -r 'if . == null or length == 0 then "" else [.[] | (.[2] // .[1])] | join(",") end')

    # Output as JSON - all values must be strings for Terraform external data source
    jq -n --arg d "$ids" --arg h "$domains" '{list_distribution: $d, list_domain: $h}'
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
