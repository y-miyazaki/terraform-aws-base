#!/bin/bash
#######################################
# Description: Hook for markdownlint-cli2.
#              Lints and fixes changed Markdown files and reports failures
#              in the appropriate format for the active AI agent.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Call report_failure on lint fingerprints or any other non-zero CLI exit
#   - Content sniffing (Summary / error MD) classifies lint vs tool failure only —
#     never treat unknown non-zero exits as success
#   - Supports Kiro CLI, Claude Code, GitHub Copilot, Cursor, Antigravity
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Capture stdin (hook event JSON) for agent detection.
# Pipe is consumed once; must be read before any other stdin operation.
HOOK_STDIN_DATA=""
if [[ ! -t 0 ]]; then
    HOOK_STDIN_DATA=$(cat)
fi

#######################################
# get_changed_files: Collect changed Markdown files from git
#
# Description:
#   Gathers modified/added/untracked Markdown files from git.
#   Each git command is guarded with || true to prevent pipefail
#   from terminating the script.
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Newline-separated unique file list to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   mapfile -t files < <(get_changed_files)
#
#######################################
function get_changed_files {
    {
        git diff --name-only --diff-filter=ACMR -- '*.md' 2> /dev/null || true
        git diff --cached --name-only --diff-filter=ACMR -- '*.md' 2> /dev/null || true
        git ls-files --others --exclude-standard -- '*.md' 2> /dev/null || true
    } | awk 'NF' | sort -u
}

#######################################
# markdownlint_has_issues: Detect lint failures from markdownlint-cli2 output
#
# Globals:
#   None
#
# Arguments:
#   $1 - combined stdout/stderr from markdownlint-cli2
#
# Outputs:
#   None
#
# Returns:
#   0 when issues are reported; 1 otherwise
#######################################
function markdownlint_has_issues {
    local result="$1"
    if [[ $result =~ Summary:\ ([1-9][0-9]*)[[:space:]]issues? ]]; then
        return 0
    fi
    if [[ $result == *" error MD"* ]]; then
        return 0
    fi
    return 1
}

#######################################
# markdownlint_requires_failure_report: Whether the hook must block
#
# Globals:
#   None
#
# Arguments:
#   $1 - combined stdout/stderr from markdownlint-cli2
#   $2 - markdownlint-cli2 exit status
#
# Outputs:
#   None
#
# Returns:
#   0 when the hook should report failure; 1 when the run is clean
#######################################
function markdownlint_requires_failure_report {
    local result="$1"
    local rc="$2"
    if markdownlint_has_issues "$result"; then
        return 0
    fi
    if ((rc != 0)); then
        return 0
    fi
    return 1
}

#######################################
# build_markdownlint_literal_targets: Build :path args for --no-globs
#
# Globals:
#   None
#
# Arguments:
#   $@ - repository-relative Markdown file paths
#
# Outputs:
#   Literal path arguments to stdout (one per line)
#
# Returns:
#   None
#######################################
function build_markdownlint_literal_targets {
    local file
    for file in "$@"; do
        printf ':%s\n' "${file}"
    done
}

#######################################
# truncate_reason_text: Cap reason size for agent responses
#
# Globals:
#   REASON_TRUNCATE_CHARS - optional max characters (default 32768)
#
# Arguments:
#   $1 - text to truncate (printed to stdout)
#
# Outputs:
#   Truncated text to stdout
#
# Returns:
#   None
#######################################
function truncate_reason_text {
    local text="$1"
    local max_chars="${REASON_TRUNCATE_CHARS:-32768}"
    if ((${#text} > max_chars)); then
        printf '%s\n...[truncated]' "${text:0:max_chars}"
    else
        printf '%s' "$text"
    fi
}

#######################################
# emit_json_with_reason: Build hook JSON via stdin (avoids ARG_MAX)
#
# Globals:
#   None
#
# Arguments:
#   $1 - reason text
#   $2 - jq filter using . for the reason value
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   None
#######################################
function emit_json_with_reason {
    local text="$1"
    local jq_filter="$2"
    truncate_reason_text "$text" | jq -Rs "$jq_filter"
}

#######################################
# report_failure: Emit error in the format the current agent expects, then exit.
#
# Description:
#   Identifies the AI agent from HOOK_STDIN_DATA structure, then returns
#   the agent-specific response format:
#     - Kiro CLI: stop → {"decision":"block","reason":"..."}
#     - Claude Code: Stop → {"decision":"block"}, PostToolUse → hookSpecificOutput
#     - GitHub Copilot: agentStop → {"decision":"block"}, postToolUse → additionalContext
#     - Antigravity: Stop → {"decision":"continue","reason":"..."}
#     - Cursor: stop → followup_message, other events → exit 2 + stderr
#     - unknown: exit 2 + stderr
#
# Globals:
#   None
#
# Arguments:
#   $1 - reason: Human-readable description of what failed and how to fix it
#
# Outputs:
#   Writes JSON to stdout or errors to stderr
#
# Returns:
#   Exits with 0 or 2
#
# Usage:
#   report_failure "markdownlint-cli2 found issues: ..."
#
#######################################
function report_failure {
    local reason="$1"
    local agent=""
    local hook_event=""

    # Step 1: Detect agent (agent-first strategy)
    if [[ -n $HOOK_STDIN_DATA ]]; then
        # 1. Antigravity (highest priority - unique fields)
        if echo "$HOOK_STDIN_DATA" | jq -e ".terminationReason" > /dev/null 2>&1; then
            agent="antigravity"
        elif echo "$HOOK_STDIN_DATA" | jq -e ".toolCall" > /dev/null 2>&1; then
            agent="antigravity"

        # 2. Check for hook_event_name first (most reliable discriminator)
        elif echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)

            # Check event name pattern to determine agent type
            if echo "$HOOK_STDIN_DATA" | jq -e '.cursor_version // .generation_id // .workspace_roots' > /dev/null 2>&1; then
                # Cursor stop shares hook_event_name "stop" with Kiro; use Cursor-only stdin fields
                agent="cursor"
            elif echo "$hook_event" | grep -qE '^(afterFileEdit|beforeShellExecution|beforeMCPExecution|beforeReadFile)$'; then
                # camelCase with Cursor-only event names
                agent="cursor"
            elif echo "$hook_event" | grep -qE '^(Stop|PostToolUse|PreToolUse)$'; then
                # PascalCase = Claude Code
                agent="claude_code"
            elif echo "$hook_event" | grep -qE '^(stop|postToolUse|preToolUse|agentSpawn|userPromptSubmit)$'; then
                # camelCase with Kiro values = Kiro
                agent="kiro"
            else
                # Default to Claude Code for unknown PascalCase
                agent="claude_code"
            fi

        # 3. Copilot CLI (env var or Copilot-unique fields, no hook_event_name)
        elif [[ -n ${GITHUB_COPILOT_API_TOKEN:-} ]] \
            || echo "$HOOK_STDIN_DATA" | jq -e '.transcriptPath // .stopReason // .stop_reason // .toolResult // .tool_result' > /dev/null 2>&1; then
            agent="copilot"
            if echo "$HOOK_STDIN_DATA" | jq -e ".stopReason" > /dev/null 2>&1; then
                hook_event="agentStop"
            elif echo "$HOOK_STDIN_DATA" | jq -e ".toolResult" > /dev/null 2>&1; then
                hook_event="postToolUse"
            elif echo "$HOOK_STDIN_DATA" | jq -e ".toolName" > /dev/null 2>&1; then
                hook_event="preToolUse"
            fi

        # 4. VS Code extension (fallback based on vscode-specific fields)
        elif echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active") or has("tool_use_id")' > /dev/null 2>&1; then
            agent="vscode"
            if echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active")' > /dev/null 2>&1; then
                hook_event="Stop"
            elif echo "$HOOK_STDIN_DATA" | jq -e 'has("tool_use_id")' > /dev/null 2>&1; then
                hook_event="PostToolUse"
            fi
        fi
    fi

    # Final fallback: env var check
    if [[ -z $agent && -n ${GITHUB_COPILOT_API_TOKEN:-} ]]; then
        agent="copilot"
    fi

    # Step 2: Build response per agent spec (A-Z order)
    case "$agent" in
        antigravity)
            emit_json_with_reason "$reason" '{decision: "continue", reason: .}'
            exit 0
            ;;
        claude_code)
            if [[ $hook_event == "Stop" ]]; then
                emit_json_with_reason "$reason" '{decision: "block", reason: .}'
                exit 0
            elif [[ $hook_event == "PostToolUse" ]]; then
                emit_json_with_reason "$reason" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        copilot)
            case "$hook_event" in
                Stop | agentStop)
                    emit_json_with_reason "$reason" '{decision: "block", reason: .}'
                    exit 0
                    ;;
                PostToolUse | postToolUse)
                    emit_json_with_reason "$reason" '{additionalContext: .}'
                    exit 0
                    ;;
                *)
                    echo "$reason" >&2
                    exit 2
                    ;;
            esac
            ;;
        cursor)
            if [[ $hook_event == "stop" ]]; then
                emit_json_with_reason "$reason" '{followup_message: .}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        kiro)
            if [[ $hook_event == "stop" ]]; then
                emit_json_with_reason "$reason" '{decision: "block", reason: .}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        vscode)
            if [[ $hook_event == "Stop" ]]; then
                emit_json_with_reason "$reason" '{hookSpecificOutput: {hookEventName: "Stop", decision: "block", reason: .}}'
                exit 0
            elif [[ $hook_event == "PostToolUse" ]]; then
                emit_json_with_reason "$reason" '{decision: "block", reason: ., hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        *)
            echo "$reason" >&2
            exit 2
            ;;
    esac
}

#######################################
# main: Entry point
#
# Description:
#   Runs markdownlint-cli2 --fix on changed Markdown files.
#   Calls report_failure if unfixable issues remain.
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 on success or skip
#
# Usage:
#   main
#
#######################################
function main {
    command -v jq > /dev/null 2>&1 || exit 0
    command -v markdownlint-cli2 > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    local files=()
    mapfile -t files < <(get_changed_files)

    if ((${#files[@]} == 0)); then
        exit 0
    fi

    local result
    local rc=0
    local -a targets=()
    mapfile -t targets < <(build_markdownlint_literal_targets "${files[@]}")

    result=$(markdownlint-cli2 --fix --no-globs "${targets[@]}" 2>&1) || rc=$?

    if markdownlint_requires_failure_report "$result" "$rc"; then
        local failure_detail
        if markdownlint_has_issues "$result"; then
            failure_detail=$(printf '%s\n' "$result" | grep -m 50 -E ' error MD' || true)
            if (($(printf '%s\n' "$result" | grep -cE ' error MD' || true) > 50)); then
                failure_detail+=$'\n...[markdownlint output truncated]'
            fi
            if [[ -z $failure_detail ]]; then
                failure_detail=$(printf '%s\n' "$result" | head -n 50 || true)
            fi
            report_failure "markdownlint-cli2 found issues that --fix could not resolve:
${failure_detail}"
        else
            failure_detail=$(printf '%s\n' "$result" | head -n 50 || true)
            report_failure "markdownlint-cli2 failed (exit ${rc}):
${failure_detail}"
        fi
    fi
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
