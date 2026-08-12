#!/bin/bash
#######################################
# Description: Detect GitHub issue entity facts for issue-triage automation
#
# Usage: ./detect_issue.sh
#
# Output:
# - JSON object with status, skip, result, verifier_context
#
# Design Rules:
# - Consume issue event fields from environment variables
# - Skip bot actors and bot issue comments
# - Output structured JSON via shared lib/json.sh
# - Exit 0 on success; fatal errors emit status=error JSON and exit 1
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq
#
# Optional environment:
#   ISSUE_NUMBER              GitHub issue number (required unless GITHUB_EVENT_PATH is set)
#   ISSUE_TITLE               Issue title
#   ISSUE_BODY                Issue body
#   ISSUE_LABELS_JSON         JSON array of label names
#   ISSUE_EVENT_NAME          GitHub event name (issues, issue_comment, ...)
#   ISSUE_EVENT_ACTION        GitHub event action (opened, created, ...)
#   ISSUE_COMMENT_ID          Comment id for issue_comment events (optional)
#   ISSUE_ACTOR               Event actor login
#   ISSUE_ACTOR_TYPE          Event actor type (User, Bot, ...)
#   ISSUE_COMMENT_USER_TYPE   Comment author type for issue_comment events (optional)
#   ISSUE_LABEL_NAME          Label name for labeled/unlabeled events (optional)
#   GITHUB_EVENT_PATH         Path to GitHub webhook event JSON (hydrates ISSUE_* when ISSUE_NUMBER unset)
#   GITHUB_EVENT_NAME         GitHub event name for hydration (issues, issue_comment, workflow_dispatch)
#   GITHUB_REPOSITORY         Repository slug for workflow_dispatch gh api fetch
#   GITHUB_ACTOR              Actor login for workflow_dispatch hydration
#   GH_TOKEN / GITHUB_TOKEN   Token for workflow_dispatch gh api fetch when title/body/labels empty
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
#   output_error "ISSUE_NUMBER is required"
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
# hydrate_issue_env_from_event: Populate ISSUE_* from GITHUB_EVENT_PATH
#
# Globals:
#   GITHUB_EVENT_PATH
#   GITHUB_EVENT_NAME
#   ISSUE_NUMBER (set)
#   ISSUE_TITLE (set)
#   ISSUE_BODY (set)
#   ISSUE_LABELS_JSON (set)
#   ISSUE_EVENT_NAME (set)
#   ISSUE_EVENT_ACTION (set)
#   ISSUE_COMMENT_ID (set)
#   ISSUE_ACTOR (set)
#   ISSUE_ACTOR_TYPE (set)
#   ISSUE_COMMENT_USER_TYPE (set)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success; calls output_error when event file is missing or invalid
#
# Usage:
#   hydrate_issue_env_from_event
#
#######################################
function hydrate_issue_env_from_event {
    local event_path="${GITHUB_EVENT_PATH:-}"
    local event_json issue_number comment_id labels_json

    if [[ -z ${event_path} || ! -f ${event_path} ]]; then
        output_error "ISSUE_NUMBER or GITHUB_EVENT_PATH required"
    fi

    if ! event_json="$(jq -c . "${event_path}" 2> /dev/null)"; then
        output_error "invalid GITHUB_EVENT_PATH JSON: ${event_path}"
    fi

    issue_number="$(jq -r '(.issue.number // empty) | tostring' <<< "${event_json}")"
    ISSUE_NUMBER="${issue_number}"
    ISSUE_TITLE="$(jq -r '.issue.title // ""' <<< "${event_json}")"
    ISSUE_BODY="$(jq -r '.issue.body // ""' <<< "${event_json}")"
    labels_json="$(jq -c '[.issue.labels[]?.name]' <<< "${event_json}")"
    ISSUE_LABELS_JSON="${labels_json}"
    ISSUE_EVENT_NAME="${GITHUB_EVENT_NAME:-}"
    ISSUE_EVENT_ACTION="$(jq -r '.action // ""' <<< "${event_json}")"
    comment_id="$(jq -r 'if .comment.id then (.comment.id | tostring) else "" end' <<< "${event_json}")"
    ISSUE_COMMENT_ID="${comment_id}"
    ISSUE_ACTOR="$(jq -r '.sender.login // ""' <<< "${event_json}")"
    ISSUE_ACTOR_TYPE="$(jq -r '.sender.type // ""' <<< "${event_json}")"
    ISSUE_COMMENT_USER_TYPE="$(jq -r '.comment.user.type // ""' <<< "${event_json}")"
    ISSUE_LABEL_NAME="$(jq -r '.label.name // ""' <<< "${event_json}")"
}

#######################################
# hydrate_issue_from_api_if_needed: Fill missing issue fields for workflow_dispatch
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_TITLE (may be set)
#   ISSUE_BODY (may be set)
#   ISSUE_LABELS_JSON (may be set)
#   ISSUE_EVENT_NAME (may be set)
#   ISSUE_EVENT_ACTION (may be set)
#   ISSUE_ACTOR (may be set)
#   ISSUE_ACTOR_TYPE (may be set)
#   GITHUB_REPOSITORY
#   GITHUB_ACTOR
#   GH_TOKEN
#   GITHUB_TOKEN
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success or when fetch is unavailable
#
# Usage:
#   hydrate_issue_from_api_if_needed
#
#######################################
function hydrate_issue_from_api_if_needed {
    local token repo issue_json

    if [[ -n ${ISSUE_TITLE:-} && -n ${ISSUE_BODY:-} && ${ISSUE_LABELS_JSON:-} != "[]" && -n ${ISSUE_LABELS_JSON:-} ]]; then
        return 0
    fi

    token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    repo="${GITHUB_REPOSITORY:-}"
    if [[ -z ${token} || -z ${repo} ]] || ! command -v gh &> /dev/null; then
        return 0
    fi

    issue_json="$(GH_TOKEN="${token}" gh api "repos/${repo}/issues/${ISSUE_NUMBER}")" || {
        output_error "failed to fetch issue #${ISSUE_NUMBER} from GitHub API"
    }

    if [[ -z ${ISSUE_TITLE:-} ]]; then
        ISSUE_TITLE="$(jq -r '.title // ""' <<< "${issue_json}")"
    fi
    if [[ -z ${ISSUE_BODY:-} ]]; then
        ISSUE_BODY="$(jq -r '.body // ""' <<< "${issue_json}")"
    fi
    if [[ -z ${ISSUE_LABELS_JSON:-} || ${ISSUE_LABELS_JSON} == "[]" ]]; then
        ISSUE_LABELS_JSON="$(jq -c '[.labels[].name]' <<< "${issue_json}")"
    fi

    ISSUE_EVENT_NAME="${ISSUE_EVENT_NAME:-workflow_dispatch}"
    ISSUE_EVENT_ACTION="${ISSUE_EVENT_ACTION:-workflow_dispatch}"
    ISSUE_ACTOR="${ISSUE_ACTOR:-${GITHUB_ACTOR:-}}"
    ISSUE_ACTOR_TYPE="${ISSUE_ACTOR_TYPE:-User}"
}

#######################################
# validate_issue_number: Fail when ISSUE_NUMBER is not a positive integer
#
# Globals:
#   None
#
# Arguments:
#   $1 - Issue number string
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on invalid input)
#
# Usage:
#   validate_issue_number "${ISSUE_NUMBER}"
#
#######################################
function validate_issue_number {
    local issue_number="$1"

    if [[ ! ${issue_number} =~ ^[1-9][0-9]*$ ]]; then
        output_error "ISSUE_NUMBER must be a positive integer"
    fi
}

#######################################
# should_skip_issue: Return whether detect should skip agent execute (E6/E7)
#
# Globals:
#   ISSUE_ACTOR_TYPE
#   ISSUE_EVENT_NAME
#   ISSUE_COMMENT_USER_TYPE
#   ISSUE_LABELS_JSON
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
#   if should_skip_issue; then skip="true"; fi
#
#######################################
function should_skip_issue {
    if [[ ${ISSUE_ACTOR_TYPE} == "Bot" ]]; then
        return 0
    fi

    if [[ ${ISSUE_EVENT_NAME} == "issue_comment" && ${ISSUE_COMMENT_USER_TYPE:-} == "Bot" ]]; then
        return 0
    fi

    if jq -e --arg name "triage:failed" 'contains([$name])' <<< "${ISSUE_LABELS_JSON}" > /dev/null 2>&1; then
        return 0
    fi

    if [[ ${ISSUE_EVENT_NAME} == "workflow_dispatch" ]]; then
        return 1
    fi

    if [[ ${ISSUE_EVENT_NAME} == "issue_comment" ]]; then
        if jq -e --arg name "triage:needs-info" 'contains([$name])' <<< "${ISSUE_LABELS_JSON}" > /dev/null 2>&1; then
            return 1
        fi
        return 0
    fi

    if jq -e 'contains(["needs-triage"]) or contains(["triage:needs-info"])' <<< "${ISSUE_LABELS_JSON}" > /dev/null 2>&1; then
        return 1
    fi

    if jq -e --arg name "triage:ready" 'contains([$name])' <<< "${ISSUE_LABELS_JSON}" > /dev/null 2>&1; then
        return 0
    fi

    return 1
}

#######################################
# should_request_dispatch: Return whether to emit dispatch flags (Y3 intake)
#
# Globals:
#   ISSUE_ACTOR_TYPE
#   ISSUE_EVENT_NAME
#   ISSUE_EVENT_ACTION
#   ISSUE_COMMENT_USER_TYPE
#   ISSUE_LABELS_JSON
#   ISSUE_LABEL_NAME
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when repository_dispatch should be requested, 1 otherwise
#
# Usage:
#   if should_request_dispatch; then ...
#
#######################################
function should_request_dispatch {
    if [[ ${ISSUE_ACTOR_TYPE} == "Bot" ]]; then
        return 1
    fi

    if [[ ${ISSUE_EVENT_NAME} == "issue_comment" && ${ISSUE_COMMENT_USER_TYPE:-} == "Bot" ]]; then
        return 1
    fi

    if jq -e --arg name "triage:failed" 'contains([$name])' <<< "${ISSUE_LABELS_JSON}" > /dev/null 2>&1; then
        return 1
    fi

    if ! jq -e 'contains(["triage:ready"]) and contains(["autofix"]) and (contains(["triage:failed"]) | not)' <<< "${ISSUE_LABELS_JSON}" > /dev/null 2>&1; then
        return 1
    fi

    # Autofix workflow already handles labeled(autofix) directly — avoid double intake.
    if [[ ${ISSUE_EVENT_NAME} == "issues" && ${ISSUE_EVENT_ACTION} == "labeled" && ${ISSUE_LABEL_NAME:-} == "autofix" ]]; then
        return 1
    fi

    # Hand off when triage:ready is applied while autofix is already present.
    if [[ ${ISSUE_EVENT_NAME} == "issues" && ${ISSUE_EVENT_ACTION} == "labeled" && ${ISSUE_LABEL_NAME:-} == "triage:ready" ]]; then
        return 0
    fi

    return 1
}

#######################################
# resolve_comment_id_json: Resolve comment_id field for result JSON
#
# Globals:
#   ISSUE_COMMENT_ID
#
# Arguments:
#   None
#
# Outputs:
#   JSON number or null literal on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   comment_id="$(resolve_comment_id_json)"
#
#######################################
function resolve_comment_id_json {
    if [[ -n ${ISSUE_COMMENT_ID:-} ]]; then
        json_number "${ISSUE_COMMENT_ID}"
        return 0
    fi

    printf '%s' "null"
}

#######################################
# build_verifier_context: Build verifier_context string for handoff
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_TITLE
#
# Arguments:
#   None
#
# Outputs:
#   Verifier context string on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   verifier_context="$(build_verifier_context)"
#
#######################################
function build_verifier_context {
    printf 'Issue #%s: %s' "${ISSUE_NUMBER}" "${ISSUE_TITLE}"
}

#######################################
# build_result_json: Build the result object JSON
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_TITLE
#   ISSUE_BODY
#   ISSUE_LABELS_JSON
#   ISSUE_EVENT_NAME
#   ISSUE_EVENT_ACTION
#   ISSUE_ACTOR
#   ISSUE_ACTOR_TYPE
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
    local comment_id payload
    comment_id="$(resolve_comment_id_json)"

    if should_request_dispatch; then
        payload="$(jq -nc --arg n "${ISSUE_NUMBER}" '{issue_number: $n}')"
        json_object \
            handoff_key "entity:issue:${ISSUE_NUMBER}" \
            issue_number "$(json_number "${ISSUE_NUMBER}")" \
            title "${ISSUE_TITLE}" \
            body "${ISSUE_BODY}" \
            labels "${ISSUE_LABELS_JSON}" \
            event_name "${ISSUE_EVENT_NAME}" \
            event_action "${ISSUE_EVENT_ACTION}" \
            comment_id "${comment_id}" \
            actor "${ISSUE_ACTOR}" \
            actor_type "${ISSUE_ACTOR_TYPE}" \
            dispatch_requested "true" \
            dispatch_event_type "loop-issue-autofix" \
            dispatch_client_payload "${payload}"
    else
        json_object \
            handoff_key "entity:issue:${ISSUE_NUMBER}" \
            issue_number "$(json_number "${ISSUE_NUMBER}")" \
            title "${ISSUE_TITLE}" \
            body "${ISSUE_BODY}" \
            labels "${ISSUE_LABELS_JSON}" \
            event_name "${ISSUE_EVENT_NAME}" \
            event_action "${ISSUE_EVENT_ACTION}" \
            comment_id "${comment_id}" \
            actor "${ISSUE_ACTOR}" \
            actor_type "${ISSUE_ACTOR_TYPE}"
    fi
}

#######################################
# output_json: Print structured detect JSON result
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_TITLE
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
    local result_json verifier_context

    result_json="$(build_result_json)"
    verifier_context="$(build_verifier_context)"

    json_object \
        status "ok" \
        skip "${skip}" \
        result "${result_json}" \
        verifier_context "${verifier_context}"
}

#######################################
# main: Validate inputs, evaluate skip policy, emit detect JSON
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_TITLE
#   ISSUE_BODY
#   ISSUE_LABELS_JSON
#   ISSUE_EVENT_NAME
#   ISSUE_EVENT_ACTION
#   ISSUE_COMMENT_ID
#   ISSUE_ACTOR
#   ISSUE_ACTOR_TYPE
#   ISSUE_COMMENT_USER_TYPE
#   ISSUE_LABELS_JSON
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

    if [[ -n ${ISSUE_NUMBER:-} ]]; then
        if [[ ${GITHUB_EVENT_NAME:-} == "workflow_dispatch" || ${ISSUE_EVENT_NAME:-} == "workflow_dispatch" ]]; then
            hydrate_issue_from_api_if_needed
        fi
    elif [[ -n ${GITHUB_EVENT_PATH:-} && -f ${GITHUB_EVENT_PATH} ]]; then
        hydrate_issue_env_from_event
    else
        output_error "ISSUE_NUMBER or GITHUB_EVENT_PATH required"
    fi

    if [[ -z ${ISSUE_NUMBER:-} ]]; then
        output_error "ISSUE_NUMBER is required"
    fi

    validate_issue_number "${ISSUE_NUMBER}"

    ISSUE_TITLE="${ISSUE_TITLE:-}"
    ISSUE_BODY="${ISSUE_BODY:-}"
    ISSUE_LABELS_JSON="${ISSUE_LABELS_JSON:-[]}"
    ISSUE_EVENT_NAME="${ISSUE_EVENT_NAME:-${GITHUB_EVENT_NAME:-}}"
    ISSUE_EVENT_ACTION="${ISSUE_EVENT_ACTION:-}"
    ISSUE_ACTOR="${ISSUE_ACTOR:-}"
    ISSUE_ACTOR_TYPE="${ISSUE_ACTOR_TYPE:-}"
    ISSUE_LABEL_NAME="${ISSUE_LABEL_NAME:-}"

    if should_skip_issue; then
        skip="true"
    fi

    output_json "${skip}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
