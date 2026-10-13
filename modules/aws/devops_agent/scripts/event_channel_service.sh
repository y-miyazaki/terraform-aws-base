#!/bin/bash
#######################################
# Description: Register, look up, or deregister the AWS DevOps Agent event channel (webhook) service
#
# Usage: ./event_channel_service.sh <register|get|deregister> <service-name> [region]
#   register:     Register the event channel service with the name (no-op when it already exists)
#   get:          Output the service ID of the event channel service with the name as JSON
#   deregister:   Deregister the event channel service with the name (no-op when it does not exist)
#   service-name: Display name of the registration. Only the registration with this name is managed.
#   region:       (Optional) AWS region. Defaults to current AWS region if not specified
#
# Output:
# - get: JSON object with "service_id" key (used by Terraform external data source)
# - register/deregister: progress messages to stderr
#
# Design Rules:
# - Must output valid JSON for Terraform external data source consumption (get)
# - All values in output must be strings (Terraform external requires string values)
# - Only touch the registration whose name matches service-name; never deregister other registrations
# - register and deregister are idempotent
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

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
Usage: $(basename "$0") <register|get|deregister> <service-name> [region]

Description: Register, look up, or deregister the AWS DevOps Agent event channel (webhook) service.

Arguments:
  register|get|deregister    Operation
  service-name               Display name of the registration
  region                     (Optional) AWS region. Defaults to current AWS region if not specified

Options:
  -h, --help    Display this help message

Example: $(basename "$0") get devops-agent-webhook ap-northeast-1
Example: $(basename "$0") register devops-agent-webhook ap-northeast-1
EOF
    exit 0
}

#######################################
# find_service_ids: List service IDs of event channel registrations with the name
#
# Arguments:
#   $1 - service name
#   $@ - region arguments for aws CLI
#
# Returns:
#   Service IDs separated by newlines (outputs to stdout)
#
# Usage:
#   find_service_ids "devops-agent-webhook" --region ap-northeast-1
#
#######################################
function find_service_ids {
    local name="$1"
    shift
    aws devops-agent list-services --filter-service-type eventChannel --output json "$@" \
        | jq -r --arg name "$name" '.services[]? | select(.name == $name) | .serviceId'
}

#######################################
# main: Main execution function
#
# Description:
#   Runs the requested operation against the event channel registration with the name.
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
    case "${1:-}" in
        -h | --help)
            show_usage
            ;;
    esac

    # Parse arguments
    if [[ $# -lt 2 ]]; then
        echo "ERROR: operation and service-name are required" >&2
        exit 1
    fi

    local operation="$1"
    local name="$2"
    local region="${3:-}" # Optional region parameter

    case "$operation" in
        get | register | deregister) ;;
        *)
            echo "ERROR: unknown operation: $operation" >&2
            exit 1
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

    local region_args=()
    if [[ -n $region ]]; then
        region_args=(--region "$region")
    fi

    local service_ids
    service_ids=$(find_service_ids "$name" "${region_args[@]}")
    local count
    count=$(printf '%s' "$service_ids" | grep -c . || true)

    if [[ $count -gt 1 ]]; then
        echo "ERROR: multiple event channel registrations named '$name' found: $(echo "$service_ids" | paste -sd, -)" >&2
        exit 1
    fi

    case "$operation" in
        get)
            if [[ $count -eq 0 ]]; then
                echo "ERROR: event channel registration named '$name' not found" >&2
                exit 1
            fi
            jq -n --arg id "$service_ids" '{service_id: $id}'
            ;;
        register)
            if [[ $count -eq 1 ]]; then
                echo "INFO: event channel registration '$name' already exists: $service_ids" >&2
                return 0
            fi
            aws devops-agent register-service --service eventChannel \
                --service-details '{"eventChannel":{"type":"webhook"}}' \
                --name "$name" --output json "${region_args[@]}" > /dev/null
            echo "INFO: registered event channel '$name'" >&2
            ;;
        deregister)
            if [[ $count -eq 0 ]]; then
                echo "INFO: event channel registration '$name' not found; nothing to deregister" >&2
                return 0
            fi
            aws devops-agent deregister-service --service-id "$service_ids" "${region_args[@]}"
            echo "INFO: deregistered event channel '$name': $service_ids" >&2
            ;;
        *)
            echo "ERROR: unknown operation: $operation" >&2
            exit 1
            ;;
    esac
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
