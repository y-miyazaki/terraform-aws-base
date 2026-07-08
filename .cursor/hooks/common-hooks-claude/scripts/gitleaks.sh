#!/bin/bash
#######################################
# Description: Hook for gitleaks.
#              Scans changed files for secrets and reports failures
#              in the appropriate format for the active AI agent.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Call report_failure on scan failure (agent-aware error signal)
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
# get_changed_files: Collect changed files from git
#
# Arguments:
#   None
#
# Returns:
#   Newline-separated unique file list to stdout
#######################################
function get_changed_files {
    {
        git diff --name-only --diff-filter=ACMR 2> /dev/null || true
        git diff --cached --name-only --diff-filter=ACMR 2> /dev/null || true
        git ls-files --others --exclude-standard 2> /dev/null || true
    } | awk 'NF' \
        | grep -v -E '^(\.agents/|\.cursor/|\.claude/|\.kiro/|\.vscode/|apm_modules/)' \
        | sort -u
}

#######################################
# report_failure: Emit error in the format the current agent expects, then exit.
#
# Arguments:
#   $1 - reason: Human-readable description of what failed
#
# Returns:
#   Does not return. Exits with 0 (JSON block) or 2 (stderr).
#######################################
function report_failure {
    local reason="$1"
    local agent=""
    local hook_event=""

    if [[ -n $HOOK_STDIN_DATA ]]; then
        if echo "$HOOK_STDIN_DATA" | jq -e ".terminationReason" > /dev/null 2>&1; then
            agent="antigravity"
        elif echo "$HOOK_STDIN_DATA" | jq -e ".toolCall" > /dev/null 2>&1; then
            agent="antigravity"
        elif echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)
            if echo "$hook_event" | grep -qE '^(Stop|PostToolUse|PreToolUse)$'; then
                agent="claude_code"
            elif echo "$hook_event" | grep -qE '^(stop|postToolUse|preToolUse|agentSpawn|userPromptSubmit)$'; then
                agent="kiro"
            elif echo "$hook_event" | grep -qE '^(afterFileEdit|beforeShellExecution|beforeMCPExecution|beforeReadFile|stop)$'; then
                agent="cursor"
            else
                agent="claude_code"
            fi
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
        elif echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active") or has("tool_use_id")' > /dev/null 2>&1; then
            agent="vscode"
            if echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active")' > /dev/null 2>&1; then
                hook_event="Stop"
            elif echo "$HOOK_STDIN_DATA" | jq -e 'has("tool_use_id")' > /dev/null 2>&1; then
                hook_event="PostToolUse"
            fi
        fi
    fi

    if [[ -z $agent && -n ${GITHUB_COPILOT_API_TOKEN:-} ]]; then
        agent="copilot"
    fi

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
            echo "$reason" >&2
            exit 2
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
#   Runs gitleaks on changed files.
#   Calls report_failure if secrets are found.
#
# Arguments:
#   None
#
# Returns:
#   0 on success or skip
#######################################
function main {
    command -v jq > /dev/null 2>&1 || exit 0
    command -v gitleaks > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    local files=()
    mapfile -t files < <(get_changed_files)

    if ((${#files[@]} == 0)); then
        exit 0
    fi

    local config_arg=""
    if [[ -f ".gitleaks.toml" ]]; then
        config_arg="--config=.gitleaks.toml"
    fi

    local scan_dir=""
    scan_dir=$(mktemp -d) || exit 0
    # shellcheck disable=SC2064
    trap "rm -rf '${scan_dir}'" EXIT

    local file=""
    for file in "${files[@]}"; do
        [[ -f $file ]] || continue
        mkdir -p "${scan_dir}/$(dirname "$file")"
        cp "$file" "${scan_dir}/${file}"
    done

    local result=""
    # shellcheck disable=SC2086
    if ! result=$(gitleaks detect --no-git $config_arg --source "$scan_dir" 2>&1); then
        report_failure "gitleaks found potential secrets in changed files:
${result}"
    fi
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
