#!/bin/bash
#######################################
# Description: List RDS DB cluster identifiers as JSON
# Usage: ./list.sh
#   -h, --help    Display this help message
#
# This script queries AWS RDS and outputs cluster identifiers.
#######################################

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

Description: List RDS DB cluster identifiers as JSON.

Options:
  -h, --help    Display this help message
EOF
    exit 0
}

#######################################
# main: Main execution function
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

    # List all RDS DB clusters
    mapfile -t clusters < <(aws rds describe-db-clusters --query 'DBClusters[].DBClusterIdentifier' --output text | tr '\t' '\n')

    # Output as JSON with comma-separated list
    joined=$(
        IFS=,
        echo "${clusters[*]}"
    )

    jq -n --arg list "$joined" '{list_db_cluster_identifier: $list}'
}

main "$@"
