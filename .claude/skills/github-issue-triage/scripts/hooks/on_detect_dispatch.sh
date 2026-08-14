#!/bin/bash
#######################################
# Description: Trusted post-detect repository_dispatch hook for github-issue-triage
#
# Usage:
#   ./on_detect_dispatch.sh <detect.json>
#   ./on_detect_dispatch.sh   # reads detect JSON from stdin
#
# Contract:
# - Invoked only by trusted platform paths (never by the Agent).
# - When result.dispatch_requested is not true: no-op, exit 0.
# - When true: POST repos/{owner}/{repo}/dispatches with event_type + client_payload.
# - DISPATCH_DRY_RUN=1 logs the intended call and exits 0 without calling GitHub.
#
# Environment:
#   GH_TOKEN / GITHUB_TOKEN  Token with permission to create repository_dispatch
#   GITHUB_REPOSITORY        owner/repo
#   DISPATCH_DRY_RUN         When 1, skip live API call
#
# See: scripts/hooks/README.md
#######################################
set -euo pipefail
umask 027
export LC_ALL=C.UTF-8

readonly -a ALLOWED_DISPATCH_EVENT_TYPES=("loop-github-issue-autofix")

#######################################
# usage: Print usage message and exit
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Usage text on stderr
#
# Returns:
#   Exits 2
#
#######################################
function usage {
    echo "Usage: $0 [detect.json]" >&2
    exit 2
}

#######################################
# main: Post repository_dispatch when detect JSON requests it
#
# Globals:
#   GH_TOKEN, GITHUB_TOKEN, GITHUB_REPOSITORY, DISPATCH_DRY_RUN
#
# Arguments:
#   $1 - Optional path to detect JSON (stdin when omitted)
#
# Outputs:
#   Diagnostic lines on stderr; API payload on stdout for gh
#
# Returns:
#   0 on success or no-op, non-zero on failure
#
#######################################
function main {
    local detect_json detect_path="${1:-}"
    local requested event_type payload body

    if [[ -n ${detect_path} ]]; then
        if [[ ! -f ${detect_path} ]]; then
            echo "on_detect_dispatch: detect JSON file not found: ${detect_path}" >&2
            exit 1
        fi
        detect_json="$(jq -c . "${detect_path}")"
    else
        detect_json="$(jq -c .)"
    fi

    requested="$(jq -r '.result.dispatch_requested // false' <<< "${detect_json}")"
    if [[ ${requested} != "true" ]]; then
        echo "on_detect_dispatch: skip (dispatch_requested!=true)" >&2
        return 0
    fi

    event_type="$(jq -r '.result.dispatch_event_type // "loop-github-issue-autofix"' <<< "${detect_json}")"
    local allowed="false" et
    for et in "${ALLOWED_DISPATCH_EVENT_TYPES[@]}"; do
        if [[ ${event_type} == "${et}" ]]; then
            allowed="true"
            break
        fi
    done
    if [[ ${allowed} != "true" ]]; then
        echo "on_detect_dispatch: reject disallowed event_type=${event_type}" >&2
        exit 1
    fi
    payload="$(jq -c '.result.dispatch_client_payload // {}' <<< "${detect_json}")"
    if ! jq -e '
        type == "object"
        and (.issue_number | type) == "string"
        and (.issue_number | test("^[1-9][0-9]*$"))
        and length == 1
    ' <<< "${payload}" > /dev/null 2>&1; then
        echo "on_detect_dispatch: reject invalid dispatch_client_payload" >&2
        exit 1
    fi
    payload="$(jq -nc --arg n "$(jq -r '.issue_number' <<< "${payload}")" '{issue_number: $n}')"

    if [[ ${DISPATCH_DRY_RUN:-0} == "1" ]]; then
        echo "on_detect_dispatch: dry-run type=${event_type} payload=${payload}" >&2
        return 0
    fi

    : "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required for live dispatch}"
    if [[ -z ${GH_TOKEN:-${GITHUB_TOKEN:-}} ]]; then
        echo "on_detect_dispatch: GH_TOKEN or GITHUB_TOKEN required for live dispatch" >&2
        exit 1
    fi
    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN}}"

    body="$(jq -nc --arg et "${event_type}" --argjson p "${payload}" \
        '{event_type: $et, client_payload: $p}')"

    echo "on_detect_dispatch: repository_dispatch type=${event_type}" >&2
    printf '%s' "${body}" | gh api --method POST "repos/${GITHUB_REPOSITORY}/dispatches" --input -
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    if [[ $# -gt 1 ]]; then
        usage
    fi
    main "$@"
fi
