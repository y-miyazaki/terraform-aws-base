#!/bin/bash
#######################################
# Description: Create, look up, or delete the generic webhook (event channel association) of an AWS DevOps Agent Space
#
# Usage: ./webhook_association.sh create <agent-space-id> <service-id> <secret-id> [region]
#        ./webhook_association.sh get    <agent-space-id> <service-id> [region]
#        ./webhook_association.sh delete <agent-space-id> <service-id> [region]
#   create: Associate the event channel service with the Agent Space and store the webhook credentials
#           (returned only once, at creation) in AWS Secrets Manager. An existing association of the service
#           is recreated so that a fresh secret is always stored (the webhook URL changes).
#   get:    Output the association ID, webhook URL and webhook type as JSON
#   delete: Disassociate the event channel service from the Agent Space (no-op when not associated)
#   agent-space-id: Agent Space ID
#   service-id:     Service ID of the event channel registration
#   secret-id:      Secrets Manager secret ARN or name to store the credentials in
#   region:         (Optional) AWS region. Defaults to current AWS region if not specified
#
# Output:
# - get: JSON object with "association_id", "webhook_id", "webhook_type" and "webhook_url" keys
#   (used by Terraform external data source)
# - create: Secrets Manager secret value (JSON):
#   {"webhook_id": "...", "webhook_secret": "...", "webhook_type": "hmac|apikey", "webhook_url": "..."}
#   ("webhook_secret" holds the HMAC signing secret, or the API key for the apikey type)
# - create/delete: progress messages to stderr
#
# Design Rules:
# - Must output valid JSON for Terraform external data source consumption (get)
# - All values in output must be strings (Terraform external requires string values)
# - Never print the webhook secret to stdout/stderr or pass it as a command-line argument;
#   it is written to Secrets Manager through a temporary file readable only by the current user
# - delete is idempotent
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
Usage: $(basename "$0") create <agent-space-id> <service-id> <secret-id> [region]
       $(basename "$0") get    <agent-space-id> <service-id> [region]
       $(basename "$0") delete <agent-space-id> <service-id> [region]

Description: Create, look up, or delete the generic webhook of an AWS DevOps Agent Space.

Arguments:
  agent-space-id    Agent Space ID
  service-id        Service ID of the event channel registration
  secret-id         (create only) Secrets Manager secret ARN or name to store the credentials in
  region            (Optional) AWS region. Defaults to current AWS region if not specified

Options:
  -h, --help    Display this help message

Example: $(basename "$0") get as-0123456789abcdef svc-0123456789abcdef ap-northeast-1
EOF
    exit 0
}

#######################################
# find_association_ids: List association IDs of the service in the Agent Space
#
# Arguments:
#   $1 - agent space ID
#   $2 - service ID
#   $@ - region arguments for aws CLI
#
# Returns:
#   Association IDs separated by newlines (outputs to stdout)
#
# Usage:
#   find_association_ids "as-1" "svc-1" --region ap-northeast-1
#
#######################################
function find_association_ids {
    local agent_space_id="$1"
    local service_id="$2"
    shift 2
    aws devops-agent list-associations --agent-space-id "$agent_space_id" --output json "$@" \
        | jq -r --arg sid "$service_id" '.associations[]? | select(.serviceId == $sid) | .associationId'
}

#######################################
# store_secret: Write the webhook credentials from an AssociateService response to Secrets Manager
#
# Arguments:
#   $1 - secret ID
#   $2 - AssociateService response (JSON)
#   $@ - region arguments for aws CLI
#
# Returns:
#   0 on success, non-zero on failure
#
# Usage:
#   store_secret "arn:aws:secretsmanager:..." "$response" --region ap-northeast-1
#
#######################################
function store_secret {
    local secret_id="$1"
    local response="$2"
    shift 2

    local input_file
    input_file=$(mktemp)
    chmod 600 "$input_file"
    # shellcheck disable=SC2064
    trap "rm -f '$input_file'" RETURN

    # The secret is passed via a file (not argv) so that it does not appear in the process list.
    if ! printf '%s' "$response" | jq -e --arg sid "$secret_id" '
        .webhook as $w
        | ($w.webhookSecret // $w.apiKey // "") as $secret
        | if $secret == "" then error("the response does not contain webhook credentials") else . end
        | {
            SecretId: $sid,
            SecretString: ({
              webhook_id: ($w.webhookId // ""),
              webhook_secret: $secret,
              webhook_type: ($w.webhookType // ""),
              webhook_url: ($w.webhookUrl // "")
            } | tojson)
          }
      ' > "$input_file"; then
        return 1
    fi

    aws secretsmanager put-secret-value --cli-input-json "file://$input_file" --output json "$@" > /dev/null
}

#######################################
# main: Main execution function
#
# Description:
#   Runs the requested operation against the event channel association of the Agent Space.
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

    local operation="${1:-}"
    local min_args=3
    case "$operation" in
        create) min_args=4 ;;
        get | delete) ;;
        *)
            echo "ERROR: unknown operation: $operation" >&2
            exit 1
            ;;
    esac

    # Parse arguments
    if [[ $# -lt $min_args ]]; then
        echo "ERROR: missing arguments for $operation (see --help)" >&2
        exit 1
    fi

    local agent_space_id="$2"
    local service_id="$3"
    local secret_id=""
    local region=""
    if [[ $operation == "create" ]]; then
        secret_id="$4"
        region="${5:-}"
    else
        region="${4:-}"
    fi

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

    local association_ids
    association_ids=$(find_association_ids "$agent_space_id" "$service_id" "${region_args[@]}")
    local count
    count=$(printf '%s' "$association_ids" | grep -c . || true)

    if [[ $count -gt 1 ]]; then
        echo "ERROR: multiple associations of service $service_id found in $agent_space_id: $(echo "$association_ids" | paste -sd, -)" >&2
        exit 1
    fi

    case "$operation" in
        get)
            if [[ $count -eq 0 ]]; then
                echo "ERROR: association of service $service_id not found in $agent_space_id" >&2
                exit 1
            fi
            aws devops-agent list-webhooks --agent-space-id "$agent_space_id" --association-id "$association_ids" \
                --output json "${region_args[@]}" \
                | jq -e --arg aid "$association_ids" '
                  (.webhooks // []) as $w
                  | ([$w[] | select(.webhookType == "hmac")] + $w)[0]
                  | if . == null then error("no webhook found for the association") else . end
                  | {
                      association_id: $aid,
                      webhook_id: (.webhookId // ""),
                      webhook_type: (.webhookType // ""),
                      webhook_url: (.webhookUrl // "")
                    }
                '
            ;;
        create)
            if [[ $count -eq 1 ]]; then
                # The secret of an existing association cannot be retrieved; recreate it to get a fresh one.
                echo "INFO: recreating existing association $association_ids to obtain a fresh webhook secret" >&2
                aws devops-agent disassociate-service --agent-space-id "$agent_space_id" \
                    --association-id "$association_ids" "${region_args[@]}" > /dev/null
            fi
            local response
            response=$(aws devops-agent associate-service --agent-space-id "$agent_space_id" \
                --service-id "$service_id" --configuration '{"eventChannel":{}}' --output json "${region_args[@]}")
            if ! store_secret "$secret_id" "$response" "${region_args[@]}"; then
                echo "ERROR: the webhook was created but its secret could not be stored in $secret_id." >&2
                echo "       Run terraform apply again (the webhook is recreated with a new secret)," >&2
                echo "       or rotate the webhook in the console and store the secret manually." >&2
                exit 1
            fi
            echo "INFO: created webhook association and stored the credentials in $secret_id" >&2
            ;;
        delete)
            if [[ $count -eq 0 ]]; then
                echo "INFO: association of service $service_id not found in $agent_space_id; nothing to delete" >&2
                return 0
            fi
            aws devops-agent disassociate-service --agent-space-id "$agent_space_id" \
                --association-id "$association_ids" "${region_args[@]}" > /dev/null
            echo "INFO: deleted webhook association $association_ids" >&2
            ;;
    esac
}

# Only call main if script is executed directly
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
