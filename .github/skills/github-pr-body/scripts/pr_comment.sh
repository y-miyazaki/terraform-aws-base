#!/bin/bash
#######################################
# Description: Create or update PR overview comment
#
# Usage: ./pr-comment.sh <PR_NUMBER> <COMMENT_FILE> [--repo OWNER/REPO] [--dry-run]
#   --repo       Repository in owner/repo format (default: auto-detect from git)
#   --dry-run    Show what would be done without making changes
#   -h, --help   Display this help message
#
# Arguments:
#   PR_NUMBER              GitHub PR number
#   COMMENT_FILE           File containing comment markdown content
#
# Examples:
#   ./pr-comment.sh 123 comment.md
#   ./pr-comment.sh 123 comment.md --repo owner/repo
#   ./pr-comment.sh 123 comment.md --dry-run
#######################################

set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load common library
# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

#######################################
# Global variables
#######################################
PR_NUMBER=""
COMMENT_FILE=""
REPOSITORY=""
DRY_RUN="false"

#######################################
# show_usage: Display usage information
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") <PR_NUMBER> <COMMENT_FILE> [options]

Description: Create or update PR overview comment

Arguments:
  PR_NUMBER              GitHub PR number
  COMMENT_FILE           File containing comment markdown

Options:
  --repo OWNER/REPO      Repository (default: auto-detect from git)
  --dry-run              Show what would be done
  -h, --help             Display this help message

Examples:
  $(basename "$0") 123 comment.md
  $(basename "$0") 123 comment.md --repo owner/repo
  $(basename "$0") 123 comment.md --dry-run

Note:
  - Detects existing comment by: <!-- github-pr-body:v1 --> marker
  - Updates existing comment if found, creates new otherwise
  - Requires gh CLI with repo:write scope
EOF
}

#######################################
# get_repository_from_git: Auto-detect repository
#######################################
function get_repository_from_git {
    if ! git remote get-url origin &> /dev/null; then
        return 1
    fi

    local remote_url
    remote_url=$(git remote get-url origin)

    if [[ "$remote_url" =~ github\.com[:/]([^/]+)/(.+?)(.git)?$ ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    else
        return 1
    fi
}

#######################################
# find_existing_comment: Find comment by marker
#######################################
function find_existing_comment {
    gh pr view "$PR_NUMBER" \
        --repo "$REPOSITORY" \
        --json comments \
        --jq '.comments[] | select(.body | contains("<!-- github-pr-body:v1 -->") or contains("<!-- github-pr-overview:v1 -->")) | .id' \
        2> /dev/null || echo ""
}

#######################################
# create_comment: Create new PR comment
#######################################
function create_comment {
    log "INFO" "Creating new overview comment on PR #$PR_NUMBER"

    gh pr comment "$PR_NUMBER" \
        --repo "$REPOSITORY" \
        --body-file "$COMMENT_FILE" || error_exit "Failed to create comment"

    log "INFO" "✅ Comment created successfully"
}

#######################################
# update_comment: Update existing comment via GraphQL
#######################################
function update_comment {
    local comment_id="$1"

    log "INFO" "Updating existing comment $comment_id on PR #$PR_NUMBER"

    local body
    body=$(cat "$COMMENT_FILE")

    # shellcheck disable=SC2016
    gh api graphql \
        -f commentId="$comment_id" \
        -f body="$body" \
        -f query='
mutation UpdateComment($commentId: ID!, $body: String!) {
  updateIssueComment(input: {id: $commentId, body: $body}) {
    issueComment {
      id
      url
    }
  }
}' || error_exit "Failed to update comment"

    log "INFO" "✅ Comment updated successfully"
}

#######################################
# manage_comment: Create or update comment
#######################################
function manage_comment {
    local comment_id
    comment_id=$(find_existing_comment)

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN MODE"
        if [[ -n "$comment_id" ]]; then
            log "INFO" "Would update existing comment $comment_id"
        else
            log "INFO" "Would create new comment"
        fi
        log "INFO" ""
        log "INFO" "Comment content:"
        log "INFO" "---"
        cat "$COMMENT_FILE" >&2
        log "INFO" "---"
    else
        if [[ -n "$comment_id" ]]; then
            update_comment "$comment_id"
        else
            create_comment
        fi
    fi
}

#######################################
# parse_arguments: Parse command line
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
            *)
                if [[ -z "$PR_NUMBER" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
                    PR_NUMBER="$1"
                elif [[ -z "$COMMENT_FILE" ]] && [[ -f "$1" ]]; then
                    COMMENT_FILE="$1"
                else
                    error_exit "Invalid argument: $1"
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$PR_NUMBER" ]]; then
        error_exit "PR_NUMBER is required"
    fi
    if [[ -z "$COMMENT_FILE" ]]; then
        error_exit "COMMENT_FILE is required"
    fi
    if [[ ! -f "$COMMENT_FILE" ]]; then
        error_exit "Comment file not found: $COMMENT_FILE"
    fi
}

#######################################
# main: Main process
#######################################
function main {
    parse_arguments "$@"

    # Auto-detect repository if not provided
    if [[ -z "$REPOSITORY" ]]; then
        log "DEBUG" "Auto-detecting repository from git remote"
        if ! REPOSITORY=$(get_repository_from_git); then
            error_exit "Could not determine repository. Use --repo OWNER/REPO"
        fi
    fi

    # Validate prerequisites
    validate_dependencies "gh" "jq"

    # Check if PR exists
    if ! gh pr view "$PR_NUMBER" --repo "$REPOSITORY" &> /dev/null; then
        error_exit "PR #$PR_NUMBER not found in $REPOSITORY"
    fi

    # Manage comment
    manage_comment
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
