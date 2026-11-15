#!/bin/bash
#######################################
# Description: Hook for zizmor.
#              Scans the .github tree when workflows, actions, or dependabot
#              files change (aligned with pre-commit zizmor scope) and reports
#              failures in the appropriate format for the active AI agent.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if tool not found or no changed files (silent skip)
#   - Call report_failure on scan failure (agent-aware error signal)
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
# get_changed_files: Collect changed GitHub Actions inputs from git
#
# Description:
#   Gathers modified/added/untracked YAML under .github/workflows/,
#   .github/actions/, and .github/dependabot.{yml,yaml}.
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
    local path

    while IFS= read -r path; do
        [[ -z ${path} ]] && continue
        [[ -f ${path} ]] || continue
        [[ ${path} =~ \.(yml|yaml)$ ]] || continue
        printf '%s\n' "${path}"
    done < <(
        {
            git diff --name-only --diff-filter=ACMR -- .github/workflows/ .github/actions/ .github/dependabot.yml .github/dependabot.yaml 2> /dev/null || true
            git diff --cached --name-only --diff-filter=ACMR -- .github/workflows/ .github/actions/ .github/dependabot.yml .github/dependabot.yaml 2> /dev/null || true
            git ls-files --others --exclude-standard -- .github/workflows/ .github/actions/ .github/dependabot.yml .github/dependabot.yaml 2> /dev/null || true
        } | awk 'NF && /\.(yml|yaml)$/' | sort -u
    )
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
#   report_failure "zizmor found security issues: ..."
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
# is_zizmor_online_audit_failure: Detect GitHub API connectivity failures
#
# Description:
#   Returns success when zizmor failed before producing findings because an
#   online audit could not reach the GitHub API (for example impostor-commit).
#
# Globals:
#   None
#
# Arguments:
#   $1 - result: Captured zizmor stdout/stderr
#
# Outputs:
#   None
#
# Returns:
#   0 when the failure looks like an online-audit connectivity issue, 1 otherwise
#
# Usage:
#   is_zizmor_online_audit_failure "$result"
#
#######################################
function is_zizmor_online_audit_failure {
    local result="$1"

    if ! echo "$result" | grep -q 'fatal: no audit was performed'; then
        return 1
    fi

    if echo "$result" | grep -qE 'request error while accessing GitHub API|couldn'\''t list tags for|tcp connect error|Connection timed out|client error \(Connect\)'; then
        return 0
    fi

    return 1
}

#######################################
# has_zizmor_reportable_findings: Detect actionable zizmor output
#
# Description:
#   Returns success when zizmor exited non-zero or printed unsuppressed
#   diagnostics. zizmor may exit 0 while still printing help/error/warning
#   lines (e.g. low severity), matching pre-commit display behavior.
#
# Globals:
#   None
#
# Arguments:
#   $1 - result: Captured zizmor stdout/stderr
#   $2 - exit_code: zizmor exit code
#
# Outputs:
#   None
#
# Returns:
#   0 when findings should be reported, 1 otherwise
#
# Usage:
#   has_zizmor_reportable_findings "$result" "$exit_code"
#
#######################################
function has_zizmor_reportable_findings {
    local result="$1"
    local exit_code="$2"

    if ((exit_code != 0)); then
        return 0
    fi

    if echo "$result" | grep -qE '^(help|error|warning)\['; then
        return 0
    fi

    return 1
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
#   Runs zizmor on .github when workflows, actions, or dependabot files change.
#   Calls report_failure when zizmor reports actionable findings.
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
    command -v zizmor > /dev/null 2>&1 || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || exit 0
    cd "$root" || exit 0

    HOOK_STATE_HASH=$(compute_state_hash)
    if is_blocked_state; then
        exit 0
    fi

    local files=()
    mapfile -t files < <(get_changed_files)

    if ((${#files[@]} == 0)); then
        exit 0
    fi

    local result exit_code zizmor_args=()
    if [[ ${ZIZMOR_OFFLINE:-} == 1 || ${ZIZMOR_OFFLINE:-} == true ]]; then
        zizmor_args+=(--offline)
    elif [[ ${ZIZMOR_NO_ONLINE_AUDITS:-} == 1 || ${ZIZMOR_NO_ONLINE_AUDITS:-} == true ]]; then
        zizmor_args+=(--no-online-audits)
    fi

    set +e
    result=$(zizmor --no-progress "${zizmor_args[@]}" .github 2>&1)
    exit_code=$?
    set -e

    if ((exit_code != 0)) \
        && ((${#zizmor_args[@]} == 0)) \
        && is_zizmor_online_audit_failure "$result"; then
        set +e
        result=$(zizmor --no-progress --no-online-audits .github 2>&1)
        exit_code=$?
        set -e
    fi

    if has_zizmor_reportable_findings "$result" "$exit_code"; then
        report_failure "zizmor found security issues in GitHub Actions workflows or composite actions:
${result}"
    fi

    clear_blocked_state
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
