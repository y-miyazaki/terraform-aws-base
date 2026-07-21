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
#   - Call report_failure on lint failure (agent-aware error signal)
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
# Arguments:
#   None
#
# Globals:
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
# Arguments:
#   $1 - reason: Human-readable description of what failed and how to fix it
#
# Globals:
#   None
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

    # Final fallback:    # Final fallback: env var check
    if [[ -z $agent && -n ${GITHUB_COPILOT_API_TOKEN:-} ]]; then
        agent="copilot"
    fi

    # Step 2: Build response per agent spec (A-Z order)
    case "$agent" in
        antigravity)
            jq -n --arg reason "$reason" '{decision: "continue", reason: $reason}'
            exit 0
            ;;
        claude_code)
            if [[ $hook_event == "Stop" ]]; then
                jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
                exit 0
            elif [[ $hook_event == "PostToolUse" ]]; then
                jq -n --arg ctx "$reason" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        copilot)
            case "$hook_event" in
                Stop | agentStop)
                    jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
                    exit 0
                    ;;
                PostToolUse | postToolUse)
                    jq -n --arg ctx "$reason" '{additionalContext: $ctx}'
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
                jq -n --arg reason "$reason" '{followup_message: $reason}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        kiro)
            if [[ $hook_event == "stop" ]]; then
                jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        vscode)
            if [[ $hook_event == "Stop" ]]; then
                jq -n --arg reason "$reason" '{hookSpecificOutput: {hookEventName: "Stop", decision: "block", reason: $reason}}'
                exit 0
            elif [[ $hook_event == "PostToolUse" ]]; then
                jq -n --arg reason "$reason" '{decision: "block", reason: $reason, hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $reason}}'
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
# Arguments:
#   None
#
# Globals:
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
    result=$(markdownlint-cli2 --fix "${files[@]}" 2>&1) || report_failure "markdownlint-cli2 found issues that --fix could not resolve:
${result}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
