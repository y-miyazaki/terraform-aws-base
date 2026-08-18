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
# - On comment webhooks, gather open human @mention comments into result.comments
# - Exclude comments that already have an eyes reaction (claimed by a prior run)
# - Skip when gather runs and result.comments is empty (queued follow-up with nothing left)
# - repository_dispatch / workflow_dispatch bypass mention (explicit trusted intake)
# - Output structured JSON via shared lib/json.sh
# - Exit 0 on success; fatal errors emit status=error JSON and exit 1
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq
# - gh (when gathering open comments via GitHub API)
#
# Optional environment:
#   PR_NUMBER         Pull request number (required unless GITHUB_EVENT_PATH hydrates it)
#   PR_MENTION        Mention token required in comment body (default: @loop)
#   PR_COMMENT_BODY   Comment body to match against PR_MENTION
#   PR_COMMENT_ID     Review/issue comment id (hydrated from event when unset)
#   PR_COMMENT_PATH   Inline review file path (empty for issue_comment)
#   PR_COMMENT_LINE   Inline review line (line or original_line; empty for issue_comment)
#   PR_COMMENT_SIDE   Inline review side (LEFT/RIGHT; empty for issue_comment)
#   PR_COMMENT_DIFF_HUNK Inline review diff hunk (empty for issue_comment)
#   PR_COMMENT_IN_REPLY_TO_ID Parent review comment id when present
#   PR_COMMENT_START_LINE Inline review start_line or original_start_line
#   PR_COMMENT_SUBJECT_TYPE Inline subject_type (line or file)
#   PR_COMMENTS_JSON  Prebuilt comments array JSON (skips API gather when set)
#   PR_ACTOR          Comment or event actor login
#   PR_ACTOR_TYPE     Comment or event actor type (User, Bot, ...)
#   PR_ACTOR_ASSOCIATION Comment or sender author_association when present
#   GITHUB_EVENT_PATH Path to GitHub webhook event JSON (hydrates PR_* when PR_NUMBER unset)
#   GITHUB_EVENT_NAME GitHub event name (mention gate applies only to comment webhooks)
#   GITHUB_REPOSITORY owner/name (required for API gather)
#   GH_TOKEN / GITHUB_TOKEN Token for API gather when prerequisites are present
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
# association_value_allowed: Return whether an association string is trusted
#
# Globals:
#   None
#
# Arguments:
#   $1 - author_association value
#
# Outputs:
#   None
#
# Returns:
#   0 when association is allowed or empty, 1 otherwise
#
# Usage:
#   if association_value_allowed "${assoc}"; then ...
#
#######################################
function association_value_allowed {
    local assoc="${1:-}"

    if [[ -z ${assoc} ]]; then
        return 0
    fi

    case "${assoc}" in
        MEMBER | OWNER | COLLABORATOR) return 0 ;;
        *) return 1 ;;
    esac
}

#######################################
# build_comment_object: Build one comments[] entry JSON object
#
# Globals:
#   None
#
# Arguments:
#   $1 - comment_id (may be empty)
#   $2 - body
#   $3 - path
#   $4 - line (may be empty)
#   $5 - side
#   $6 - diff_hunk
#   $7 - in_reply_to_id (may be empty)
#   $8 - source (issue_comment|pull_request_review_comment|dispatch)
#   $9 - actor
#   $10 - start_line (may be empty)
#   $11 - subject_type (line or file; may be empty)
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   build_comment_object "1" "@loop fix" "a.go" "10" "RIGHT" "@@" "" "pull_request_review_comment" "me" "8" "line"
#
#######################################
function build_comment_object {
    local comment_id="${1:-}"
    local body="${2:-}"
    local path="${3:-}"
    local line="${4:-}"
    local side="${5:-}"
    local diff_hunk="${6:-}"
    local in_reply_to_id="${7:-}"
    local source="${8:-}"
    local actor="${9:-}"
    local start_line="${10:-}"
    local subject_type="${11:-}"
    local comment_id_json="" line_json="" in_reply_to_json="" start_line_json=""

    if [[ -n ${comment_id} ]]; then
        comment_id_json="$(json_number "${comment_id}")"
    fi
    if [[ -n ${line} ]]; then
        line_json="$(json_number "${line}")"
    fi
    if [[ -n ${in_reply_to_id} ]]; then
        in_reply_to_json="$(json_number "${in_reply_to_id}")"
    fi
    if [[ -n ${start_line} ]]; then
        start_line_json="$(json_number "${start_line}")"
    fi

    json_object \
        comment_id "${comment_id_json}" \
        body "${body}" \
        path "${path}" \
        line "${line_json}" \
        start_line "${start_line_json}" \
        side "${side}" \
        diff_hunk "${diff_hunk}" \
        in_reply_to_id "${in_reply_to_json}" \
        source "${source}" \
        actor "${actor}" \
        subject_type "${subject_type}"
}

#######################################
# build_result_json: Build the result object JSON
#
# Globals:
#   PR_NUMBER
#   PR_MENTION
#   PR_COMMENT_BODY
#   PR_COMMENT_ID
#   PR_COMMENT_PATH
#   PR_COMMENT_LINE
#   PR_COMMENT_SIDE
#   PR_COMMENT_DIFF_HUNK
#   PR_COMMENT_IN_REPLY_TO_ID
#   PR_COMMENTS_JSON
#   PR_ACTOR
#   GITHUB_EVENT_NAME
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
    local comment_id="${PR_COMMENT_ID:-}"
    local comment_line="${PR_COMMENT_LINE:-}"
    local in_reply_to_id="${PR_COMMENT_IN_REPLY_TO_ID:-}"
    local start_line="${PR_COMMENT_START_LINE:-}"
    local comments_json="${PR_COMMENTS_JSON:-[]}"
    local comment_id_json=""
    local comment_line_json=""
    local in_reply_to_json=""
    local start_line_json=""

    if [[ -n ${comment_id} ]]; then
        comment_id_json="$(json_number "${comment_id}")"
    fi
    if [[ -n ${comment_line} ]]; then
        comment_line_json="$(json_number "${comment_line}")"
    fi
    if [[ -n ${in_reply_to_id} ]]; then
        in_reply_to_json="$(json_number "${in_reply_to_id}")"
    fi
    if [[ -n ${start_line} ]]; then
        start_line_json="$(json_number "${start_line}")"
    fi

    json_object \
        pr_number "${PR_NUMBER}" \
        mention "${mention}" \
        comment_body "${body}" \
        comment_id "${comment_id_json}" \
        path "${PR_COMMENT_PATH:-}" \
        line "${comment_line_json}" \
        start_line "${start_line_json}" \
        side "${PR_COMMENT_SIDE:-}" \
        diff_hunk "${PR_COMMENT_DIFF_HUNK:-}" \
        in_reply_to_id "${in_reply_to_json}" \
        comments "${comments_json}" \
        actor "${PR_ACTOR:-}" \
        event_name "${GITHUB_EVENT_NAME:-}" \
        subject_type "${PR_COMMENT_SUBJECT_TYPE:-}"
}

#######################################
# build_skip_message: Resolve skip reason message for output JSON
#
# Globals:
#   PR_NUMBER
#   PR_ACTOR_TYPE
#   PR_COMMENT_BODY
#   PR_MENTION
#   PR_SKIP_REASON
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

    if [[ -n ${PR_SKIP_REASON:-} ]]; then
        printf '%s' "${PR_SKIP_REASON}"
        return 0
    fi

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
# build_trigger_comments_array: Build comments[] from the triggering comment fields
#
# Globals:
#   PR_COMMENT_BODY
#   PR_COMMENT_ID
#   PR_COMMENT_PATH
#   PR_COMMENT_LINE
#   PR_COMMENT_SIDE
#   PR_COMMENT_DIFF_HUNK
#   PR_COMMENT_IN_REPLY_TO_ID
#   PR_ACTOR
#   GITHUB_EVENT_NAME
#
# Arguments:
#   None
#
# Outputs:
#   JSON array to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   PR_COMMENTS_JSON="$(build_trigger_comments_array)"
#
#######################################
function build_trigger_comments_array {
    local source="${GITHUB_EVENT_NAME:-dispatch}"
    local obj

    case "${source}" in
        issue_comment | pull_request_review_comment) ;;
        *) source="dispatch" ;;
    esac

    obj="$(build_comment_object \
        "${PR_COMMENT_ID:-}" \
        "${PR_COMMENT_BODY:-}" \
        "${PR_COMMENT_PATH:-}" \
        "${PR_COMMENT_LINE:-}" \
        "${PR_COMMENT_SIDE:-}" \
        "${PR_COMMENT_DIFF_HUNK:-}" \
        "${PR_COMMENT_IN_REPLY_TO_ID:-}" \
        "${source}" \
        "${PR_ACTOR:-}" \
        "${PR_COMMENT_START_LINE:-}" \
        "${PR_COMMENT_SUBJECT_TYPE:-}")"
    json_array "${obj}"
}

#######################################
# build_verifier_context_markdown: Build verifier_context for batched comments
#
# Globals:
#   PR_COMMENTS_JSON
#   PR_NUMBER
#
# Arguments:
#   None
#
# Outputs:
#   Markdown on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   verifier_context="$(build_verifier_context_markdown)"
#
#######################################
function build_verifier_context_markdown {
    local comments_json="${PR_COMMENTS_JSON:-[]}"

    jq -r --arg pr "${PR_NUMBER:-}" '
        "## PR Revise Comments\n"
        + "- pr_number: " + $pr + "\n"
        + "- count: " + ((length) | tostring) + "\n"
        + (
            if length == 0 then ""
            else
                (map(
                    "- comment_id=" + ((.comment_id // "") | tostring)
                    + " source=" + (.source // "")
                    + (
                        if ((.path // "") | length) > 0 then
                            " path=`" + .path + "`"
                            + (
                                if (.line | type) == "number" then ":" + (.line | tostring)
                                else ""
                                end
                            )
                        else ""
                        end
                    )
                    + " — " + ((.body // "") | gsub("\n"; " ") | .[0:160])
                    + "\n"
                ) | join(""))
            end
        )
    ' <<< "${comments_json}"
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
# filter_api_comments_to_objects: Convert API comment JSON arrays into comments[]
#
# Globals:
#   PR_MENTION
#
# Arguments:
#   $1 - Issue comments JSON array
#   $2 - Review comments JSON array
#
# Outputs:
#   JSON array to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   filter_api_comments_to_objects "${issue_json}" "${review_json}"
#
#######################################
function filter_api_comments_to_objects {
    local issue_json="$1"
    local review_json="$2"
    local mention="${PR_MENTION:-@loop}"
    local -a objects=()
    local item body assoc actor_type comment_id path line start_line side diff_hunk in_reply_to actor eyes obj subject_type

    while IFS= read -r item; do
        [[ -z ${item} || ${item} == "null" ]] && continue
        body="$(jq -r '.body // empty' <<< "${item}")"
        actor_type="$(jq -r '.user.type // empty' <<< "${item}")"
        assoc="$(jq -r '.author_association // empty' <<< "${item}")"
        eyes="$(jq -r '.reactions.eyes // 0' <<< "${item}")"
        if [[ ${actor_type} == "Bot" ]]; then
            continue
        fi
        if ! association_value_allowed "${assoc}"; then
            continue
        fi
        if ! comment_body_contains_mention "${body}" "${mention}"; then
            continue
        fi
        if [[ ${eyes} != "0" ]]; then
            continue
        fi
        comment_id="$(jq -r 'if .id then (.id | tostring) else empty end' <<< "${item}")"
        actor="$(jq -r '.user.login // empty' <<< "${item}")"
        obj="$(build_comment_object \
            "${comment_id}" \
            "${body}" \
            "" \
            "" \
            "" \
            "" \
            "" \
            "issue_comment" \
            "${actor}" \
            "" \
            "")"
        objects+=("${obj}")
    done < <(jq -c '.[]?' <<< "${issue_json}")

    while IFS= read -r item; do
        [[ -z ${item} || ${item} == "null" ]] && continue
        body="$(jq -r '.body // empty' <<< "${item}")"
        actor_type="$(jq -r '.user.type // empty' <<< "${item}")"
        assoc="$(jq -r '.author_association // empty' <<< "${item}")"
        eyes="$(jq -r '.reactions.eyes // 0' <<< "${item}")"
        if [[ ${actor_type} == "Bot" ]]; then
            continue
        fi
        if ! association_value_allowed "${assoc}"; then
            continue
        fi
        if ! comment_body_contains_mention "${body}" "${mention}"; then
            continue
        fi
        if [[ ${eyes} != "0" ]]; then
            continue
        fi
        comment_id="$(jq -r 'if .id then (.id | tostring) else empty end' <<< "${item}")"
        path="$(jq -r '.path // empty' <<< "${item}")"
        line="$(jq -r '
            if (.line | type) == "number" then (.line | tostring)
            elif (.original_line | type) == "number" then (.original_line | tostring)
            else empty end
        ' <<< "${item}")"
        start_line="$(jq -r '
            if (.start_line | type) == "number" then (.start_line | tostring)
            elif (.original_start_line | type) == "number" then (.original_start_line | tostring)
            else empty end
        ' <<< "${item}")"
        subject_type="$(jq -r '.subject_type // empty' <<< "${item}")"
        side="$(jq -r '.side // empty' <<< "${item}")"
        diff_hunk="$(jq -r '.diff_hunk // empty' <<< "${item}")"
        in_reply_to="$(jq -r 'if (.in_reply_to_id | type) == "number" then (.in_reply_to_id | tostring) else empty end' <<< "${item}")"
        actor="$(jq -r '.user.login // empty' <<< "${item}")"
        obj="$(build_comment_object \
            "${comment_id}" \
            "${body}" \
            "${path}" \
            "${line}" \
            "${side}" \
            "${diff_hunk}" \
            "${in_reply_to}" \
            "pull_request_review_comment" \
            "${actor}" \
            "${start_line}" \
            "${subject_type}")"
        objects+=("${obj}")
    done < <(jq -c '.[]?' <<< "${review_json}")

    if [[ ${#objects[@]} -eq 0 ]]; then
        printf '%s' '[]'
        return 0
    fi

    json_array "${objects[@]}" | jq -c 'sort_by(.comment_id // 0)'
}

#######################################
# gather_open_loop_comments: Fetch and filter open @mention comments on the PR
#
# Globals:
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#   PR_NUMBER
#   PR_MENTION
#
# Arguments:
#   None
#
# Outputs:
#   JSON array to stdout
#
# Returns:
#   0 on success; calls output_error on API failure
#
# Usage:
#   comments="$(gather_open_loop_comments)"
#
#######################################
function gather_open_loop_comments {
    local token issue_json review_json

    token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    export GH_TOKEN="${token}"

    if ! issue_json="$(gh api --paginate "repos/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/comments" 2> /dev/null | jq -s 'add // []')"; then
        output_error "github-pr-revise: failed to list issue comments for PR ${PR_NUMBER}"
    fi
    if ! review_json="$(gh api --paginate "repos/${GITHUB_REPOSITORY}/pulls/${PR_NUMBER}/comments" 2> /dev/null | jq -s 'add // []')"; then
        output_error "github-pr-revise: failed to list review comments for PR ${PR_NUMBER}"
    fi

    filter_api_comments_to_objects "${issue_json}" "${review_json}"
}

#######################################
# hydrate_pr_env_from_event: Populate PR_* from GITHUB_EVENT_PATH
#
# Globals:
#   GITHUB_EVENT_PATH
#   PR_NUMBER (set)
#   PR_COMMENT_BODY (set)
#   PR_COMMENT_ID (set)
#   PR_COMMENT_PATH (set)
#   PR_COMMENT_LINE (set)
#   PR_COMMENT_SIDE (set)
#   PR_COMMENT_DIFF_HUNK (set)
#   PR_COMMENT_IN_REPLY_TO_ID (set)
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
    local pr_number comment_body comment_id comment_path comment_line comment_side comment_diff_hunk
    local comment_in_reply_to comment_start_line comment_subject_type actor_type actor actor_association

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
    comment_id="$(jq -r 'if .comment.id then (.comment.id | tostring) else empty end' "${event_path}")"
    comment_path="$(jq -r '.comment.path // empty' "${event_path}")"
    comment_line="$(jq -r '
        if (.comment.line | type) == "number" then (.comment.line | tostring)
        elif (.comment.original_line | type) == "number" then (.comment.original_line | tostring)
        else empty end
    ' "${event_path}")"
    comment_side="$(jq -r '.comment.side // empty' "${event_path}")"
    comment_diff_hunk="$(jq -r '.comment.diff_hunk // empty' "${event_path}")"
    comment_in_reply_to="$(jq -r '
        if (.comment.in_reply_to_id | type) == "number" then (.comment.in_reply_to_id | tostring)
        else empty end
    ' "${event_path}")"
    comment_start_line="$(jq -r '
        if (.comment.start_line | type) == "number" then (.comment.start_line | tostring)
        elif (.comment.original_start_line | type) == "number" then (.comment.original_start_line | tostring)
        else empty end
    ' "${event_path}")"
    comment_subject_type="$(jq -r '.comment.subject_type // empty' "${event_path}")"
    actor_type="$(jq -r '.comment.user.type // .sender.type // empty' "${event_path}")"
    actor="$(jq -r '.comment.user.login // .sender.login // empty' "${event_path}")"
    actor_association="$(jq -r '.comment.author_association // .sender.author_association // empty' "${event_path}")"

    if [[ -z ${PR_NUMBER:-} && -n ${pr_number} ]]; then
        PR_NUMBER="${pr_number}"
    fi
    if [[ -z ${PR_COMMENT_BODY:-} && -n ${comment_body} ]]; then
        PR_COMMENT_BODY="${comment_body}"
    fi
    if [[ -z ${PR_COMMENT_ID:-} && -n ${comment_id} ]]; then
        PR_COMMENT_ID="${comment_id}"
    fi
    if [[ -z ${PR_COMMENT_PATH:-} && -n ${comment_path} ]]; then
        PR_COMMENT_PATH="${comment_path}"
    fi
    if [[ -z ${PR_COMMENT_LINE:-} && -n ${comment_line} ]]; then
        PR_COMMENT_LINE="${comment_line}"
    fi
    if [[ -z ${PR_COMMENT_SIDE:-} && -n ${comment_side} ]]; then
        PR_COMMENT_SIDE="${comment_side}"
    fi
    if [[ -z ${PR_COMMENT_DIFF_HUNK:-} && -n ${comment_diff_hunk} ]]; then
        PR_COMMENT_DIFF_HUNK="${comment_diff_hunk}"
    fi
    if [[ -z ${PR_COMMENT_IN_REPLY_TO_ID:-} && -n ${comment_in_reply_to} ]]; then
        PR_COMMENT_IN_REPLY_TO_ID="${comment_in_reply_to}"
    fi
    if [[ -z ${PR_COMMENT_START_LINE:-} && -n ${comment_start_line} ]]; then
        PR_COMMENT_START_LINE="${comment_start_line}"
    fi
    if [[ -z ${PR_COMMENT_SUBJECT_TYPE:-} && -n ${comment_subject_type} ]]; then
        PR_COMMENT_SUBJECT_TYPE="${comment_subject_type}"
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
# output_json: Print structured detect JSON result
#
# Globals:
#   PR_NUMBER
#   PR_MENTION
#   PR_COMMENT_BODY
#   PR_ACTOR
#   PR_ACTOR_TYPE
#   PR_COMMENTS_JSON
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
    local message result_json verifier_context

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
            result "$(json_object pr_number "${PR_NUMBER}" mention "${PR_MENTION:-@loop}" comments "${PR_COMMENTS_JSON:-[]}")"
        return 0
    fi

    result_json="$(build_result_json)"
    verifier_context="$(build_verifier_context_markdown)"
    json_object \
        status "ok" \
        skip "false" \
        message "github-pr-revise: proceed" \
        result "${result_json}" \
        verifier_context "${verifier_context}"
}

#######################################
# resolve_comments_json: Populate PR_COMMENTS_JSON from override, API, or trigger
#
# Globals:
#   PR_COMMENTS_JSON (set)
#   PR_GATHER_ATTEMPTED (set)
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#   PR_NUMBER
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
#   resolve_comments_json
#
#######################################
function resolve_comments_json {
    PR_GATHER_ATTEMPTED="false"

    if [[ -n ${PR_COMMENTS_JSON:-} ]]; then
        if ! jq -e 'type == "array"' > /dev/null 2>&1 <<< "${PR_COMMENTS_JSON}"; then
            output_error "github-pr-revise: PR_COMMENTS_JSON must be a JSON array"
        fi
        PR_GATHER_ATTEMPTED="true"
        return 0
    fi

    if should_gather_open_comments; then
        PR_GATHER_ATTEMPTED="true"
        PR_COMMENTS_JSON="$(gather_open_loop_comments)"
        return 0
    fi

    PR_COMMENTS_JSON="$(build_trigger_comments_array)"
}

#######################################
# should_gather_open_comments: Return whether API gather should run
#
# Globals:
#   GITHUB_EVENT_NAME
#   GITHUB_REPOSITORY
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
#   0 when gather prerequisites are met on a comment webhook, 1 otherwise
#
# Usage:
#   if should_gather_open_comments; then ...
#
#######################################
function should_gather_open_comments {
    if ! mention_gate_applies; then
        return 1
    fi
    case "${GITHUB_EVENT_NAME:-}" in
        issue_comment | pull_request_review_comment) ;;
        *) return 1 ;;
    esac
    if [[ -z ${GITHUB_REPOSITORY:-} ]]; then
        return 1
    fi
    if [[ -z ${GH_TOKEN:-${GITHUB_TOKEN:-}} ]]; then
        return 1
    fi
    if ! command -v gh > /dev/null 2>&1; then
        return 1
    fi
    return 0
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
# main: Validate inputs, evaluate skip policy, emit detect JSON
#
# Globals:
#   PR_NUMBER
#   PR_MENTION
#   PR_COMMENT_BODY
#   PR_ACTOR
#   PR_ACTOR_TYPE
#   PR_COMMENTS_JSON
#   PR_GATHER_ATTEMPTED
#   PR_SKIP_REASON
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
    local comments_count

    ensure_dependencies bash jq

    hydrate_pr_env_from_event

    PR_NUMBER="${PR_NUMBER:-}"
    PR_COMMENT_BODY="${PR_COMMENT_BODY:-}"
    PR_COMMENT_ID="${PR_COMMENT_ID:-}"
    PR_COMMENT_PATH="${PR_COMMENT_PATH:-}"
    PR_COMMENT_LINE="${PR_COMMENT_LINE:-}"
    PR_COMMENT_SIDE="${PR_COMMENT_SIDE:-}"
    PR_COMMENT_DIFF_HUNK="${PR_COMMENT_DIFF_HUNK:-}"
    PR_COMMENT_IN_REPLY_TO_ID="${PR_COMMENT_IN_REPLY_TO_ID:-}"
    PR_COMMENTS_JSON="${PR_COMMENTS_JSON:-}"
    PR_ACTOR_TYPE="${PR_ACTOR_TYPE:-}"
    PR_ACTOR="${PR_ACTOR:-}"
    PR_MENTION="${PR_MENTION:-@loop}"
    PR_SKIP_REASON=""
    PR_GATHER_ATTEMPTED="false"

    if [[ -z ${PR_NUMBER} ]]; then
        output_json "true"
        return 0
    fi

    validate_pr_number "${PR_NUMBER}"

    if should_skip_pr_revise; then
        skip="true"
        output_json "${skip}"
        return 0
    fi

    resolve_comments_json

    comments_count="$(jq 'length' <<< "${PR_COMMENTS_JSON}")"
    if [[ ${PR_GATHER_ATTEMPTED} == "true" && ${comments_count} -eq 0 ]]; then
        PR_SKIP_REASON="github-pr-revise: no open @loop comments to revise"
        skip="true"
        output_json "${skip}"
        return 0
    fi

    output_json "${skip}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
