#!/bin/bash
#######################################
# Description: Hook for ghalint.
#              Runs ghalint on the repository when workflow files change
#              and reports failures in the appropriate format for the active AI agent.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Call report_failure on policy violation (agent-aware error signal)
#   - Skip (exit 0) once the same working-tree state was reported HOOK_BLOCK_LIMIT times
#     (default 2) in this session; any file change re-runs the tool
#   - Supports Kiro CLI, Claude Code, Copilot CLI, Cursor, Antigravity, VS Code
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
# has_changed_workflows: Check if any workflow files have changed
#
# Description:
#   Returns success if any GitHub Actions workflow files are modified,
#   staged, or untracked. Each git command is guarded with || true to
#   prevent pipefail from terminating the script.
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
#   0 if changed files exist, 1 otherwise
#
# Usage:
#   if has_changed_workflows; then ...
#
#######################################
function has_changed_workflows {
    local path

    while IFS= read -r path; do
        [[ -z ${path} ]] && continue
        [[ -f ${path} ]] || continue
        return 0
    done < <(
        {
            git diff --name-only --diff-filter=ACMR -- .github/workflows/*.yml .github/workflows/*.yaml 2> /dev/null || true
            git diff --cached --name-only --diff-filter=ACMR -- .github/workflows/*.yml .github/workflows/*.yaml 2> /dev/null || true
            git ls-files --others --exclude-standard -- .github/workflows/*.yml .github/workflows/*.yaml 2> /dev/null || true
        } | awk 'NF' | sort -u
    )
    return 1
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
# collapse_reason_for_cursor_display: Flatten multiline hook reasons for Cursor stop UI
#
# Globals:
#   None
#
# Arguments:
#   $1 - reason text
#
# Outputs:
#   Single-line reason on stdout
#
# Returns:
#   None
#
#######################################
function collapse_reason_for_cursor_display {
    local text="$1"
    printf '%s' "$text" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g;s/^[[:space:]]*//;s/[[:space:]]*$//'
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
#   report_failure "ghalint found policy violations: ..."
#
#######################################
function report_failure {
    local reason="$1"
    record_blocked_state
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
        elif echo "$HOOK_STDIN_DATA" | jq -e 'has("cursor_version") or has("generation_id") or has("workspace_roots")' > /dev/null 2>&1; then
            agent="cursor"
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name // "stop"' 2> /dev/null)
        elif echo "$HOOK_STDIN_DATA" | jq -e ".hook_event_name" > /dev/null 2>&1; then
            hook_event=$(echo "$HOOK_STDIN_DATA" | jq -r '.hook_event_name' 2> /dev/null)

            # Check event name pattern to determine agent type
            if echo "$hook_event" | grep -qE '^(afterFileEdit|beforeShellExecution|beforeMCPExecution|beforeReadFile)$'; then
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
    if [[ $agent == "cursor" && $hook_event == "stop" ]]; then
        reason=$(collapse_reason_for_cursor_display "$reason")
    fi

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
# blocked_state_file: Resolve the per-session, per-hook file that stores the blocked state
#
# Globals:
#   HOOK_STDIN_DATA - hook event JSON (session_id / conversation_id / sessionId / conversationId)
#   TMPDIR          - optional base directory (default /tmp)
#
# Arguments:
#   None
#
# Outputs:
#   State file path to stdout
#
# Returns:
#   0 always
#
#######################################
function blocked_state_file {
    local session name
    session=$(printf '%s' "${HOOK_STDIN_DATA:-}" | jq -r '.session_id // .conversation_id // .sessionId // .conversationId // empty' 2> /dev/null || true)
    session=$(printf '%s' "${session:-nosession}" | tr -c 'A-Za-z0-9_-' '_')
    name=$(basename "${BASH_SOURCE[0]}" .sh)
    printf '%s/hook-state-%s/%s__%s\n' "${TMPDIR:-/tmp}" "$(id -u)" "${session:0:64}" "$name"
}

#######################################
# clear_blocked_state: Forget the blocked state after a passing run
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
#   0 always
#
#######################################
function clear_blocked_state {
    rm -f "$(blocked_state_file)" 2> /dev/null || true
}

#######################################
# compute_state_hash: Hash the working-tree change state (tracked diff + untracked content)
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Hex digest to stdout (empty when no hash command is available)
#
# Returns:
#   0 always
#
#######################################
function compute_state_hash {
    local -a hasher
    if command -v sha256sum > /dev/null 2>&1; then
        hasher=(sha256sum)
    elif command -v shasum > /dev/null 2>&1; then
        hasher=(shasum -a 256)
    else
        return 0
    fi

    {
        git diff HEAD 2> /dev/null || true
        git ls-files --others --exclude-standard -z 2> /dev/null | xargs -0 -r "${hasher[@]}" 2> /dev/null || true
    } | "${hasher[@]}" | cut -d' ' -f1
}

#######################################
# is_blocked_state: Check whether the current state was already reported enough times
#
# Globals:
#   HOOK_BLOCK_LIMIT - max reports per unchanged state (default 2)
#   HOOK_STATE_HASH  - state hash captured at hook start
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when the state was reported HOOK_BLOCK_LIMIT times already, 1 otherwise
#
#######################################
function is_blocked_state {
    local current="${HOOK_STATE_HASH:-}"
    [[ -n $current ]] || return 1

    local limit="${HOOK_BLOCK_LIMIT:-2}"
    [[ $limit =~ ^[0-9]+$ ]] || limit=2

    local file saved="" count=0
    file=$(blocked_state_file)
    [[ -f $file ]] || return 1
    read -r saved count < "$file" || true
    [[ $saved == "$current" && ${count:-0} =~ ^[0-9]+$ ]] || return 1
    ((count >= limit))
}

#######################################
# record_blocked_state: Count one more report for the post-run state
#
# Description:
#   Re-hashes after the tool ran so auto-fixes made by the tool itself are included.
#   The count restarts at 1 when the state differs from the stored one.
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
#   0 always
#
#######################################
function record_blocked_state {
    local hash file saved="" count=0
    hash=$(compute_state_hash)
    [[ -n $hash ]] || return 0
    file=$(blocked_state_file)
    if [[ -f $file ]]; then
        read -r saved count < "$file" || true
    fi
    if [[ $saved == "$hash" && ${count:-0} =~ ^[0-9]+$ ]]; then
        count=$((count + 1))
    else
        count=1
    fi
    {
        mkdir -p "$(dirname "$file")" \
            && printf '%s %s\n' "$hash" "$count" > "$file"
    } 2> /dev/null || true
}

#######################################
# main: Entry point
#
# Description:
#   Runs ghalint when workflow files have changed.
#   Calls report_failure if policy violations are found.
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
    command -v ghalint > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    HOOK_STATE_HASH=$(compute_state_hash)
    if is_blocked_state; then
        exit 0
    fi

    has_changed_workflows || exit 0

    local result
    result=$(ghalint run 2>&1) || report_failure "ghalint found policy violations:
${result}"

    clear_blocked_state
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
