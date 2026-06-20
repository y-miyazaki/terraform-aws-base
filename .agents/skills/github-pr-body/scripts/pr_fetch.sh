#!/bin/bash
#######################################
# Description: Fetch and parse PR metadata
#
# Usage: ./pr_fetch.sh <PR_NUMBER> [--repo OWNER/REPO] [--format json]
#   --repo       Repository in owner/repo format (default: auto-detect from git)
#   --format     Output format: json (default)
#   -h, --help   Display this help message
#
# Output: JSON with PR metadata including files, statistics, template sections
#
# Examples:
#   ./pr_fetch.sh 123
#   ./pr_fetch.sh 123 --repo owner/repo
#   ./pr_fetch.sh 123 --format json
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
REPOSITORY=""
OUTPUT_FORMAT="json"

#######################################
# show_usage: Display usage information
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") <PR_NUMBER> [options]

Description: Fetch PR metadata and analyze file changes

Arguments:
  PR_NUMBER              GitHub PR number

Options:
    --repo OWNER/REPO      Repository (default: auto-detect from git)
    --format FORMAT        Output format: json (default: json)
    -h, --help             Display this help message

Examples:
    $(basename "$0") 123
    $(basename "$0") 123 --repo owner/repo
    $(basename "$0") 123 --format json

Output contains:
  - PR metadata (title, body, branches, statistics)
  - File changes (path, additions, deletions)
  - Parsed template sections (Overview, Changes, Type of Change)
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
# fetch_pr_metadata: Fetch PR info via gh
#######################################
function fetch_pr_metadata {
    log "INFO" "Fetching PR #$PR_NUMBER metadata from $REPOSITORY"

    gh pr view "$PR_NUMBER" --repo "$REPOSITORY" \
        --json title,body,additions,deletions,baseRefName,headRefName,state \
        --jq '.'
}

#######################################
# fetch_pr_files_paginated: Fetch all PR files via GitHub API pagination
#######################################
function fetch_pr_files_paginated {
    log "INFO" "Fetching all files for PR #$PR_NUMBER via paginated API"

    gh api --paginate \
        -H "Accept: application/vnd.github+json" \
        "repos/$REPOSITORY/pulls/$PR_NUMBER/files?per_page=100" \
        | jq -s 'add | map({path: .filename, additions: .additions, deletions: .deletions})'
}

#######################################
# parse_template_sections: Extract template sections
#######################################
function parse_template_sections {
    local pr_body="$1"
    local overview=""
    local changes=""
    local type_of_change=""

    # Extract sections using regex patterns
    overview=$(echo "$pr_body" \
        | sed -n '/^#\+ Overview\|^#\+ Summary\|^#\+ Description/,/^#\+ [^#]/p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' | head -20 || echo "")

    changes=$(echo "$pr_body" \
        | sed -n '/^#\+ Changes\|^#\+ What Changed/,/^#\+ [^#]/p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' || echo "")

    type_of_change=$(echo "$pr_body" \
        | sed -n '/^#\+ Type of Change/,/^#\+ [^#]/p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' || echo "")

    jq -n \
        --arg overview "$overview" \
        --arg changes "$changes" \
        --arg type_of_change "$type_of_change" \
        '{overview: $overview, changes: $changes, type_of_change: $type_of_change}'
}

#######################################
# classify_files: Classify files by type
#######################################
function classify_files {
    local files_json="$1"

    echo "$files_json" | jq '
    map(
        .path as $path |
        if ($path | test("_test\\.(go|ts|js|py|java)$")) then
            .type = "Test"
        elif ($path | test("\\.(md|txt|rst)$")) then
            .type = "Docs"
        elif ($path | test("(Dockerfile|docker-compose|\\.github/workflows|manifest|stack|terraform|Makefile|package\\.json|go\\.mod)")) then
            .type = "Config"
        elif ($path | test("\\.(go|ts|js|py|java)$")) then
            .type = "Feature"
        else
            .type = "Other"
        end
    ) |
    sort_by(.type) |
    group_by(.type) |
    map(
        {
            type: .[0].type,
            files: map({path: .path, additions: .additions, deletions: .deletions})
        }
    ) |
    sort_by(.type)
    '
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
            --format)
                OUTPUT_FORMAT="$2"
                if [[ "$OUTPUT_FORMAT" != "json" ]]; then
                    error_exit "Unsupported format: $OUTPUT_FORMAT (supported: json)"
                fi
                shift 2
                ;;
            *)
                if [[ -z "$PR_NUMBER" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
                    PR_NUMBER="$1"
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

    # Fetch PR metadata
    local pr_metadata
    pr_metadata=$(fetch_pr_metadata)

    # Fetch all PR files (avoid gh pr view files truncation on large PRs)
    local files_json
    files_json=$(fetch_pr_files_paginated)

    local pr_body
    pr_body=$(echo "$pr_metadata" | jq -r '.body // empty')

    # Parse template sections
    local template_sections
    template_sections=$(parse_template_sections "$pr_body")

    # Classify files
    local classified_files
    classified_files=$(classify_files "$files_json")

    # Combine results
    local result
    result=$(echo "$pr_metadata" \
        | jq \
            --argjson files "$files_json" \
            --argjson template "$template_sections" \
            --argjson classified "$classified_files" \
            '{
                metadata: (. + {files: $files}),
                template: $template,
                classified_files: $classified
            }')

    # Output in requested format
    case "$OUTPUT_FORMAT" in
        json)
            echo "$result"
            ;;
        *)
            error_exit "Unknown format: $OUTPUT_FORMAT"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
