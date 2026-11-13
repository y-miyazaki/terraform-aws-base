#!/bin/bash
#######################################
# Description: Detect Issue autofix intake facts for github-issue-autofix automation
#
# Usage: ./detect_autofix.sh
#
# Output:
# - JSON object with status, skip, message, and result
#
# Design Rules:
# - Consume issue facts from environment variables
# - Hydrate ISSUE_NUMBER from GITHUB_EVENT_PATH when unset
# - Skip when an open/draft PR already closes the Issue (Fixes/Close/Resolve #N)
# - Single-Issue mode reports the Issue state as the fact result.gate.entity.state (items mode: per item
#   gate); the admission gate decides on it. Fails closed when the state cannot be read
# - Scan mode (AUTOFIX_SCAN=true): list qualifying Issues as result.items (oldest first, max 50,
#   never truncated to the platform detect_max_targets); no ISSUE_NUMBER required
# - Scan mode qualifies Issues: open, not a PR, AUTOFIX_SOURCE_LABEL present, no autofix label,
#   author user.type Bot, body contains AUTOFIX_SOURCE_MARKER
# - Scan mode excludes Issues closed by an open PR, and handled Issues (closed autofix PR whose latest
#   closedAt is not older than the latest human comment; human = non-Bot user whose author_association is OWNER, MEMBER or COLLABORATOR)
# - Scan mode skips when open autofix PRs (AUTOFIX_PR_LABEL + AUTOFIX_BRANCH_PREFIX head) reach
#   AUTOFIX_MAX_OPEN_PRS; single-Issue mode ignores that limit
# - Scan mode fails closed (status=error, exit 1) on any gh failure
# - Items mode (AUTOFIX_ITEMS=true, single-Issue mode only): a non-skip result is
#   result.items with exactly one element (key issue:<N>); skip results use result {}.
#   Ignored when AUTOFIX_SCAN=true (scan output wins). Any other value keeps the legacy output
# - PR list limits (AUTOFIX_PR_SCAN_LIMIT, default 1000) apply to the open-PR fetch in single-Issue
#   mode and to both the closed-PR and the open-PR fetch in scan mode; a list that reaches the limit may be truncated, so fail closed
# - Closed PRs are filtered client-side to head branches starting with AUTOFIX_BRANCH_PREFIX
#   before Fixes #N matching and latest closedAt; empty prefix skips that filter
# - jq -e exit status 1 means "no match"; any other non-zero status is a jq error and fails closed
# - Fail closed when PR scan prerequisites (GITHUB_REPOSITORY, token, gh) are missing
# - Output structured JSON via shared lib/json.sh
# - Exit 0 on success; fatal errors emit status=error JSON and exit 1
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq
# - gh (required to scan open PRs for closing keywords)
#
# Optional environment:
#   ISSUE_NUMBER              Issue number (required unless GITHUB_EVENT_PATH hydrates it)
#   GITHUB_EVENT_PATH         Path to GitHub webhook event JSON
#   GITHUB_REPOSITORY         Repository slug for gh pr list (owner/repo)
#   GH_TOKEN / GITHUB_TOKEN   Token for gh pr list when scanning open PRs
#   AUTOFIX_SCAN              "true" enables scan mode (list Issues as result.items)
#   AUTOFIX_SOURCE_LABEL      Scan mode (required): label an Issue must carry
#   AUTOFIX_SOURCE_MARKER     Scan mode (required): marker string the Issue body must contain
#   AUTOFIX_PR_LABEL          Scan mode (required): label identifying autofix PRs
#   AUTOFIX_BRANCH_PREFIX     Scan mode: head branch prefix of autofix PRs (open-PR limit and closed-PR
#                             filter; empty = no closed-PR prefix filter)
#   AUTOFIX_PR_SCAN_LIMIT     Positive integer, max PRs fetched per list (default 1000;
#                             leading zeros are decimal); reaching it fails closed
#   AUTOFIX_ITEMS             "true" emits result.items (one element) in single-Issue mode
#   AUTOFIX_MAX_OPEN_PRS      Scan mode: skip when open autofix PRs >= this integer (unset = no limit)
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
# hydrate_issue_number_from_event: Set ISSUE_NUMBER from event when unset
#
# Globals:
#   GITHUB_EVENT_PATH
#   ISSUE_NUMBER (set)
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
#   hydrate_issue_number_from_event
#
#######################################
function hydrate_issue_number_from_event {
    local event_path="${GITHUB_EVENT_PATH:-}"

    if [[ -n ${ISSUE_NUMBER:-} ]]; then
        return 0
    fi

    if [[ -z ${event_path} || ! -f ${event_path} ]]; then
        return 0
    fi

    ISSUE_NUMBER="$(jq -r '
        (.issue.number // .client_payload.issue_number // empty) | tostring
    ' "${event_path}")"

    if [[ ${ISSUE_NUMBER} == "null" || ${ISSUE_NUMBER} == "" ]]; then
        ISSUE_NUMBER=""
    fi
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
# ensure_pr_scan_prerequisites: Fail closed when duplicate-PR scan cannot run
#
# Globals:
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
#   None (calls output_error when prerequisites are missing)
#
# Usage:
#   ensure_pr_scan_prerequisites
#
#######################################
function ensure_pr_scan_prerequisites {
    if [[ -z ${GITHUB_REPOSITORY:-} ]]; then
        output_error "github-issue-autofix: GITHUB_REPOSITORY required to scan open PRs"
    fi

    if [[ -z ${GH_TOKEN:-${GITHUB_TOKEN:-}} ]]; then
        output_error "github-issue-autofix: GH_TOKEN or GITHUB_TOKEN required to scan open PRs"
    fi

    if ! command -v gh &> /dev/null; then
        output_error "github-issue-autofix: gh required to scan open PRs"
    fi
}

#######################################
# validate_pr_scan_limit: Validate AUTOFIX_PR_SCAN_LIMIT and set PR_SCAN_LIMIT
#
# Globals:
#   AUTOFIX_PR_SCAN_LIMIT
#   PR_SCAN_LIMIT (set; decimal integer, default 1000)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error when the value is not a positive integer)
#
# Usage:
#   validate_pr_scan_limit
#
#######################################
function validate_pr_scan_limit {
    PR_SCAN_LIMIT=1000
    if [[ -n ${AUTOFIX_PR_SCAN_LIMIT:-} ]]; then
        if [[ ! ${AUTOFIX_PR_SCAN_LIMIT} =~ ^[0-9]+$ || $((10#${AUTOFIX_PR_SCAN_LIMIT})) -lt 1 ]]; then
            output_error "github-issue-autofix: AUTOFIX_PR_SCAN_LIMIT must be a positive integer"
        fi
        PR_SCAN_LIMIT=$((10#${AUTOFIX_PR_SCAN_LIMIT}))
    fi
}

#######################################
# resolve_issue_state: Read the Issue state fact into ISSUE_STATE
#
# Globals:
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#   ISSUE_STATE (set; open | closed)
#
# Arguments:
#   $1 - Issue number
#
# Outputs:
#   None
#
# Returns:
#   0 on success; calls output_error (exit 1) when gh or jq fails. Not run in a subshell so
#   output_error can emit the error JSON
#
# Usage:
#   resolve_issue_state "${ISSUE_NUMBER}"
#
#######################################
function resolve_issue_state {
    local issue_number="$1"
    local issue

    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    if ! issue="$(gh api "repos/${GITHUB_REPOSITORY}/issues/${issue_number}" 2> /dev/null)"; then
        output_error "github-issue-autofix: failed to read Issue #${issue_number}"
    fi
    if ! ISSUE_STATE="$(jq -er '.state' <<< "${issue}" 2> /dev/null)"; then
        output_error "github-issue-autofix: unreadable state for Issue #${issue_number}"
    fi
}

#######################################
# open_pr_fixes_issue: Return whether an open/draft PR closes the Issue
#
# Globals:
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#   PR_SCAN_LIMIT
#
# Arguments:
#   $1 - Issue number
#
# Outputs:
#   None
#
# Returns:
#   0 when a matching open/draft PR exists; 1 when none (calls output_error on gh or jq failure)
#
# Usage:
#   if open_pr_fixes_issue "${ISSUE_NUMBER}"; then skip="true"; fi
#
#######################################
function open_pr_fixes_issue {
    local issue_number="$1"
    local prs pattern token rc=0

    token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    export GH_TOKEN="${token}"

    if ! prs="$(gh pr list --repo "${GITHUB_REPOSITORY}" --state open \
        --limit "${PR_SCAN_LIMIT}" --json number,title,body,isDraft 2> /dev/null)"; then
        output_error "github-issue-autofix: failed to list open PRs"
    fi
    scan_assert_below_limit "${prs}" "open"

    # GitHub closing keywords (tense variants) for same-repo #N
    pattern="(?i)\\b(fix(?:e[sd])?|close[sd]?|resolve[sd]?)\\s+#${issue_number}\\b"
    jq -e --arg re "${pattern}" '
        map(select((.title + "\n" + (.body // "")) | test($re))) | length > 0
    ' <<< "${prs}" > /dev/null 2>&1 || rc=$?
    case "${rc}" in
        0) return 0 ;;
        1) return 1 ;;
        *) output_error "github-issue-autofix: failed to evaluate open PRs (jq exit ${rc})" ;;
    esac
}

#######################################
# build_gate_json: Build the result.gate facts of the Issue
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_STATE
#
# Arguments:
#   None
#
# Outputs:
#   {"entity":{"kind":"issue","number":N,"state":S}} on stdout (no trigger: the admission gate
#   skips the actor and mention checks without a webhook source)
#
# Returns:
#   0 on success
#
#######################################
function build_gate_json {
    jq -nc --argjson n "${ISSUE_NUMBER}" --arg state "${ISSUE_STATE:-}" \
        '{entity: {kind: "issue", number: $n, state: $state}}'
}

#######################################
# build_result_json: Build the result object JSON
#
# Globals:
#   ISSUE_NUMBER
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
    local gate
    gate="$(build_gate_json)"
    jq -nc --arg issue_number "${ISSUE_NUMBER}" --argjson gate "${gate}" \
        '{issue_number: $issue_number, gate: $gate}'
}

#######################################
# output_json: Print structured detect JSON result
#
# Globals:
#   ISSUE_NUMBER
#   ISSUE_STATE
#   AUTOFIX_ITEMS
#
# Arguments:
#   $1 - skip flag (true|false)
#   $2 - Output message
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   None
#
# Usage:
#   output_json "${skip}" "${message}"
#
#######################################
function output_json {
    local skip="$1"
    local message="$2"
    local result_json

    if [[ ${skip} == "true" && -z ${ISSUE_NUMBER:-} ]]; then
        json_object \
            status "ok" \
            skip "true" \
            message "${message}" \
            result "{}"
        return 0
    fi

    if [[ ${AUTOFIX_ITEMS:-} == "true" ]]; then
        if [[ ${skip} == "true" ]]; then
            result_json="{}"
        else
            result_json="$(jq -n -c --argjson n "${ISSUE_NUMBER}" --argjson gate "$(build_gate_json)" '{items: [{
                key: ("issue:" + ($n | tostring)),
                entity: {kind: "issue", number: $n},
                context: {issue_number: $n},
                gate: $gate
            }]}')"
        fi
    else
        result_json="$(build_result_json)"
    fi
    json_object \
        status "ok" \
        skip "${skip}" \
        message "${message}" \
        result "${result_json}"
}

#######################################
# scan_validate_env: Fail when scan mode required environment is missing
#
# Globals:
#   AUTOFIX_SOURCE_LABEL
#   AUTOFIX_SOURCE_MARKER
#   AUTOFIX_PR_LABEL
#   AUTOFIX_MAX_OPEN_PRS
#   AUTOFIX_PR_SCAN_LIMIT
#   PR_SCAN_LIMIT (set; decimal integer, default 1000)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on missing or invalid values)
#
# Usage:
#   scan_validate_env
#
#######################################
function scan_validate_env {
    local name
    for name in AUTOFIX_SOURCE_LABEL AUTOFIX_SOURCE_MARKER AUTOFIX_PR_LABEL; do
        if [[ -z ${!name:-} ]]; then
            output_error "github-issue-autofix: ${name} required when AUTOFIX_SCAN=true"
        fi
    done

    if [[ -n ${AUTOFIX_MAX_OPEN_PRS:-} && ! ${AUTOFIX_MAX_OPEN_PRS} =~ ^[0-9]+$ ]]; then
        output_error "github-issue-autofix: AUTOFIX_MAX_OPEN_PRS must be a non-negative integer"
    fi

    validate_pr_scan_limit
}

#######################################
# scan_list_open_prs: List open PRs once (number, title, body, head, labels)
#
# Globals:
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#   PR_SCAN_LIMIT
#
# Arguments:
#   None
#
# Outputs:
#   JSON array to stdout
#
# Returns:
#   gh exit status (caller reports the error; output_error cannot run inside $(...))
#
# Usage:
#   open_prs="$(scan_list_open_prs)" || output_error "..."
#
#######################################
function scan_list_open_prs {
    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    gh pr list --repo "${GITHUB_REPOSITORY}" --state open --limit "${PR_SCAN_LIMIT}" \
        --json number,title,body,headRefName,labels 2> /dev/null
}

#######################################
# scan_open_pr_count: Count open autofix PRs (label + head branch prefix)
#
# Globals:
#   AUTOFIX_PR_LABEL
#   AUTOFIX_BRANCH_PREFIX
#
# Arguments:
#   $1 - Open PR JSON array (from scan_list_open_prs)
#
# Outputs:
#   Integer count to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   count="$(scan_open_pr_count "${open_prs}")"
#
#######################################
function scan_open_pr_count {
    jq -r --arg label "${AUTOFIX_PR_LABEL}" --arg prefix "${AUTOFIX_BRANCH_PREFIX:-}" '
        [.[] | select(((.labels // []) | map(.name) | index($label)) != null)
             | select((.headRefName // "") | startswith($prefix))] | length
    ' <<< "$1"
}

#######################################
# scan_fetch_issues: Fetch candidate Issue numbers (oldest first)
#
# Globals:
#   GITHUB_REPOSITORY
#   AUTOFIX_SOURCE_LABEL
#   AUTOFIX_SOURCE_MARKER
#   GH_TOKEN
#   GITHUB_TOKEN
#
# Arguments:
#   None
#
# Outputs:
#   JSON array of Issue numbers to stdout
#
# Returns:
#   non-zero when gh or jq fails (caller reports the error)
#
# Usage:
#   numbers="$(scan_fetch_issues)" || output_error "..."
#
#######################################
function scan_fetch_issues {
    local encoded raw
    encoded="$(jq -rn --arg v "${AUTOFIX_SOURCE_LABEL}" '$v | @uri')"
    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    raw="$(gh api --paginate \
        "repos/${GITHUB_REPOSITORY}/issues?labels=${encoded}&state=open&sort=created&direction=asc&per_page=100" 2> /dev/null)" || return 1

    jq -s -c --arg label "${AUTOFIX_SOURCE_LABEL}" --arg marker "${AUTOFIX_SOURCE_MARKER}" '
        [.[] | (if type == "array" then .[] else empty end)
            | select((.pull_request // null) == null)
            | select(((.labels // []) | map((.name // "") | ascii_downcase) | index($label | ascii_downcase)) != null)
            | select(((.labels // []) | map((.name // "") | ascii_downcase) | index("autofix")) == null)
            | select((.user.type // "") == "Bot")
            | select((.body // "") | contains($marker))
            | .number]
    ' <<< "${raw}"
}

#######################################
# scan_latest_closed_at: Latest closedAt of closed autofix PRs referencing an Issue
#
# Globals:
#   None
#
# Arguments:
#   $1 - Closed PR JSON array
#   $2 - Issue number
#
# Outputs:
#   closedAt string to stdout, empty when none
#
# Returns:
#   0 on success
#
# Usage:
#   closed_at="$(scan_latest_closed_at "${closed_prs}" 12)"
#
#######################################
function scan_latest_closed_at {
    local pattern="(?i)\\b(fix(?:e[sd])?|close[sd]?|resolve[sd]?)\\s+#${2}\\b"
    jq -r --arg re "${pattern}" '
        [.[] | select(.closedAt != null)
             | select(((.title // "") + "\n" + (.body // "")) | test($re))
             | .closedAt] | max // ""
    ' <<< "$1"
}

#######################################
# scan_has_newer_human_comment: Whether a trusted human (OWNER/MEMBER/COLLABORATOR, non-Bot) commented after closedAt
#
# Globals:
#   GITHUB_REPOSITORY
#
# Arguments:
#   $1 - Issue number
#   $2 - closedAt (ISO-8601 UTC)
#
# Outputs:
#   None
#
# Returns:
#   0 when a newer human comment exists; 1 when none (calls output_error when gh or jq fails)
#
# Usage:
#   if scan_has_newer_human_comment 12 "${closed_at}"; then ...; fi
#
#######################################
function scan_has_newer_human_comment {
    local comments
    if ! comments="$(gh api --paginate "repos/${GITHUB_REPOSITORY}/issues/${1}/comments?per_page=100" 2> /dev/null)"; then
        output_error "github-issue-autofix: failed to list comments for Issue #${1}"
    fi
    local rc=0
    jq -s -e --arg closed "${2}" '
        [.[] | (if type == "array" then .[] else empty end)
             | select((.user.type // "") != "Bot"
                      and ((.author_association // "") | IN("OWNER","MEMBER","COLLABORATOR")))
             | .created_at // ""] | any(. > $closed)
    ' <<< "${comments}" > /dev/null 2>&1 || rc=$?
    case "${rc}" in
        0) return 0 ;;
        1) return 1 ;;
        *) output_error "github-issue-autofix: failed to evaluate comments for Issue #${1} (jq exit ${rc})" ;;
    esac
}

#######################################
# scan_assert_below_limit: Fail closed when a PR list may have been truncated
#
# Globals:
#   PR_SCAN_LIMIT
#
# Arguments:
#   $1 - PR JSON array
#   $2 - List name for the error message
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error when the list is unreadable or reaches the limit)
#
# Usage:
#   scan_assert_below_limit "${open_prs}" "open"
#
#######################################
function scan_assert_below_limit {
    local length
    if ! length="$(jq -e 'length' <<< "$1" 2> /dev/null)"; then
        output_error "github-issue-autofix: unreadable ${2} PR list"
    fi
    if [[ ${length} -ge ${PR_SCAN_LIMIT} ]]; then
        output_error "github-issue-autofix: ${2} PR list reached AUTOFIX_PR_SCAN_LIMIT (${PR_SCAN_LIMIT}); results may be truncated"
    fi
}

#######################################
# scan_build_items: Filter candidates and build the result.items array
#
# Globals:
#   GITHUB_REPOSITORY
#   AUTOFIX_PR_LABEL
#   AUTOFIX_BRANCH_PREFIX
#   PR_SCAN_LIMIT
#   GH_TOKEN
#   GITHUB_TOKEN
#   SCAN_ITEMS (set)
#
# Arguments:
#   $1 - Candidate Issue numbers (JSON array)
#   $2 - Open PR JSON array
#
# Outputs:
#   None (result JSON array is stored in SCAN_ITEMS; not a subshell so errors can exit)
#
# Returns:
#   0 on success (calls output_error when gh fails)
#
# Usage:
#   scan_build_items "${numbers}" "${open_prs}"
#
#######################################
function scan_build_items {
    local numbers="$1" open_prs="$2"
    local closed_prs closed_at number pattern kept="[]" count=0 rc
    SCAN_ITEMS="[]"

    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    if ! closed_prs="$(gh pr list --repo "${GITHUB_REPOSITORY}" --state closed \
        --label "${AUTOFIX_PR_LABEL}" --limit "${PR_SCAN_LIMIT}" \
        --json number,title,body,closedAt,headRefName 2> /dev/null)"; then
        output_error "github-issue-autofix: failed to list closed PRs"
    fi
    scan_assert_below_limit "${closed_prs}" "closed"
    if [[ -n ${AUTOFIX_BRANCH_PREFIX:-} ]]; then
        if ! closed_prs="$(jq -c --arg prefix "${AUTOFIX_BRANCH_PREFIX}" '
            [.[] | select((.headRefName // "") | startswith($prefix))]
        ' <<< "${closed_prs}")"; then
            output_error "github-issue-autofix: failed to filter closed PRs"
        fi
    fi

    while IFS= read -r number; do
        [[ -n ${number} ]] || continue
        pattern="(?i)\\b(fix(?:e[sd])?|close[sd]?|resolve[sd]?)\\s+#${number}\\b"
        rc=0
        jq -e --arg re "${pattern}" '
            any(.[]; ((.title // "") + "\n" + (.body // "")) | test($re))
        ' <<< "${open_prs}" > /dev/null 2>&1 || rc=$?
        case "${rc}" in
            0) continue ;;
            1) ;;
            *) output_error "github-issue-autofix: failed to evaluate open PRs (jq exit ${rc})" ;;
        esac

        closed_at="$(scan_latest_closed_at "${closed_prs}" "${number}")"
        if [[ -n ${closed_at} ]] && ! scan_has_newer_human_comment "${number}" "${closed_at}"; then
            continue
        fi

        kept="$(jq -c --argjson n "${number}" '. + [{
            key: ("issue:" + ($n | tostring)),
            entity: {kind: "issue", number: $n},
            context: {issue_number: $n}
        }]' <<< "${kept}")"
        count=$((count + 1))
        if [[ ${count} -ge 50 ]]; then
            break
        fi
    done < <(jq -r '.[]' <<< "${numbers}")

    SCAN_ITEMS="${kept}"
}

#######################################
# scan_main: Scan mode entry; emit detect JSON with result.items
#
# Globals:
#   AUTOFIX_MAX_OPEN_PRS
#
# Arguments:
#   None
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success; exits 1 on fatal errors
#
# Usage:
#   scan_main
#
#######################################
function scan_main {
    local open_prs open_count numbers items count

    scan_validate_env
    ensure_pr_scan_prerequisites

    open_prs="$(scan_list_open_prs)" || output_error "github-issue-autofix: failed to list open PRs"
    scan_assert_below_limit "${open_prs}" "open"
    if [[ -n ${AUTOFIX_MAX_OPEN_PRS:-} ]]; then
        open_count="$(scan_open_pr_count "${open_prs}")"
        if [[ ${open_count} -ge $((10#${AUTOFIX_MAX_OPEN_PRS})) ]]; then
            json_object status "ok" skip "true" \
                message "github-issue-autofix: ${open_count} open autofix PRs (limit ${AUTOFIX_MAX_OPEN_PRS})" \
                result "{}"
            return 0
        fi
    fi

    numbers="$(scan_fetch_issues)" || output_error "github-issue-autofix: failed to list Issues"
    scan_build_items "${numbers}" "${open_prs}"
    items="${SCAN_ITEMS}"
    count="$(jq 'length' <<< "${items}")"

    if [[ ${count} -eq 0 ]]; then
        json_object status "ok" skip "true" \
            message "github-issue-autofix: no eligible Issues" \
            result "{}"
        return 0
    fi

    json_object status "ok" skip "false" \
        message "github-issue-autofix: ${count} eligible Issue(s)" \
        result "$(jq -c '{items: .}' <<< "${items}")"
}

#######################################
# main: Validate inputs, evaluate skip policy, emit detect JSON
#
# Globals:
#   ISSUE_NUMBER
#   GITHUB_EVENT_PATH
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#   AUTOFIX_SCAN
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
    local message=""

    ensure_dependencies bash jq

    if [[ ${AUTOFIX_SCAN:-} == "true" ]]; then
        scan_main
        return 0
    fi

    hydrate_issue_number_from_event
    ISSUE_NUMBER="${ISSUE_NUMBER:-}"

    if [[ -z ${ISSUE_NUMBER} ]]; then
        output_json "true" "github-issue-autofix: ISSUE_NUMBER required"
        return 0
    fi

    validate_issue_number "${ISSUE_NUMBER}"

    ensure_pr_scan_prerequisites
    validate_pr_scan_limit

    resolve_issue_state "${ISSUE_NUMBER}"
    if open_pr_fixes_issue "${ISSUE_NUMBER}"; then
        skip="true"
        message="github-issue-autofix: open/draft PR already references Fixes #${ISSUE_NUMBER}"
    else
        message="github-issue-autofix: proceed"
    fi

    output_json "${skip}" "${message}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
