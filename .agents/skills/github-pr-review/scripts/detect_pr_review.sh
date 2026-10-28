#!/bin/bash
#######################################
# Description: Detect PR facts for github-pr-review (first review on open)
#
# Usage: ./detect_pr_review.sh
#
# Output:
# - JSON object with status, skip, message, result, verifier_context
#
# Design Rules:
# - Emit mechanical facts only (no semantic findings)
# - result.entity.kind is always pr (the loop entity platform requires it when skip=false)
# - Hydrate unset PR_* from GITHUB_EVENT_PATH (pull_request / pull_request_target / workflow_dispatch)
# - Skip bot-authored, draft, fork, and excluded-label PRs
# - Skip when a review carrying the github-pr-review marker already exists, unless force is set
# - workflow_dispatch fills missing PR facts via gh pr view
# - Output structured JSON via shared lib/json.sh
# - Exit 0 on success; fatal errors emit status=error JSON and exit 1
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq
# - gh (when PR facts, changed files, or reviews are fetched from the GitHub API)
#
# Fail closed: when a required fact (workflow_dispatch PR facts, reviews, changed files)
# cannot be obtained and no seed env var supplies it, emit the error envelope.
#
# Optional environment:
#   PR_NUMBER             Pull request number (required unless GITHUB_EVENT_PATH hydrates it)
#   PR_FORCE              true|false; true ignores the existing-review marker (default: false)
#   PR_AUTHOR_TYPE        PR author type (User, Bot, ...)
#   PR_DRAFT              true|false
#   PR_IS_FORK            true|false (head repository differs from base repository)
#   PR_LABELS_JSON        JSON array of label names
#   PR_BASE_SHA           Base commit SHA
#   PR_HEAD_SHA           Head commit SHA
#   PR_CHANGED_FILES_JSON JSON array of changed file paths (test seam; fetched via gh pr view when unset)
#   PR_REVIEWS_JSON       JSON array of reviews with body and user.type (test seam; fetched via gh api when unset)
#   PR_EXCLUDE_LABELS     Comma-separated label names that skip the review
#   GITHUB_EVENT_PATH     Path to GitHub event JSON (hydrates unset PR_*)
#   GITHUB_EVENT_NAME     GitHub event name
#   GITHUB_REPOSITORY     Repository slug for gh calls
#   GH_TOKEN / GITHUB_TOKEN Token for gh calls
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

readonly REVIEW_MARKER='<!-- github-pr-review:v1 -->'

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
# hydrate_pr_env_from_event: Populate unset PR_* from GITHUB_EVENT_PATH
#
# Globals:
#   GITHUB_EVENT_PATH
#   GITHUB_EVENT_NAME
#   PR_* (set when unset)
#   PR_EVENT_NAME (set)
#   PR_EVENT_ACTION (set)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success; calls output_error when the event file is invalid JSON
#
# Usage:
#   hydrate_pr_env_from_event
#
#######################################
function hydrate_pr_env_from_event {
    local event_path="${GITHUB_EVENT_PATH:-}"
    local event_json value

    if [[ -z ${event_path} || ! -f ${event_path} ]]; then
        return 0
    fi

    if ! event_json="$(jq -c . "${event_path}" 2> /dev/null)"; then
        output_error "invalid GITHUB_EVENT_PATH JSON: ${event_path}"
    fi

    value="$(jq -r '
        if .pull_request.number then (.pull_request.number | tostring)
        elif .inputs.pr_number then (.inputs.pr_number | tostring)
        else empty end
    ' <<< "${event_json}")"
    if [[ -z ${PR_NUMBER:-} && -n ${value} ]]; then
        PR_NUMBER="${value}"
    fi

    value="$(jq -r '.inputs.force // empty | tostring' <<< "${event_json}")"
    if [[ -z ${PR_FORCE:-} && -n ${value} ]]; then
        PR_FORCE="${value}"
    fi

    if jq -e '.pull_request' <<< "${event_json}" > /dev/null 2>&1; then
        if [[ -z ${PR_AUTHOR_TYPE:-} ]]; then
            PR_AUTHOR_TYPE="$(jq -r '.pull_request.user.type // ""' <<< "${event_json}")"
        fi
        if [[ -z ${PR_DRAFT:-} ]]; then
            PR_DRAFT="$(jq -r '.pull_request.draft // false | tostring' <<< "${event_json}")"
        fi
        if [[ -z ${PR_IS_FORK:-} ]]; then
            PR_IS_FORK="$(jq -r '(.pull_request.head.repo.full_name // "") as $h | (.repository.full_name // "") as $r | (($h != "" and $r != "" and $h == $r) | not) | tostring' <<< "${event_json}")"
        fi
        if [[ -z ${PR_LABELS_JSON:-} ]]; then
            PR_LABELS_JSON="$(jq -c '[.pull_request.labels[]?.name]' <<< "${event_json}")"
        fi
        if [[ -z ${PR_BASE_SHA:-} ]]; then
            PR_BASE_SHA="$(jq -r '.pull_request.base.sha // ""' <<< "${event_json}")"
        fi
        if [[ -z ${PR_HEAD_SHA:-} ]]; then
            PR_HEAD_SHA="$(jq -r '.pull_request.head.sha // ""' <<< "${event_json}")"
        fi
    fi

    PR_EVENT_ACTION="$(jq -r '.action // ""' <<< "${event_json}")"
    PR_EVENT_NAME="${GITHUB_EVENT_NAME:-}"
    if [[ -z ${PR_EVENT_NAME} ]] && jq -e '.inputs.pr_number' <<< "${event_json}" > /dev/null 2>&1; then
        PR_EVENT_NAME="workflow_dispatch"
    fi
    if [[ ${PR_EVENT_NAME} == "workflow_dispatch" && -z ${PR_EVENT_ACTION} ]]; then
        PR_EVENT_ACTION="workflow_dispatch"
    fi
}

#######################################
# gh_available: Return whether gh API calls can be made
#
# Globals:
#   GH_TOKEN
#   GITHUB_TOKEN
#   GITHUB_REPOSITORY
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when gh, a token, and a repository are available
#
# Usage:
#   if gh_available; then ...
#
#######################################
function gh_available {
    [[ -n ${GH_TOKEN:-${GITHUB_TOKEN:-}} && -n ${GITHUB_REPOSITORY:-} ]] && command -v gh &> /dev/null
}

#######################################
# hydrate_pr_from_api_if_needed: Fill missing PR facts for workflow_dispatch via gh pr view
#
# Globals:
#   PR_NUMBER
#   PR_EVENT_NAME
#   PR_* (set when unset)
#   PR_CHANGED_FILES_JSON (set when fetched)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success or when the fetch is unnecessary/unavailable
#
# Usage:
#   hydrate_pr_from_api_if_needed
#
#######################################
function hydrate_pr_from_api_if_needed {
    local pr_json

    if [[ ${PR_EVENT_NAME:-} != "workflow_dispatch" ]]; then
        return 0
    fi
    if [[ -n ${PR_AUTHOR_TYPE:-} && -n ${PR_DRAFT:-} && -n ${PR_IS_FORK:-} && -n ${PR_LABELS_JSON:-} && -n ${PR_BASE_SHA:-} && -n ${PR_HEAD_SHA:-} ]]; then
        return 0
    fi
    if ! gh_available; then
        output_error "cannot determine PR facts for #${PR_NUMBER}: gh, token, or GITHUB_REPOSITORY unavailable and PR_* not seeded"
    fi

    pr_json="$(GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}" gh pr view "${PR_NUMBER}" --repo "${GITHUB_REPOSITORY}" \
        --json author,isDraft,isCrossRepository,labels,baseRefOid,headRefOid)" || {
        output_error "failed to fetch PR #${PR_NUMBER} from GitHub API"
    }

    if [[ -z ${PR_AUTHOR_TYPE:-} ]]; then
        PR_AUTHOR_TYPE="$(jq -r 'if .author.is_bot then "Bot" else "User" end' <<< "${pr_json}")"
    fi
    if [[ -z ${PR_DRAFT:-} ]]; then
        PR_DRAFT="$(jq -r '.isDraft // false | tostring' <<< "${pr_json}")"
    fi
    if [[ -z ${PR_IS_FORK:-} ]]; then
        PR_IS_FORK="$(jq -r '.isCrossRepository // false | tostring' <<< "${pr_json}")"
    fi
    if [[ -z ${PR_LABELS_JSON:-} ]]; then
        PR_LABELS_JSON="$(jq -c '[.labels[]?.name]' <<< "${pr_json}")"
    fi
    if [[ -z ${PR_BASE_SHA:-} ]]; then
        PR_BASE_SHA="$(jq -r '.baseRefOid // ""' <<< "${pr_json}")"
    fi
    if [[ -z ${PR_HEAD_SHA:-} ]]; then
        PR_HEAD_SHA="$(jq -r '.headRefOid // ""' <<< "${pr_json}")"
    fi
}

#######################################
# resolve_changed_files: Ensure PR_CHANGED_FILES_JSON is set
#
# Globals:
#   PR_NUMBER
#   PR_CHANGED_FILES_JSON (set)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success; calls output_error when the gh fetch fails
#
# Usage:
#   resolve_changed_files
#
#######################################
function resolve_changed_files {
    if [[ -n ${PR_CHANGED_FILES_JSON:-} ]]; then
        return 0
    fi
    if ! gh_available; then
        output_error "cannot determine changed files for PR #${PR_NUMBER}: gh, token, or GITHUB_REPOSITORY unavailable"
    fi

    PR_CHANGED_FILES_JSON="$(GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}" gh api --paginate "repos/${GITHUB_REPOSITORY}/pulls/${PR_NUMBER}/files" \
        --jq '.[].filename' | jq -R -s -c 'split("\n") | map(select(length > 0))')" || {
        output_error "failed to fetch changed files for PR #${PR_NUMBER}"
    }
}

#######################################
# has_marker_review: Return whether a Bot-authored review with the marker exists
#
# Globals:
#   PR_NUMBER
#   PR_REVIEWS_JSON (set when fetched)
#   REVIEW_MARKER
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when a Bot-authored marker review exists, 1 otherwise; calls output_error when the gh fetch fails
#
# Usage:
#   if has_marker_review; then ...
#
#######################################
function has_marker_review {
    if [[ -z ${PR_REVIEWS_JSON:-} ]]; then
        if ! gh_available; then
            output_error "cannot determine existing reviews for PR #${PR_NUMBER}: gh, token, or GITHUB_REPOSITORY unavailable"
        fi
        PR_REVIEWS_JSON="$(GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}" gh api --paginate "repos/${GITHUB_REPOSITORY}/pulls/${PR_NUMBER}/reviews" | jq -cs 'add // []')" || {
            output_error "failed to fetch reviews for PR #${PR_NUMBER}"
        }
    fi

    # Only a Bot-authored review counts: anyone can paste the marker into a
    # human review to suppress the review for this PR.
    jq -e --arg marker "${REVIEW_MARKER}" \
        'any(.[]?; (.user.type? // "") == "Bot" and ((.body // "") | contains($marker)))' \
        <<< "${PR_REVIEWS_JSON}" > /dev/null 2>&1
}

#######################################
# has_excluded_label: Return whether a PR label is in PR_EXCLUDE_LABELS
#
# Globals:
#   PR_LABELS_JSON
#   PR_EXCLUDE_LABELS
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when an excluded label is present, 1 otherwise
#
# Usage:
#   if has_excluded_label; then ...
#
#######################################
function has_excluded_label {
    local -a excluded=()
    local name

    IFS=',' read -r -a excluded <<< "${PR_EXCLUDE_LABELS:-}"
    for name in "${excluded[@]}"; do
        name="${name#"${name%%[![:space:]]*}"}"
        name="${name%"${name##*[![:space:]]}"}"
        if [[ -z ${name} ]]; then
            continue
        fi
        if jq -e --arg name "${name}" 'index($name) != null' <<< "${PR_LABELS_JSON}" > /dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

#######################################
# evaluate_skip: Set SKIP_FLAG and SKIP_MESSAGE from the skip policy
#
# Globals:
#   PR_AUTHOR_TYPE
#   PR_DRAFT
#   PR_IS_FORK
#   PR_FORCE
#   SKIP_FLAG (set)
#   SKIP_MESSAGE (set)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   evaluate_skip
#
#######################################
function evaluate_skip {
    SKIP_FLAG="true"
    if [[ ${PR_AUTHOR_TYPE} == "Bot" ]]; then
        SKIP_MESSAGE="PR author is a bot"
    elif [[ ${PR_DRAFT} == "true" ]]; then
        SKIP_MESSAGE="PR is a draft"
    elif [[ ${PR_IS_FORK} == "true" ]]; then
        SKIP_MESSAGE="PR is from a fork"
    elif has_excluded_label; then
        SKIP_MESSAGE="PR has an excluded label"
    elif [[ ${PR_FORCE} != "true" ]] && has_marker_review; then
        SKIP_MESSAGE="already reviewed (marker review exists)"
    else
        SKIP_FLAG="false"
        SKIP_MESSAGE=""
    fi
}

#######################################
# build_result_json: Build the result object JSON
#
# Globals:
#   PR_NUMBER
#   PR_BASE_SHA
#   PR_HEAD_SHA
#   PR_CHANGED_FILES_JSON
#   PR_EVENT_NAME
#   PR_EVENT_ACTION
#   PR_FORCE
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
    json_object \
        handoff_key "entity:pr:${PR_NUMBER}" \
        entity '{"kind":"pr"}' \
        pr_number "$(json_number "${PR_NUMBER}")" \
        base_sha "${PR_BASE_SHA}" \
        head_sha "${PR_HEAD_SHA}" \
        changed_files "${PR_CHANGED_FILES_JSON}" \
        report_path ".loop-review/pr-${PR_NUMBER}.json" \
        event_name "${PR_EVENT_NAME}" \
        event_action "${PR_EVENT_ACTION}" \
        force "${PR_FORCE}"
}

#######################################
# main: Validate inputs, evaluate skip policy, emit detect JSON
#
# Globals:
#   PR_*
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
    local result_json verifier_context file_count

    ensure_dependencies bash jq

    PR_EVENT_NAME="${GITHUB_EVENT_NAME:-}"
    PR_EVENT_ACTION=""
    hydrate_pr_env_from_event

    if [[ -z ${PR_NUMBER:-} ]]; then
        output_error "PR_NUMBER or GITHUB_EVENT_PATH required"
    fi
    if [[ ! ${PR_NUMBER} =~ ^[1-9][0-9]*$ ]]; then
        output_error "PR_NUMBER must be a positive integer"
    fi

    hydrate_pr_from_api_if_needed

    PR_FORCE="${PR_FORCE:-false}"
    if [[ ${PR_FORCE} != "true" ]]; then
        PR_FORCE="false"
    fi
    PR_AUTHOR_TYPE="${PR_AUTHOR_TYPE:-User}"
    PR_DRAFT="${PR_DRAFT:-false}"
    PR_IS_FORK="${PR_IS_FORK:-false}"
    PR_LABELS_JSON="${PR_LABELS_JSON:-[]}"
    PR_BASE_SHA="${PR_BASE_SHA:-}"
    PR_HEAD_SHA="${PR_HEAD_SHA:-}"

    evaluate_skip
    if [[ ${SKIP_FLAG} == "true" ]]; then
        PR_CHANGED_FILES_JSON="${PR_CHANGED_FILES_JSON:-[]}"
    else
        resolve_changed_files
    fi

    file_count="$(jq -r 'length' <<< "${PR_CHANGED_FILES_JSON}")"
    result_json="$(build_result_json)"
    verifier_context="PR #${PR_NUMBER} base ${PR_BASE_SHA} head ${PR_HEAD_SHA} files: ${file_count}"

    json_object \
        status "ok" \
        skip "${SKIP_FLAG}" \
        message "${SKIP_MESSAGE}" \
        result "${result_json}" \
        verifier_context "${verifier_context}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
