#!/bin/bash
#######################################
# Description: Update PR Body sections with AI-generated or baseline content
#
# Usage: ./pr_body.sh <PR_NUMBER> [--repo OWNER/REPO] [--overview-file FILE] [--verbose] [--dry-run]
#   --repo           Repository in owner/repo format (default: auto-detect from git)
#   --overview-file  Path to AI-generated Overview content file (optional)
#   --verbose        Enable verbose output (SCRIPT_VERBOSE=1)
#   --dry-run        Show what would be done without making changes
#
# Behavior:
#   - Updates PR Body sections: ## Overview (from file or baseline), ## Changes
#   - Replaces only generated sections and preserves other existing sections
#   - Overview: uses --overview-file content if provided, otherwise generates baseline
#   - Changes: always generated from deterministic file classification
#   - Multiple executions are idempotent
#
# Examples:
#   ./pr_body.sh 123 --overview-file /tmp/ai_overview.md
#   ./pr_body.sh 123 --repo octocat/Hello-World
#   ./pr_body.sh 123 --verbose --dry-run
#######################################

set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables
#######################################
PR_NUMBER=""
REPOSITORY=""
OVERVIEW_FILE=""
DRY_RUN="false"
CHANGES_LIST_THRESHOLD=30
BODY_FILE="/tmp/pr_body_$$.md"
TMP_FILES=()

#######################################
# Cleanup function
#######################################
# cleanup: Remove temporary files
#
# Description:
#   Removes all temporary files created during script execution.
#   Registered as EXIT trap handler for automatic cleanup.
#
# Arguments:
#   None
#
# Global Variables:
#   TMP_FILES - Array of temporary file paths to clean up
#
# Returns:
#   None
#
# Usage:
#   cleanup
#
#######################################
function cleanup {
    # Remove temporary files
    for file in "${TMP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
        fi
    done
}

trap cleanup EXIT

#######################################
# show_usage: Display usage information
#
# Description:
#   Displays usage information for the script, including command syntax,
#   options, and examples. Exits with status 0 after display.
#
# Arguments:
#   None
#
# Returns:
#   Exits with status 0 after display
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") <PR_NUMBER> [options]

Description: Update PR Body sections with AI-generated or baseline content

Arguments:
  PR_NUMBER                 GitHub PR number

Options:
  --repo OWNER/REPO         Repository (default: auto-detect from git)
  --overview-file FILE      Path to AI-generated Overview content (optional)
  --verbose                 Enable verbose output
  --dry-run                 Show what would be done
  -h, --help                Display this help message

Behavior:
  - Updates PR Body sections: ## Overview, ## Changes
  - Overview: uses --overview-file content if provided, otherwise generates baseline
  - Changes: always generated from deterministic file classification
  - Replaces generated sections and preserves other existing sections
  - Idempotent: multiple executions produce same result

Examples:
  $(basename "$0") 123 --overview-file /tmp/ai_overview.md
  $(basename "$0") 123 --repo owner/repo
  $(basename "$0") 123 --verbose --dry-run

For more information, see: SKILL.md
EOF
}

#######################################
# get_repository_from_git: Auto-detect repository from git remote
#
# Description:
#   Extracts repository name in owner/repo format from git remote URL.
#   Handles both HTTPS and SSH git URL formats.
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Outputs repository name (owner/repo) on success, exits with error on failure
#
# Usage:
#   REPOSITORY=$(get_repository_from_git)
#
#######################################
function get_repository_from_git {
    if ! git remote get-url origin &> /dev/null; then
        return 1
    fi

    local remote_url
    remote_url=$(git remote get-url origin)

    # Extract owner/repo from git URL
    # Handles both HTTPS (github.com/owner/repo.git) and SSH (github.com:owner/repo.git) formats
    if [[ "$remote_url" =~ github\.com[:/]([^/]+)/(.+?)(.git)?$ ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    else
        return 1
    fi
}

#######################################
# validate_pr_exists: Check if PR exists
#
# Description:
#   Verifies that the specified PR exists in the given repository.
#   Exits with error if PR is not found.
#
# Arguments:
#   None
#
# Global Variables:
#   PR_NUMBER - GitHub PR number to validate
#   REPOSITORY - Repository in owner/repo format
#
# Returns:
#   None (exits with error if PR not found)
#
# Usage:
#   validate_pr_exists
#
#######################################
function validate_pr_exists {
    if ! gh pr view "$PR_NUMBER" --repo "$REPOSITORY" &> /dev/null; then
        error_exit "PR #$PR_NUMBER not found in $REPOSITORY"
    fi
}

#######################################
# parse_template_sections: Extract template sections from PR body
#
# Description:
#   Parses PR body to extract key template sections:
#   - Overview/Summary/Description
#   - Related Issues
#   - Changes
#   - Type of Change
#   - Testing
#
# Arguments:
#   $1 - PR body text
#
# Global Variables:
#   None
#
# Returns:
#   Outputs JSON with extracted sections
#
# Usage:
#   sections=$(parse_template_sections "$pr_body")
#   overview=$(echo "$sections" | jq -r '.overview')
#
#######################################
function parse_template_sections {
    local pr_body="$1"
    local overview=""
    local changes=""
    local type_of_change=""
    local testing=""
    local related_issues=""

    # Extract Overview/Summary/Description (first major content section)
    # Match only single # header, extract until next ## header
    overview=$(echo "$pr_body" \
        | sed -n '/^# Overview\|^# Summary\|^# Description/,/^## /p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' | grep -v '^[[:space:]]*$' | head -20 || echo "")

    # Extract Changes section (## level, extract until next ## header)
    changes=$(echo "$pr_body" \
        | sed -n '/^## Changes/,/^## /p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' | grep -v '^[[:space:]]*$' || echo "")

    # Extract Type of Change section
    type_of_change=$(echo "$pr_body" \
        | sed -n '/^## Type of Change/,/^## /p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' | grep -v '^[[:space:]]*$' || echo "")

    # Extract Testing section
    testing=$(echo "$pr_body" \
        | sed -n '/^## Test/,/^## /p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' | grep -v '^[[:space:]]*$' || echo "")

    # Extract Related Issues
    related_issues=$(echo "$pr_body" \
        | sed -n '/^## Related\|^## Issue/,/^## /p' \
        | sed '1d;$d' | grep -v '^<!--' | sed '/^$/d' | grep -v '^[[:space:]]*$' || echo "")

    # Output as JSON
    jq -n \
        --arg overview "$overview" \
        --arg changes "$changes" \
        --arg type_of_change "$type_of_change" \
        --arg testing "$testing" \
        --arg related_issues "$related_issues" \
        '{overview: $overview, changes: $changes, type_of_change: $type_of_change, testing: $testing, related_issues: $related_issues}'
}

#######################################
# classify_file_changes: Classify files by type
#
# Description:
#   Classifies changed files into categories: Feature, Fix, Refactor, Test, Docs, Config, etc.
#   Uses file path patterns to determine classification.
#
# Arguments:
#   $1 - JSON array of file objects from gh pr view
#
# Returns:
#   Outputs JSON with files grouped by classification
#
# Usage:
#   classified=$(classify_file_changes "$files_json")
#
#######################################
function classify_file_changes {
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
# generate_changes_section: Generate detailed Changes section
#
# Description:
#   Creates a detailed Changes section grouped by file type and directory.
#   Lists specific modifications with line counts.
#
# Arguments:
#   $1 - JSON with classified files
#
# Returns:
#   Outputs markdown for Changes section
#
# Usage:
#   generate_changes_section "$classified_files"
#
#######################################
function generate_changes_section {
    local classified_json="$1"
    local threshold="${2:-$CHANGES_LIST_THRESHOLD}"

    local total_files
    total_files=$(echo "$classified_json" | jq '[.[].files | length] | add // 0')

    if ((total_files > threshold)); then
        echo "_Changes list is summarized because total changed files exceed ${threshold}._"
        echo ""

        echo "$classified_json" | jq -r '
        .[] |
        "### " + .type + " (" + ((.files | length) | tostring) + " files, +" + (([.files[].additions] | add // 0) | tostring) + " / -" + (([.files[].deletions] | add // 0) | tostring) + " lines)\n" +
        ((.files | .[0:5] | map("- **\(.path)**: +\(.additions) / -\(.deletions) lines") | join("\n"))) +
        (if (.files | length) > 5 then "\n- ... and " + (((.files | length) - 5) | tostring) + " more files" else "" end) +
        "\n"
        '
    else
        echo "$classified_json" | jq -r '
        .[] |
        "### " + .type + "\n" +
        (.files |
        map("- **\(.path)**: +\(.additions) / -\(.deletions) lines") |
        join("\n")) +
        "\n"
        '
    fi
}

#######################################
# generate_body_sections: Generate PR Body sections for ## Overview and ## Changes
#
# Description:
#   Generates markdown content for PR Body sections:
#   - ## Overview: (populated from PR metadata and file analysis)
#   - ## Changes: (lists files grouped by type with line counts)
#
#   Content is generated fresh each time, ignoring existing PR body content.
#   Meant to be inserted/replaced in PR Body directly.
#
# Arguments:
#   None
#
# Global Variables:
#   PR_NUMBER - GitHub PR number
#   REPOSITORY - Repository in owner/repo format
#   BODY_FILE - Path to output body file
#   TMP_FILES - Array to track temporary files
#
# Returns:
#   None (writes body sections to BODY_FILE)
#
# Usage:
#   generate_body_sections
#
#######################################
function generate_body_sections {
    local pr_title
    local pr_info
    local pr_additions
    local pr_deletions
    local pr_base_ref
    local pr_head_ref
    local pr_file_count
    local files_json
    local classified_changes

    log "INFO" "Analyzing PR #$PR_NUMBER"

    # Fetch PR metadata via pr_fetch.sh to avoid file truncation on large PRs
    pr_info=$("${SCRIPT_DIR}/pr_fetch.sh" "$PR_NUMBER" --repo "$REPOSITORY" --format json)

    pr_title=$(echo "$pr_info" | jq -r '.metadata.title')
    pr_additions=$(echo "$pr_info" | jq -r '.metadata.additions')
    pr_deletions=$(echo "$pr_info" | jq -r '.metadata.deletions')
    pr_base_ref=$(echo "$pr_info" | jq -r '.metadata.baseRefName')
    pr_head_ref=$(echo "$pr_info" | jq -r '.metadata.headRefName')
    pr_file_count=$(echo "$pr_info" | jq -r '.metadata.files | length')

    # Extract and classify file changes
    files_json=$(echo "$pr_info" | jq '.metadata.files')

    classified_changes=$(classify_file_changes "$files_json")

    # Generate body sections
    {
        echo "## Overview"
        echo ""

        # Use overview file if provided, otherwise generate baseline
        if [[ -n "$OVERVIEW_FILE" ]]; then
            if [[ ! -f "$OVERVIEW_FILE" ]]; then
                error_exit "Overview file not found: $OVERVIEW_FILE"
            fi
            log "INFO" "Using Overview content from: $OVERVIEW_FILE"
            cat "$OVERVIEW_FILE"
            echo ""
        else
            log "INFO" "Generating baseline Overview (no --overview-file provided)"
            echo "**Title**: $pr_title"
            echo ""
            echo "**Branch**: $pr_head_ref -> $pr_base_ref"
            echo ""
            echo "**Stats**: $pr_file_count files changed (+$pr_additions / -$pr_deletions lines)"
            echo ""
            echo "_This section was auto-generated._"
            echo ""
        fi

        echo "## Changes"
        echo ""
        generate_changes_section "$classified_changes"
        echo ""
        echo "**Summary**: $pr_file_count files changed (+$pr_additions / -$pr_deletions lines)"
    } > "$BODY_FILE"

    TMP_FILES+=("$BODY_FILE")
}

#######################################
# extract_h2_section: Extract an H2 section from markdown text
#
# Description:
#   Extracts a section starting at a specific H2 heading and ending
#   before the next H2 heading. Handles CRLF line endings.
#
# Arguments:
#   $1 - Markdown text
#   $2 - H2 heading text (for example: "## Changes")
#
# Returns:
#   Outputs the matched section or empty output if not found
#
# Usage:
#   section=$(extract_h2_section "$markdown" "## Changes")
#
#######################################
function extract_h2_section {
    local markdown_text="$1"
    local heading="$2"

    echo "$markdown_text" | awk -v target_heading="$heading" '
        {
            line = $0
            sub(/\r$/, "", line)
        }
        line == target_heading {
            in_section = 1
            print line
            next
        }
        in_section == 1 && line ~ /^##[[:space:]]+/ {
            exit
        }
        in_section == 1 {
            print line
        }
    '
}

#######################################
# extract_overview_template_body: Extract template body under # Overview
#
# Description:
#   Extracts all lines after '# Overview' until the first H2 heading.
#   Used to preserve guidance comments from PULL_REQUEST_TEMPLATE.md.
#
# Arguments:
#   $1 - Template markdown text
#
# Returns:
#   Outputs extracted body text
#
# Usage:
#   body=$(extract_overview_template_body "$template_body")
#
#######################################
function extract_overview_template_body {
    local markdown_text="$1"

    echo "$markdown_text" | awk '
        {
            line = $0
            sub(/\r$/, "", line)
        }
        line == "# Overview" {
            in_overview = 1
            next
        }
        in_overview == 1 && line ~ /^##[[:space:]]+/ {
            exit
        }
        in_overview == 1 {
            print line
        }
    '
}

#######################################
# section_body_without_heading: Remove first heading line from section
#
# Description:
#   Removes the first line from section text and keeps remaining content.
#
# Arguments:
#   $1 - Section markdown text
#
# Returns:
#   Outputs section body without heading
#
# Usage:
#   body=$(section_body_without_heading "$section")
#
#######################################
function section_body_without_heading {
    local section_text="$1"

    echo "$section_text" | awk '
        NR == 1 { next }
        {
            line = $0
            sub(/\r$/, "", line)
            print line
        }
    '
}

#######################################
# section_has_visible_content: Check if section has non-comment content
#
# Description:
#   Returns success when a section contains visible markdown content
#   other than heading, blank lines, or HTML comments.
#
# Arguments:
#   $1 - Section markdown text
#
# Returns:
#   0 if visible content exists, 1 otherwise
#
# Usage:
#   if section_has_visible_content "$section"; then
#       echo "has visible content"
#   fi
#
#######################################
function section_has_visible_content {
    local section_text="$1"

    echo "$section_text" | awk '
        BEGIN { in_comment = 0; found = 0 }
        NR == 1 { next }
        {
            line = $0
            sub(/\r$/, "", line)

            if (line ~ /^<!--[[:space:]]*$/) {
                in_comment = 1
                next
            }

            if (in_comment == 1 && line ~ /-->[[:space:]]*$/) {
                in_comment = 0
                next
            }

            if (in_comment == 1) {
                next
            }

            if (line ~ /^[[:space:]]*$/) {
                next
            }

            found = 1
            exit
        }
        END {
            if (found == 1) {
                exit 0
            }
            exit 1
        }
    '
}

#######################################
# build_fallback_section: Build deterministic fallback section content
#
# Description:
#   Returns the template section unchanged for empty sections.
#   Semantic completion is handled by a separate AI refinement step.
#
# Arguments:
#   $1 - H2 heading text (for example: "## Testing")
#   $2 - Template section markdown text
#
# Returns:
#   Outputs section markdown
#
# Usage:
#   fallback=$(build_fallback_section "## Testing" "$template_section")
#
#######################################
function build_fallback_section {
    local heading="$1"
    local template_section="$2"

    # Keep the interface stable while preserving template structure.
    printf '%s\n' "$template_section"
}

#######################################
# update_pr_body: Update PR Body sections (## Overview, ## Changes)
#
# Description:
#   Updates PR Body, replacing ## Overview and ## Changes sections with auto-generated content.
#   Preserves other template sections (Related Issues, Testing, Type of Change, etc.).
#   Uses `gh pr edit` to update the PR directly.
#
#   Generation is idempotent: multiple executions produce identical results.
#
# Arguments:
#   None
#
# Global Variables:
#   PR_NUMBER - GitHub PR number
#   REPOSITORY - Repository in owner/repo format
#   BODY_FILE - Path to generated body sections
#   DRY_RUN - Enable dry-run mode flag
#
# Returns:
#   None (updates PR or exits with error)
#
# Usage:
#   update_pr_body
#
#######################################
function update_pr_body {
    local current_body
    local generated_body
    local generated_overview
    local generated_changes
    local generated_overview_body
    local generated_changes_body
    local template_file
    local template_body
    local template_overview_body
    local template_changes_section
    local template_changes_body
    local new_body
    local heading
    local section
    local current_section
    local template_section

    log "INFO" "Fetching current PR body"

    # Fetch current PR body
    current_body=$(gh pr view "$PR_NUMBER" --repo "$REPOSITORY" --json body --jq '.body // ""')

    log "INFO" "Rebuilding PR body from PULL_REQUEST_TEMPLATE.md"

    generated_body=$(cat "$BODY_FILE")
    generated_overview=$(extract_h2_section "$generated_body" "## Overview")
    generated_changes=$(extract_h2_section "$generated_body" "## Changes")

    if [[ -z "${generated_overview//[[:space:]]/}" ]]; then
        error_exit "Generated body is missing ## Overview section"
    fi

    if [[ -z "${generated_changes//[[:space:]]/}" ]]; then
        error_exit "Generated body is missing ## Changes section"
    fi

    template_file="$(git rev-parse --show-toplevel)/.github/PULL_REQUEST_TEMPLATE.md"
    if [[ ! -f "$template_file" ]]; then
        error_exit "Template file not found: $template_file"
    fi

    template_body=$(cat "$template_file")

    # Preserve template guidance comments for generated sections.
    template_overview_body=$(extract_overview_template_body "$template_body")
    template_changes_section=$(extract_h2_section "$template_body" "## Changes")
    template_changes_body=$(section_body_without_heading "$template_changes_section")

    generated_overview_body=$(section_body_without_heading "$generated_overview")
    generated_changes_body=$(section_body_without_heading "$generated_changes")

    generated_overview="## Overview"
    if [[ -n "${template_overview_body//[[:space:]]/}" ]]; then
        generated_overview+=$'\n\n'
        generated_overview+="$template_overview_body"
    fi
    if [[ -n "${generated_overview_body//[[:space:]]/}" ]]; then
        generated_overview+=$'\n\n'
        generated_overview+="$generated_overview_body"
    fi

    generated_changes="## Changes"
    if [[ -n "${template_changes_body//[[:space:]]/}" ]]; then
        generated_changes+=$'\n\n'
        generated_changes+="$template_changes_body"
    fi
    if [[ -n "${generated_changes_body//[[:space:]]/}" ]]; then
        generated_changes+=$'\n\n'
        generated_changes+="$generated_changes_body"
    fi

    # Always place auto-generated Overview first.
    new_body="$generated_overview"

    # Rebuild all template H2 sections in template order.
    while IFS= read -r heading; do
        section=""

        if [[ "$heading" == "## Changes" ]]; then
            section="$generated_changes"
        else
            current_section=$(extract_h2_section "$current_body" "$heading")

            if [[ -n "${current_section//[[:space:]]/}" ]] && section_has_visible_content "$current_section"; then
                section="$current_section"
            else
                template_section=$(extract_h2_section "$template_body" "$heading")
                section=$(build_fallback_section "$heading" "$template_section")
            fi
        fi

        if [[ -n "${section//[[:space:]]/}" ]]; then
            new_body+=$'\n\n'
            new_body+="$section"
        fi
    done < <(
        echo "$template_body" | awk '
            {
                line = $0
                sub(/\r$/, "", line)
            }
            line ~ /^##[[:space:]]+/ {
                print line
            }
        '
    )

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY-RUN MODE"
        log "INFO" "Would update PR #$PR_NUMBER body"
        log "INFO" ""
        log "INFO" "New body:"
        log "INFO" "---"
        echo "$new_body" >&2
        log "INFO" "---"
    else
        log "INFO" "Updating PR #$PR_NUMBER body"

        # Use gh pr edit to update body
        gh pr edit "$PR_NUMBER" \
            --repo "$REPOSITORY" \
            --body "$new_body" || error_exit "Failed to update PR body"

        log "INFO" "✅ PR body updated successfully"
    fi
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables accordingly
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   PR_NUMBER - GitHub PR number
#   REPOSITORY - Repository in owner/repo format
#   DRY_RUN - Enable dry-run mode
#
# Returns:
#   None (sets global variables, exits on error)
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
            --overview-file)
                OVERVIEW_FILE="$2"
                shift 2
                ;;
            --verbose)
                export SCRIPT_VERBOSE=1
                shift
                ;;
            --dry-run)
                export DRY_RUN="true"
                shift
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

    # Validate required arguments
    if [[ -z "$PR_NUMBER" ]]; then
        error_exit "PR_NUMBER is required"
    fi
}

#######################################
# main: Main process
#
# Description:
#   Main function to execute the PR Body update workflow.
#   Analyzes PR changes and updates PR Body sections (## Overview, ## Changes)
#   with auto-generated content based on PULL_REQUEST_TEMPLATE.md structure.
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   PR_NUMBER - GitHub PR number
#   REPOSITORY - Repository in owner/repo format (owner/repo)
#   DRY_RUN - Enable dry-run mode flag
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # Auto-detect repository if not provided
    if [[ -z "$REPOSITORY" ]]; then
        log "DEBUG" "Auto-detecting repository from git remote"
        if ! REPOSITORY=$(get_repository_from_git); then
            error_exit "Could not determine repository. Use --repo OWNER/REPO"
        fi
        log "INFO" "Repository: $REPOSITORY"
    fi

    # Validate prerequisites
    validate_dependencies "gh" "jq"

    # Verify PR exists
    validate_pr_exists

    # Generate body sections
    generate_body_sections

    # Update PR Body
    update_pr_body

    if [[ "$DRY_RUN" != "true" ]]; then
        log "INFO" "✅ PR Body updated successfully"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
