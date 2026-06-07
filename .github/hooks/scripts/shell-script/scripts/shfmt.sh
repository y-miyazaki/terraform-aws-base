#!/bin/bash
#######################################
# Description: Hook for shfmt.
#              Formats changed shell scripts and reports failures
#              in the appropriate format for the active AI agent.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Call report_failure on format failure (agent-aware error signal)
#   - Supports Kiro CLI, Claude Code, Copilot CLI, Cursor, Antigravity, VS Code
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for reliable relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Capture stdin (hook event JSON) for agent detection.
# Pipe is consumed once; must be read before any other stdin operation.
HOOK_STDIN_DATA=""
if [[ ! -t 0 ]]; then
    HOOK_STDIN_DATA=$(cat)
fi

#######################################
# get_changed_files: Collect changed shell script files from git
#
# Description:
#   Gathers modified/added/untracked shell scripts from git.
#   Each git command is guarded with || true to prevent pipefail
#   from terminating the script.
#
# Arguments:
#   None
#
# Returns:
#   Newline-separated unique file list to stdout
#
# Usage:
#   mapfile -t files < <(get_changed_files)
#
#######################################
function get_changed_files {
    {
        git diff --name-only --diff-filter=ACMR -- '*.sh' 2> /dev/null || true
        git diff --cached --name-only --diff-filter=ACMR -- '*.sh' 2> /dev/null || true
        git ls-files --others --exclude-standard -- '*.sh' 2> /dev/null || true
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
#     - Cursor/unknown: exit 2 + stderr
#
# Arguments:
#   $1 - reason: Human-readable description of what failed and how to fix it
#
# Returns:
#   Does not return. Exits with 0 (JSON block) or 2 (stderr).
#
# Usage:
#   report_failure "shfmt found formatting issues: ..."
#
#######################################
function report_failure {
    local reason="$1"
    local agent=""
    local hook_event=""

    # Step 1: Detect agent (agent-first strategy)
    if [[ -n "$HOOK_STDIN_DATA" ]]; then
        # 1. Antigravity (highest priority - unique fields)
        if echo "$HOOK_STDIN_DATA" | jq -e ".terminationReason" > /dev/null 2>&1; then
            agent="antigravity"
        elif echo "$HOOK_STDIN_DATA" | jq -e ".toolCall" > /dev/null 2>&1; then
            agent="antigravity"

        # 2. VS Code (stop_hook_active field existence is VS Code-specific)
        elif echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active") or has("tool_use_id")' > /dev/null 2>&1; then
            agent="vscode"
            if echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
                hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)
            elif echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active")' > /dev/null 2>&1; then
                hook_event="Stop"
            elif echo "$HOOK_STDIN_DATA" | jq -e 'has("tool_use_id")' > /dev/null 2>&1; then
                hook_event="PostToolUse"
            fi

        # 3. Copilot CLI (env var or Copilot-unique fields)
        elif [[ -n "${GITHUB_COPILOT_API_TOKEN:-}" ]] \
            || echo "$HOOK_STDIN_DATA" | jq -e '.transcriptPath // .stopReason // .stop_reason // .toolResult // .tool_result' > /dev/null 2>&1; then
            agent="copilot"
            if echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
                hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)
            elif echo "$HOOK_STDIN_DATA" | jq -e ".stopReason" > /dev/null 2>&1; then
                hook_event="agentStop"
            elif echo "$HOOK_STDIN_DATA" | jq -e ".toolResult" > /dev/null 2>&1; then
                hook_event="postToolUse"
            elif echo "$HOOK_STDIN_DATA" | jq -e ".toolName" > /dev/null 2>&1; then
                hook_event="preToolUse"
            fi

        # 4. Kiro CLI (camelCase hook_event_name with known values)
        elif echo "$HOOK_STDIN_DATA" | jq -e '.hook_event_name' > /dev/null 2>&1 \
            && echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null | grep -qE '^(stop|postToolUse|preToolUse|agentSpawn|userPromptSubmit)$'; then
            agent="kiro"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)

        # 5. Claude Code (remaining PascalCase hook_event_name)
        elif echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
            agent="claude_code"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)
        fi
    fi

    # Final fallback: env var check
    if [[ -z "$agent" && -n "${GITHUB_COPILOT_API_TOKEN:-}" ]]; then
        agent="copilot"
    fi

    # Step 2: Build response per agent spec
    case "$agent" in
        kiro)
            if [[ "$hook_event" == "stop" ]]; then
                jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        claude_code)
            if [[ "$hook_event" == "Stop" ]]; then
                jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
                exit 0
            elif [[ "$hook_event" == "PostToolUse" ]]; then
                jq -n --arg ctx "$reason" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}'
                exit 0
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        vscode)
            if [[ "$hook_event" == "Stop" ]]; then
                jq -n --arg reason "$reason" '{hookSpecificOutput: {hookEventName: "Stop", decision: "block", reason: $reason}}'
                exit 0
            elif [[ "$hook_event" == "PostToolUse" ]]; then
                jq -n --arg reason "$reason" '{decision: "block", reason: $reason, hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $reason}}'
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
        antigravity)
            jq -n --arg reason "$reason" '{decision: "continue", reason: $reason}'
            exit 0
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
#   Runs shfmt on changed shell scripts.
#   Calls report_failure if formatting issues are found.
#
# Arguments:
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
    command -v shfmt > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    local files=()
    mapfile -t files < <(get_changed_files)

    if ((${#files[@]} == 0)); then
        exit 0
    fi

    local result
    result=$(shfmt -w -i 4 -ci -bn -sr "${files[@]}" 2>&1) || report_failure "shfmt found formatting issues in shell scripts:
${result}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
