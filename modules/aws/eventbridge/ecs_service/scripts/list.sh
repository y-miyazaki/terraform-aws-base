#!/bin/bash
#######################################
# Description: List ECS clusters and services with desired counts as JSON
#
# Usage: ./list.sh [options]
#   options:
#   -h, --help    Display this help message
#
# Output:
# - JSON object with "list_ecs_cluster", "list_ecs_service", "list_desired_count",
#   "list_has_autoscaling", "list_autoscaling_min", "list_autoscaling_max" keys (comma-separated)
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

Description: List ECS clusters and services with desired counts as JSON.

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
#   Main execution function that lists ECS clusters and services
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

    # Initialize arrays
    list_ecs_cluster=()
    list_ecs_service=()
    list_desired_count=()
    list_has_autoscaling=()
    list_autoscaling_min=()
    list_autoscaling_max=()

    # List all ECS clusters
    mapfile -t clusters < <(aws ecs list-clusters --query 'clusterArns[]' --output text | tr '\t' '\n')

    # Iterate through each cluster
    for cluster_arn in "${clusters[@]}"; do
        # Skip if empty
        [[ -z $cluster_arn ]] && continue

        # Extract cluster name from ARN
        cluster_name=$(basename "$cluster_arn")

        # List services in this cluster
        mapfile -t services < <(aws ecs list-services --cluster "$cluster_arn" --query 'serviceArns[]' --output text | tr '\t' '\n')

        # Iterate through each service
        for service_arn in "${services[@]}"; do
            # Skip if empty
            [[ -z $service_arn ]] && continue

            # Extract service name from ARN
            service_name=$(basename "$service_arn")

            # Get desired count for this service
            desired_count=$(aws ecs describe-services \
                --cluster "$cluster_arn" \
                --services "$service_arn" \
                --query 'services[0].desiredCount' \
                --output text 2> /dev/null || echo "1")

            # Default to 1 if empty or None
            if [[ -z $desired_count || $desired_count == "None" ]]; then
                desired_count=1
            fi

            # Check if AutoScaling is configured for this service
            resource_id="service/${cluster_name}/${service_name}"
            autoscaling_info=$(aws application-autoscaling describe-scalable-targets \
                --service-namespace ecs \
                --resource-ids "$resource_id" \
                --scalable-dimension "ecs:service:DesiredCount" \
                --query 'ScalableTargets[0].[MinCapacity,MaxCapacity]' \
                --output text 2> /dev/null || echo "")

            # Parse AutoScaling min/max capacity and set flag
            if [[ -n $autoscaling_info && $autoscaling_info != "None" ]]; then
                has_autoscaling="1"
                autoscaling_min=$(echo "$autoscaling_info" | awk '{print $1}')
                autoscaling_max=$(echo "$autoscaling_info" | awk '{print $2}')
                # Handle case where min/max are empty or None
                [[ -z $autoscaling_min || $autoscaling_min == "None" ]] && autoscaling_min="0"
                [[ -z $autoscaling_max || $autoscaling_max == "None" ]] && autoscaling_max="0"
            else
                has_autoscaling="0"
                autoscaling_min="0"
                autoscaling_max="0"
            fi

            # Add to arrays
            list_ecs_cluster+=("$cluster_name")
            list_ecs_service+=("$service_name")
            list_desired_count+=("$desired_count")
            list_has_autoscaling+=("$has_autoscaling")
            list_autoscaling_min+=("$autoscaling_min")
            list_autoscaling_max+=("$autoscaling_max")
        done
    done

    # Output as JSON
    if [[ ${#list_ecs_cluster[@]} -eq 0 ]]; then
        jq -n \
            --arg list_ecs_cluster "" \
            --arg list_ecs_service "" \
            --arg list_desired_count "" \
            --arg list_has_autoscaling "" \
            --arg list_autoscaling_min "" \
            --arg list_autoscaling_max "" \
            '{
                list_ecs_cluster: $list_ecs_cluster,
                list_ecs_service: $list_ecs_service,
                list_desired_count: $list_desired_count,
                list_has_autoscaling: $list_has_autoscaling,
                list_autoscaling_min: $list_autoscaling_min,
                list_autoscaling_max: $list_autoscaling_max
            }'
        exit 0
    fi

    cluster_joined=$(printf '%s\n' "${list_ecs_cluster[@]}" | jq -R . | jq -s -r 'join(",")')
    service_joined=$(printf '%s\n' "${list_ecs_service[@]}" | jq -R . | jq -s -r 'join(",")')
    count_joined=$(printf '%s\n' "${list_desired_count[@]}" | jq -R . | jq -s -r 'join(",")')
    has_autoscaling_joined=$(printf '%s\n' "${list_has_autoscaling[@]}" | jq -R . | jq -s -r 'join(",")')
    autoscaling_min_joined=$(printf '%s\n' "${list_autoscaling_min[@]}" | jq -R . | jq -s -r 'join(",")')
    autoscaling_max_joined=$(printf '%s\n' "${list_autoscaling_max[@]}" | jq -R . | jq -s -r 'join(",")')

    jq -n \
        --arg list_ecs_cluster "$cluster_joined" \
        --arg list_ecs_service "$service_joined" \
        --arg list_desired_count "$count_joined" \
        --arg list_has_autoscaling "$has_autoscaling_joined" \
        --arg list_autoscaling_min "$autoscaling_min_joined" \
        --arg list_autoscaling_max "$autoscaling_max_joined" \
        '{
            list_ecs_cluster: $list_ecs_cluster,
            list_ecs_service: $list_ecs_service,
            list_desired_count: $list_desired_count,
            list_has_autoscaling: $list_has_autoscaling,
            list_autoscaling_min: $list_autoscaling_min,
            list_autoscaling_max: $list_autoscaling_max
        }'
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
