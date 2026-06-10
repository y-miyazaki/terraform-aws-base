#!/bin/bash
#######################################
# Description: Hook for tflint.
#              Lints and fixes changed Terraform files and reports failures
#              in the appropriate format for the active AI agent.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Call report_failure on lint failure (agent-aware error signal)
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
# get_changed_dirs: Collect unique directories containing changed Terraform files
#
# Description:
#   Gathers modified/added/untracked Terraform files from git and extracts
#   their parent directories. Each git command is guarded with || true to
#   prevent pipefail from terminating the script.
#
# Arguments:
#   None
#
# Returns:
#   Newline-separated unique directory list to stdout
#
# Usage:
#   mapfile -t dirs < <(get_changed_dirs)
#
#######################################
function get_changed_dirs {
    {
        git diff --name-only --diff-filter=ACMR -- '*.tf' '*.tfvars' '*.hcl' 2> /dev/null || true
        git diff --cached --name-only --diff-filter=ACMR -- '*.tf' '*.tfvars' '*.hcl' 2> /dev/null || true
        git ls-files --others --exclude-standard -- '*.tf' '*.tfvars' '*.hcl' 2> /dev/null || true
    } | awk 'NF' | xargs -I{} dirname {} | sort -u
}

#######################################
# report_failure: Emit error in the format the current agent expects, then exit.
#
# Description:
#   Identifies the AI agent from HOOK_STDIN_DATA structure, then returns
#   the agent-specific response format for Stop events.
#
# Arguments:
#   $1 - reason: Human-readable description of what failed and how to fix it
#
# Returns:
#   Does not return. Exits with 0 (JSON block) or 2 (stderr).
#
# Usage:
#   report_failure "tflint found issues: ..."
#
#######################################
function report_failure {
    local reason="$1"
    local agent=""
    local hook_event=""

    # Step 1: Detect agent (agent-first strategy)
    if [[ -n "$HOOK_STDIN_DATA" ]]; then
        if echo "$HOOK_STDIN_DATA" | jq -e ".terminationReason" > /dev/null 2>&1; then
            agent="antigravity"
        elif echo "$HOOK_STDIN_DATA" | jq -e ".toolCall" > /dev/null 2>&1; then
            agent="antigravity"
        elif echo "$HOOK_STDIN_DATA" | jq -e 'has("stop_hook_active") or has("tool_use_id")' > /dev/null 2>&1; then
            agent="vscode"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name // "Stop"' 2> /dev/null)
        elif [[ -n "${GITHUB_COPILOT_API_TOKEN:-}" ]] \
            || echo "$HOOK_STDIN_DATA" | jq -e '.transcriptPath // .stopReason // .stop_reason // .toolResult // .tool_result' > /dev/null 2>&1; then
            agent="copilot"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name // "agentStop"' 2> /dev/null)
        elif echo "$HOOK_STDIN_DATA" | jq -e '.hook_event_name' > /dev/null 2>&1 \
            && echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null | grep -qE '^(stop|postToolUse|preToolUse|agentSpawn|userPromptSubmit)$'; then
            agent="kiro"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)
        elif echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
            agent="claude_code"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)
        fi
    fi

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
            else
                echo "$reason" >&2
                exit 2
            fi
            ;;
        vscode)
            if [[ "$hook_event" == "Stop" ]]; then
                jq -n --arg reason "$reason" '{hookSpecificOutput: {hookEventName: "Stop", decision: "block", reason: $reason}}'
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
#   Runs tflint on each directory containing changed Terraform files.
#   Collects failures and calls report_failure with a summary.
#
#   Config resolution: module-local .tflint.hcl takes priority, falling
#   back to repository root .tflint.hcl. This matches the CI workflow
#   config resolution strategy. pre-commit cannot implement this due to
#   tool constraints and uses root config only.
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
    command -v jq > /dev/null 2>&1 || exit 0
    command -v tflint > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    local dirs=()
    mapfile -t dirs < <(get_changed_dirs)

    if ((${#dirs[@]} == 0)); then
        exit 0
    fi

    local fails=0
    local output=""
    for dir in "${dirs[@]}"; do
        [[ -n "$dir" && -d "$dir" ]] || continue

        local config_arg=""
        if [[ -f "${dir}/.tflint.hcl" ]]; then
            config_arg="--config=${dir}/.tflint.hcl"
        elif [[ -f "${root}/.tflint.hcl" ]]; then
            config_arg="--config=${root}/.tflint.hcl"
        fi

        local -a config_args=()
        if [[ -n "$config_arg" ]]; then
            config_args=("$config_arg")
        fi

        tflint --init --chdir "$dir" "${config_args[@]}" > /dev/null 2>&1 || true
        local result
        result=$(tflint --fix --chdir "$dir" "${config_args[@]}" 2>&1) || {
            fails=$((fails + 1))
            output+="${result}"$'\n'
        }
    done

    if [[ "$fails" -gt 0 ]]; then
        report_failure "tflint found issues in Terraform code:
${output}"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
