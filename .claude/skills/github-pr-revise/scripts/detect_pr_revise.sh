#!/bin/bash
#######################################
# Description: Detect PR revise intake facts for github-pr-revise automation
#
# Usage: ./detect_pr_revise.sh
#
# Output:
# - JSON object with status, skip, message, and result
#
# Design Rules:
# - Consume PR comment facts from environment variables
# - Hydrate PR_* from GITHUB_EVENT_PATH when unset
# - Skip bot actors; require maintainer association on all intake paths when known
# - Require @mention on comment webhooks only
# - repository_dispatch / workflow_dispatch bypass mention (explicit trusted intake)
# - Output structured JSON via shared lib/json.sh
# - Exit 0 on success; fatal errors emit status=error JSON and exit 1
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq
#
# Optional environment:
#   PR_NUMBER         Pull request number (required unless GITHUB_EVENT_PATH hydrates it)
#   PR_MENTION        Mention token required in comment body (default: @loop)
#   PR_COMMENT_BODY   Comment body to match against PR_MENTION
#   PR_ACTOR          Comment or event actor login
#   PR_ACTOR_TYPE     Comment or event actor type (User, Bot, ...)
#   PR_ACTOR_ASSOCIATION Comment or sender author_association when present
#   GITHUB_EVENT_PATH Path to GitHub webhook event JSON (hydrates PR_* when PR_NUMBER unset)
#   GITHUB_EVENT_NAME GitHub event name (mention gate applies only to comment webhooks)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# output_error: Print structured JSON error and exit
#
# Globals:
#   None
#
# Arguments:
#   $1 - Error message
#
# Outputs:
#   JSON error object to stdout
#
# Returns:
#   Exits with code 1
#
# Usage:
#   output_error "PR_NUMBER is required"
#
#######################################
function output_error {
    local message="$1"

    if ! command -v jq &> /dev/null; then
        json_emit_minimal_error "${message}"
        exit 1
    fi

    json_object \
        status "error" \
        skip "true" \
        message "${message}"
    exit 1
}

#######################################
# ensure_dependencies: Fail with detect error JSON when tools are missing
#
# Globals:
#   None
#
# Arguments:
#   $@ - Required tools/commands
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on missing dependencies)
#
# Usage:
#   ensure_dependencies bash jq
#
#######################################
function ensure_dependencies {
    local -a missing_tools=()
    local tool

    while IFS= read -r tool; do
        if [[ -n ${tool} ]]; then
            missing_tools+=("${tool}")
        fi
    done < <(validate_dependencies "$@" || true)

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        output_error "Missing required tools: ${missing_tools[*]}. Please install them and ensure they are in PATH."
    fi
}

#######################################
# hydrate_pr_env_from_event: Populate PR_* from GITHUB_EVENT_PATH
#
# Globals:
#   GITHUB_EVENT_PATH
#   PR_NUMBER (set)
#   PR_COMMENT_BODY (set)
#   PR_ACTOR (set)
#   PR_ACTOR_TYPE (set)
#   PR_ACTOR_ASSOCIATION (set)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success or when event file is absent
#
# Usage:
#   hydrate_pr_env_from_event
#
#######################################
function hydrate_pr_env_from_event {
    local event_path="${GITHUB_EVENT_PATH:-}"
    local pr_number comment_body actor_type actor actor_association

    if [[ -z ${event_path} || ! -f ${event_path} ]]; then
        return 0
    fi

    pr_number="$(jq -r '
        if .pull_request.number then (.pull_request.number | tostring)
        elif .issue.pull_request then (.issue.number | tostring)
        elif .client_payload.pr_number then (.client_payload.pr_number | tostring)
        else empty end
    ' "${event_path}")"
    comment_body="$(jq -r '.comment.body // empty' "${event_path}")"
    if [[ -z ${comment_body} ]]; then
        comment_body="$(jq -r '.client_payload.feedback // .client_payload.comment_body // empty' "${event_path}")"
    fi
    if [[ -z ${comment_body} ]]; then
        comment_body="$(jq -r '.inputs.feedback // empty' "${event_path}")"
    fi
    actor_type="$(jq -r '.comment.user.type // .sender.type // empty' "${event_path}")"
    actor="$(jq -r '.comment.user.login // .sender.login // empty' "${event_path}")"
    actor_association="$(jq -r '.comment.author_association // .sender.author_association // empty' "${event_path}")"

    if [[ -z ${PR_NUMBER:-} && -n ${pr_number} ]]; then
        PR_NUMBER="${pr_number}"
    fi
    if [[ -z ${PR_COMMENT_BODY:-} && -n ${comment_body} ]]; then
        PR_COMMENT_BODY="${comment_body}"
    fi
    if [[ -z ${PR_ACTOR_TYPE:-} && -n ${actor_type} ]]; then
        PR_ACTOR_TYPE="${actor_type}"
    fi
    if [[ -z ${PR_ACTOR:-} && -n ${actor} ]]; then
        PR_ACTOR="${actor}"
    fi
    if [[ -z ${PR_ACTOR_ASSOCIATION:-} && -n ${actor_association} ]]; then
        PR_ACTOR_ASSOCIATION="${actor_association}"
    fi
}

#######################################
# validate_pr_number: Fail when PR_NUMBER is not a positive integer
#
# Globals:
#   None
#
# Arguments:
#   $1 - PR number string
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on invalid input)
#
# Usage:
#   validate_pr_number "${PR_NUMBER}"
#
#######################################
function validate_pr_number {
    local pr_number="$1"

    if [[ ! ${pr_number} =~ ^[1-9][0-9]*$ ]]; then
        output_error "PR_NUMBER must be a positive integer"
    fi
}

#######################################
# comment_body_contains_mention: Match mention token without substring false positives
#
# Globals:
#   None
#
# Arguments:
#   $1 - Comment body
#   $2 - Mention token (for example @loop)
#
# Outputs:
#   None
#
# Returns:
#   0 when the mention token is present, 1 otherwise
#
# Usage:
#   if comment_body_contains_mention "${body}" "${mention}"; then ...
#
#######################################
function comment_body_contains_mention {
    local body="$1"
    local mention="$2"
    local escaped

    if [[ -z ${body} || -z ${mention} ]]; then
        return 1
    fi

    escaped="${mention//\/\\/}"
    escaped="${escaped//./\.}"
    escaped="${escaped//+/\+}"
    escaped="${escaped//\*/\*}"
    escaped="${escaped//\?/\?}"
    escaped="${escaped//\^/\^}"
    escaped="${escaped//\$/\$}"
    escaped="${escaped//\{/\{}"
    escaped="${escaped//\}/\}}"
    escaped="${escaped//\(/\(}"
    escaped="${escaped//\)/\)}"
    escaped="${escaped//\[/\[}"
    escaped="${escaped//\]/\]}"
    escaped="${escaped//|/\|}"

    [[ ${body} =~ (^|[^[:alnum:]_])${escaped}([^[:alnum:]_]|$) ]]
}

#######################################
# actor_association_allowed: Return whether the PR actor association is trusted
#
# Globals:
#   PR_ACTOR_ASSOCIATION
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when association is allowed or unset, 1 otherwise
#
# Usage:
#   if actor_association_allowed; then ...
#
#######################################
function actor_association_allowed {
    local assoc="${PR_ACTOR_ASSOCIATION:-}"

    if [[ -z ${assoc} ]]; then
        return 0
    fi

    case "${assoc}" in
        MEMBER | OWNER | COLLABORATOR) return 0 ;;
        *) return 1 ;;
    esac
}

#######################################
# mention_gate_applies: Return whether mention gating applies to this event
#
# Globals:
#   GITHUB_EVENT_NAME
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when mention gating applies, 1 for dispatch events
#
# Usage:
#   if mention_gate_applies; then ...
#
#######################################
function mention_gate_applies {
    case "${GITHUB_EVENT_NAME:-}" in
        repository_dispatch | workflow_dispatch) return 1 ;;
        *) return 0 ;;
    esac
}

#######################################
# should_skip_pr_revise: Return whether detect should skip this event
#
# Globals:
#   PR_ACTOR_TYPE
#   PR_COMMENT_BODY
#   PR_MENTION
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when the event should be skipped, 1 otherwise
#
# Usage:
#   if should_skip_pr_revise; then skip="true"; fi
#
#######################################
function should_skip_pr_revise {
    local mention="${PR_MENTION:-@loop}"
    local body="${PR_COMMENT_BODY:-}"

    if [[ ${PR_ACTOR_TYPE:-} == "Bot" ]]; then
        return 0
    fi

    if ! actor_association_allowed; then
        return 0
    fi

    if mention_gate_applies; then
        if ! comment_body_contains_mention "${body}" "${mention}"; then
            return 0
        fi
    elif [[ -z ${body} ]]; then
        return 0
    fi

    return 1
}

#######################################
# build_skip_message: Resolve skip reason message for output JSON
#
# Globals:
#   PR_NUMBER
#   PR_ACTOR_TYPE
#   PR_COMMENT_BODY
#   PR_MENTION
#
# Arguments:
#   None
#
# Outputs:
#   Skip reason string on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   message="$(build_skip_message)"
#
#######################################
function build_skip_message {
    local mention="${PR_MENTION:-@loop}"
    local body="${PR_COMMENT_BODY:-}"

    if [[ -z ${PR_NUMBER:-} ]]; then
        printf '%s' "github-pr-revise: PR_NUMBER required"
        return 0
    fi

    if [[ ${PR_ACTOR_TYPE:-} == "Bot" ]]; then
        printf '%s' "github-pr-revise: bot actor skipped"
        return 0
    fi

    if ! actor_association_allowed; then
        printf '%s' "github-pr-revise: maintainer association required"
        return 0
    fi

    if mention_gate_applies; then
        if [[ -n ${body} ]] && ! comment_body_contains_mention "${body}" "${mention}"; then
            printf 'github-pr-revise: mention %s not found' "${mention}"
            return 0
        fi
        if [[ -z ${body} ]]; then
            printf '%s' "github-pr-revise: comment body required"
            return 0
        fi
    elif [[ -z ${body} ]]; then
        printf '%s' "github-pr-revise: explicit dispatch requires feedback"
        return 0
    fi

    printf '%s' "github-pr-revise: skipped"
}

#######################################
# build_result_json: Build the result object JSON
#
# Globals:
#   PR_NUMBER
#   PR_MENTION
#   PR_COMMENT_BODY
#   PR_ACTOR
#
# Arguments:
#   None
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   result_json="$(build_result_json)"
#
#######################################
function build_result_json {
    local mention="${PR_MENTION:-@loop}"
    local body="${PR_COMMENT_BODY:-}"

    json_object \
        pr_number "${PR_NUMBER}" \
        mention "${mention}" \
        comment_body "${body}" \
        actor "${PR_ACTOR:-}"
}

#######################################
# output_json: Print structured detect JSON result
#
# Globals:
#   PR_NUMBER
#   PR_MENTION
#   PR_COMMENT_BODY
#   PR_ACTOR
#   PR_ACTOR_TYPE
#
# Arguments:
#   $1 - skip flag (true|false)
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   None
#
# Usage:
#   output_json "${skip}"
#
#######################################
function output_json {
    local skip="$1"
    local message result_json

    if [[ ${skip} == "true" ]]; then
        message="$(build_skip_message)"
        if [[ -z ${PR_NUMBER:-} ]]; then
            json_object \
                status "ok" \
                skip "true" \
                message "${message}" \
                result "{}"
            return 0
        fi

        json_object \
            status "ok" \
            skip "true" \
            message "${message}" \
            result "$(json_object pr_number "${PR_NUMBER}" mention "${PR_MENTION:-@loop}")"
        return 0
    fi

    result_json="$(build_result_json)"
    json_object \
        status "ok" \
        skip "false" \
        message "github-pr-revise: proceed" \
        result "${result_json}"
}

#######################################
# main: Validate inputs, evaluate skip policy, emit detect JSON
#
# Globals:
#   PR_NUMBER
#   PR_MENTION
#   PR_COMMENT_BODY
#   PR_ACTOR
#   PR_ACTOR_TYPE
#
# Arguments:
#   None
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success; exits 1 on fatal validation errors
#
# Usage:
#   main
#
#######################################
function main {
    local skip="false"

    ensure_dependencies bash jq

    hydrate_pr_env_from_event

    PR_NUMBER="${PR_NUMBER:-}"
    PR_COMMENT_BODY="${PR_COMMENT_BODY:-}"
    PR_ACTOR_TYPE="${PR_ACTOR_TYPE:-}"
    PR_ACTOR="${PR_ACTOR:-}"
    PR_MENTION="${PR_MENTION:-@loop}"

    if [[ -z ${PR_NUMBER} ]]; then
        output_json "true"
        return 0
    fi

    validate_pr_number "${PR_NUMBER}"

    if should_skip_pr_revise; then
        skip="true"
    fi

    output_json "${skip}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
