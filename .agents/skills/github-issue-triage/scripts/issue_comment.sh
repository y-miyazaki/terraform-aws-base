#!/bin/bash
#######################################
# Description: Post or correct github-issue-triage GitHub Issue comments
#
# Usage: ./issue_comment.sh create|correct <ISSUE_NUMBER> <COMMENT_FILE> [--repo OWNER/REPO] [--dry-run]
#   --repo       Repository in owner/repo format (default: auto-detect from git)
#   --dry-run    Show the intended action without GitHub write APIs
#   -h, --help   Display this help message
#
# Arguments:
#   create|correct         create posts a new comment; correct updates the latest marked comment
#   ISSUE_NUMBER           GitHub Issue number
#   COMMENT_FILE           File containing comment markdown
#
# Examples:
#   ./issue_comment.sh create 81 comment.md --repo owner/repo
#   ./issue_comment.sh correct 81 comment.md --repo owner/repo
#   ./issue_comment.sh create 81 comment.md --dry-run
#
# Output:
# - JSON object with action and issue_number; comment_id when action is update
#
# Design Rules:
# - Lives beside detect scripts (not under scripts/lib/) so
#   scripts/self/apm/sync_skill_lib.sh does not overwrite it
# - create always posts a new Issue comment (FSM transitions and re-triage)
# - correct updates only the latest comment that contains the skill marker
# - Never PATCH a comment without the skill marker (human comments)
# - Prepend the skill marker when the body file omits it
# - Exit 0 on success; fatal errors use error_exit (stderr + non-zero)
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
# - Do not call repository_dispatch
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - gh
# - jq
#
# Environment:
#   GH_TOKEN / GITHUB_TOKEN   Token with issues:write (used by gh)
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
# Global variables
#######################################
# COMMENT_MARKER: HTML marker that identifies github-issue-triage bot comments (do not PATCH unmarked comments)
COMMENT_MARKER="<!-- github-issue-triage:v1 -->"
# ACTION: create | correct (empty until parse_arguments)
ACTION=""
# ISSUE_NUMBER: GitHub Issue number (digits only)
ISSUE_NUMBER=""
# COMMENT_FILE: Path to markdown body supplied by the caller
COMMENT_FILE=""
# REPOSITORY: owner/repo slug (required; auto-detected from origin when omitted)
REPOSITORY=""
# DRY_RUN: "true" skips GitHub write APIs (default: false)
DRY_RUN="false"

#######################################
# show_usage: Display usage information
#
# Globals:
#   COMMENT_MARKER - Included in help Note
#
# Arguments:
#   None
#
# Outputs:
#   Help text to stdout
#
# Returns:
#   Exits with code 0
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") create|correct ISSUE_NUMBER COMMENT_FILE [options]

Description: Post a new github-issue-triage comment, or correct the latest marked bot comment

Arguments:
  create|correct         create posts a new comment; correct updates the latest marked comment
  ISSUE_NUMBER           GitHub Issue number
  COMMENT_FILE           File containing comment markdown

Options:
  --repo OWNER/REPO      Repository (default: auto-detect from git)
  --dry-run              Show intended action without calling GitHub write APIs
  -h, --help             Display this help message

Examples:
  $(basename "$0") create 81 comment.md --repo owner/repo
  $(basename "$0") correct 81 comment.md --repo owner/repo
  $(basename "$0") create 81 comment.md --dry-run

Note:
  - Identifies bot comments by: ${COMMENT_MARKER}
  - create always posts a new comment
  - correct updates only the latest marked comment; fails when none exists
  - Requires gh CLI with issues:write
EOF
}

#######################################
# get_repository_from_git: Auto-detect repository from origin
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   owner/repo to stdout when detected
#
# Returns:
#   0 on success, 1 otherwise
#
# Usage:
#   REPOSITORY="$(get_repository_from_git)"
#
#######################################
function get_repository_from_git {
    if ! git remote get-url origin &> /dev/null; then
        return 1
    fi

    local remote_url
    remote_url=$(git remote get-url origin)

    if [[ $remote_url =~ github\.com[:/]([^/]+)/(.+?)(.git)?$ ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    else
        return 1
    fi
}

#######################################
# body_with_marker: Write comment body with skill marker to a temp file
#
# Globals:
#   COMMENT_FILE - Source markdown path
#   COMMENT_MARKER - HTML comment marker
#
# Arguments:
#   $1 - Destination path
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
# Usage:
#   body_with_marker "${marked_body}"
#
#######################################
function body_with_marker {
    local dest="$1"
    local body
    body="$(cat "${COMMENT_FILE}")"
    if [[ ${body} == *"${COMMENT_MARKER}"* ]]; then
        printf '%s\n' "${body}" > "${dest}"
    else
        printf '%s\n\n%s\n' "${COMMENT_MARKER}" "${body}" > "${dest}"
    fi
}

#######################################
# latest_marked_comment_id: Return REST id of the latest marked comment
#
# Globals:
#   REPOSITORY - owner/repo
#   ISSUE_NUMBER - Issue number
#   COMMENT_MARKER - HTML comment marker
#
# Arguments:
#   None
#
# Outputs:
#   Comment id to stdout, or empty when none
#
# Returns:
#   0 on success
#
# Usage:
#   comment_id="$(latest_marked_comment_id)"
#
#######################################
function latest_marked_comment_id {
    gh api --paginate "repos/${REPOSITORY}/issues/${ISSUE_NUMBER}/comments" \
        | jq -s --arg marker "${COMMENT_MARKER}" -r '
            add
            | map(select(.body | contains($marker)))
            | sort_by(.created_at)
            | (.[-1].id // empty)
        '
}

#######################################
# create_comment: Post a new Issue comment
#
# Globals:
#   ISSUE_NUMBER - Issue number
#   REPOSITORY - owner/repo
#   DRY_RUN - true skips the write
#
# Arguments:
#   $1 - Body file path (already includes marker)
#
# Outputs:
#   Result JSON to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   create_comment "${marked_body}"
#
#######################################
function create_comment {
    local body_file="$1"
    if [[ ${DRY_RUN} == "true" ]]; then
        log "INFO" "Would create issue comment on #${ISSUE_NUMBER}"
    else
        gh issue comment "${ISSUE_NUMBER}" \
            --repo "${REPOSITORY}" \
            --body-file "${body_file}" || error_exit "Failed to create issue comment"
    fi
    jq -n --argjson issue_number "${ISSUE_NUMBER}" '{action: "create", issue_number: $issue_number}'
}

#######################################
# correct_comment: PATCH the latest marked bot comment
#
# Globals:
#   ISSUE_NUMBER - Issue number
#   REPOSITORY - owner/repo
#   DRY_RUN - true skips the write
#
# Arguments:
#   $1 - Body file path (already includes marker)
#
# Outputs:
#   Result JSON to stdout
#
# Returns:
#   0 on success; exits non-zero when no marked comment exists
#
# Usage:
#   correct_comment "${marked_body}"
#
#######################################
function correct_comment {
    local body_file="$1"
    local comment_id body payload
    comment_id="$(latest_marked_comment_id)"
    if [[ -z ${comment_id} || ${comment_id} == "null" ]]; then
        error_exit "No github-issue-triage marker comment to correct on #${ISSUE_NUMBER}"
    fi
    body="$(cat "${body_file}")"
    payload="$(jq -n --arg body "${body}" '{body: $body}')"
    if [[ ${DRY_RUN} == "true" ]]; then
        log "INFO" "Would update issue comment ${comment_id} on #${ISSUE_NUMBER}"
    else
        gh api --method PATCH "repos/${REPOSITORY}/issues/comments/${comment_id}" \
            --input - <<< "${payload}" || error_exit "Failed to update issue comment ${comment_id}"
    fi
    jq -n --argjson issue_number "${ISSUE_NUMBER}" --argjson comment_id "${comment_id}" \
        '{action: "update", issue_number: $issue_number, comment_id: $comment_id}'
}

#######################################
# parse_arguments: Parse command line
#
# Globals:
#   ACTION - Set to create or correct
#   ISSUE_NUMBER - Set from positional digits
#   COMMENT_FILE - Set from positional path
#   REPOSITORY - Set from --repo
#   DRY_RUN - Set from --dry-run
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   Exits on invalid arguments
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                exit 0
                ;;
            --repo)
                REPOSITORY="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            create | correct)
                if [[ -n ${ACTION} ]]; then
                    error_exit "Invalid argument: $1"
                fi
                ACTION="$1"
                shift
                ;;
            *)
                if [[ -z ${ISSUE_NUMBER} ]] && [[ $1 =~ ^[0-9]+$ ]]; then
                    ISSUE_NUMBER="$1"
                elif [[ -z ${COMMENT_FILE} ]]; then
                    COMMENT_FILE="$1"
                else
                    error_exit "Invalid argument: $1"
                fi
                shift
                ;;
        esac
    done

    if [[ -z ${ACTION} ]]; then
        error_exit "ACTION create|correct is required"
    fi
    if [[ -z ${ISSUE_NUMBER} ]]; then
        error_exit "ISSUE_NUMBER is required"
    fi
    if [[ -z ${COMMENT_FILE} ]]; then
        error_exit "COMMENT_FILE is required"
    fi
    if [[ ! -f ${COMMENT_FILE} ]]; then
        error_exit "Comment file not found: ${COMMENT_FILE}"
    fi
}

#######################################
# main: Main process
#
# Globals:
#   ACTION - create or correct
#   ISSUE_NUMBER - GitHub Issue number
#   COMMENT_FILE - Markdown body path
#   REPOSITORY - owner/repo (set when omitted)
#   DRY_RUN - true skips writes
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Result JSON to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   main "$@"
#
#######################################
function main {
    local marked_body
    parse_arguments "$@"

    if [[ -z ${REPOSITORY} ]]; then
        if ! REPOSITORY=$(get_repository_from_git); then
            error_exit "Could not determine repository. Use --repo OWNER/REPO"
        fi
    fi

    require_dependencies "gh" "jq"

    marked_body="$(mktemp)"
    body_with_marker "${marked_body}"

    case "${ACTION}" in
        create)
            create_comment "${marked_body}"
            ;;
        correct)
            correct_comment "${marked_body}"
            ;;
        *)
            error_exit "Unknown action: ${ACTION}"
            ;;
    esac
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
