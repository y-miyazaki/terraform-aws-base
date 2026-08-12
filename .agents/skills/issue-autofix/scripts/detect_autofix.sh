#!/bin/bash
#######################################
# Description: Detect Issue autofix intake facts for issue-autofix automation
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
        output_error "issue-autofix: GITHUB_REPOSITORY required to scan open PRs"
    fi

    if [[ -z ${GH_TOKEN:-${GITHUB_TOKEN:-}} ]]; then
        output_error "issue-autofix: GH_TOKEN or GITHUB_TOKEN required to scan open PRs"
    fi

    if ! command -v gh &> /dev/null; then
        output_error "issue-autofix: gh required to scan open PRs"
    fi
}

#######################################
# open_pr_fixes_issue: Return whether an open/draft PR closes the Issue
#
# Globals:
#   GITHUB_REPOSITORY
#   GH_TOKEN
#   GITHUB_TOKEN
#
# Arguments:
#   $1 - Issue number
#
# Outputs:
#   None
#
# Returns:
#   0 when a matching open/draft PR exists; 1 when none
#
# Usage:
#   if open_pr_fixes_issue "${ISSUE_NUMBER}"; then skip="true"; fi
#
#######################################
function open_pr_fixes_issue {
    local issue_number="$1"
    local prs pattern token

    token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    export GH_TOKEN="${token}"

    if ! prs="$(gh pr list --repo "${GITHUB_REPOSITORY}" --state open \
        --json number,title,body,isDraft 2> /dev/null)"; then
        output_error "issue-autofix: failed to list open PRs"
    fi

    # GitHub closing keywords (tense variants) for same-repo #N
    pattern="(?i)\\b(fix(?:e[sd])?|close[sd]?|resolve[sd]?)\\s+#${issue_number}\\b"
    jq -e --arg re "${pattern}" '
        map(select((.title + "\n" + (.body // "")) | test($re))) | length > 0
    ' <<< "${prs}" > /dev/null
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
    json_object issue_number "${ISSUE_NUMBER}"
}

#######################################
# output_json: Print structured detect JSON result
#
# Globals:
#   ISSUE_NUMBER
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

    result_json="$(build_result_json)"
    json_object \
        status "ok" \
        skip "${skip}" \
        message "${message}" \
        result "${result_json}"
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

    hydrate_issue_number_from_event
    ISSUE_NUMBER="${ISSUE_NUMBER:-}"

    if [[ -z ${ISSUE_NUMBER} ]]; then
        output_json "true" "issue-autofix: ISSUE_NUMBER required"
        return 0
    fi

    validate_issue_number "${ISSUE_NUMBER}"

    ensure_pr_scan_prerequisites

    if open_pr_fixes_issue "${ISSUE_NUMBER}"; then
        skip="true"
        message="issue-autofix: open/draft PR already references Fixes #${ISSUE_NUMBER}"
    else
        message="issue-autofix: proceed"
    fi

    output_json "${skip}" "${message}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
