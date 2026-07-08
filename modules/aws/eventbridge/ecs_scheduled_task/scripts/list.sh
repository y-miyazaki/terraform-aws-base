#!/bin/bash
#######################################
# Description: List EventBridge rules targeting ECS tasks mapped by "ClusterName/TaskDefinitionFamily"
#
# Usage: ./list.sh [options]
#   options:
#     -h, --help    Display this help message
#
# Output:
# - JSON object where keys are "ClusterName/TaskDefinitionFamily" and values are comma-separated rule names
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

Description: List EventBridge rules targeting ECS tasks mapped by cluster and task definition.

Options:
  -h, --help    Display this help message
EOF
    exit 0
}

#######################################
# main: Main execution function
#
# Description:
#   Queries AWS EventBridge to list rules targeting ECS tasks,
#   maps them by cluster/task definition family, and outputs as JSON.
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

    # Get all enabled rule names
    # Note: --state option is not supported in list-rules, so filter in query
    # shellcheck disable=SC2016
    rules=$(aws events list-rules --query 'Rules[?State==`ENABLED`].Name' --output text 2> /dev/null || echo "")

    if [[ -z $rules ]]; then
        echo '{}'
        exit 0
    fi

    # Temporary file to store key-value pairs
    tmp_file=$(mktemp)
    trap 'rm -f "$tmp_file"' EXIT

    # Iterate through rules and check targets
    # Note: This can be slow if there are many rules.
    # Optimization: using xargs for parallel processing could be considered if performance becomes an issue.
    for rule in $rules; do
        # Get targets for the rule
        # We look for targets that have EcsParameters and return: RoleArn(ClusterArn) + TaskDefinitionArn
        # Output format: ClusterArn|TaskDefinitionArn
        # shellcheck disable=SC2016
        targets=$(aws events list-targets-by-rule --rule "$rule" \
            --query 'Targets[?EcsParameters!=`null`].[Arn, EcsParameters.TaskDefinitionArn]' \
            --output text | tr '\t' '|')

        if [[ -n $targets ]]; then
            while read -r line; do
                cluster_arn=$(echo "$line" | cut -d'|' -f1)
                task_def_arn=$(echo "$line" | cut -d'|' -f2)

                # Extract Cluster Name and Task Definition Family
                # ClusterArn: arn:aws:ecs:region:account:cluster/ClusterName
                # TaskDefinitionArn: arn:aws:ecs:region:account:task-definition/Family:Revision

                cluster_name=$(echo "$cluster_arn" | awk -F'/' '{print $NF}')
                # Extract family (remove :revision)
                task_family=$(echo "$task_def_arn" | awk -F'/' '{print $NF}' | cut -d':' -f1)

                if [[ -n $cluster_name && -n $task_family ]]; then
                    echo "$cluster_name/$task_family=$rule" >> "$tmp_file"
                fi
            done <<< "$targets"
        fi
    done

    # Convert the key-value pairs in tmp_file to JSON
    # If multiple rules populate the same key, we define the behavior here.
    # We will join them with commas.

    jq -n -R '
        [inputs | split("=")] |
        group_by(.[0]) |
        map({
            key: .[0][0],
            value: (map(.[1]) | join(","))
        }) |
        from_entries
    ' "$tmp_file"
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
