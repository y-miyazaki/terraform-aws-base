#!/bin/bash
#######################################
# Description: Stop hook that blocks finishing until a code review ran on the changes.
#              Reports in the format of the active AI agent (same helpers as the other hooks).
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives hook event JSON via stdin.
#
# Design Rules:
#   - Change detection uses git (tracked diff, staged, untracked), minus agent-managed paths:
#     chat-only turns and Bash-made edits are both handled; no edit log is needed.
#   - The working-tree state is a hash of the whole git diff and the untracked files (compute_state_hash;
#     the ignore list only trims the file list of the message), saved per session when the
#     gate asks for a review. A different hash than the saved one asks for a review; the same hash
#     means the state was already reported, so the gate passes (HOOK_BLOCK_LIMIT, default 1 here).
#   - The block reason lets the agent decide: it finishes without a second review when the diff was
#     already reviewed in the session (for example by an automatic review tool), and it picks the review
#     depth and, without REVIEW_GATE_MODEL, a reviewer model different from the session's.
#   - Review requests per session are bounded (REVIEW_GATE_MAX_PROMPTS) so review -> fix -> review ends.
#   - The agent is detected from the event JSON (detect_agent) only to pick the default review command.
#   - Fail open: any error, a missing jq/git or REVIEW_GATE_DISABLED=1
#     exits 0 without blocking, so a broken hook never traps the agent.
#   - Supports Kiro CLI, Claude Code, Copilot CLI, Cursor, Antigravity, VS Code
#
# Environment:
#   REVIEW_GATE_DISABLED   - 1 disables the gate
#   REVIEW_GATE_MAX_PROMPTS - review requests per session (default 3)
#   REVIEW_GATE_COMMAND    - review command named in the block reason (default per agent: /code-review for
#                            Claude Code, /review for Copilot CLI and Cursor)
#   REVIEW_GATE_MODEL      - model the review must use, named in the block reason (default empty: the
#                            reason asks for a model different from the session's and leaves the choice,
#                            and the review depth, to the agent)
#   REVIEW_GATE_MODEL_<AGENT> - the same per agent; wins over REVIEW_GATE_MODEL, and an empty value
#                            (set but empty) turns the model note off for that agent. Advisory only: the
#                            reason asks the agent to use the model, the gate does not verify it
#   REVIEW_GATE_COMMAND_<AGENT> - the same per agent (CLAUDE, COPILOT, CURSOR); wins over REVIEW_GATE_COMMAND;
#                            an empty value falls back to the shared or default command
#######################################

set -Eeuo pipefail

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
# get_changed_files: Collect changed files from git
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
#######################################
function get_changed_files {
    local path

    while IFS= read -r path; do
        [[ -z ${path} ]] && continue
        [[ -f ${path} ]] || continue
        printf '%s\n' "${path}"
    done < <(
        {
            git diff --name-only --diff-filter=ACMR 2> /dev/null || true
            git diff --cached --name-only --diff-filter=ACMR 2> /dev/null || true
            git ls-files --others --exclude-standard 2> /dev/null || true
        } | awk 'NF' \
            | grep -v -E '^(\.agents/|\.cursor/|\.claude/|\.kiro/|\.vscode/|apm_modules/)' \
            | sort -u
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
# Globals:
#   None
#
# Arguments:
#   $1 - reason: Human-readable description of what failed
#
# Outputs:
#   Does not return. Exits with 0 (JSON block) or 2 (stderr).
#
# Returns:
#   0 on success
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
# clear_blocked_state: Forget the blocked state (hash and session counts) after a passing run
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
# is_blocked_state: Decide from the saved state whether the hook should let the agent stop
#
# Description:
#   One shared decision, controlled by variables the hook sets in main (all optional):
#   the same state reported HOOK_BLOCK_LIMIT times, or the session reported HOOK_SESSION_LIMIT
#   times in total. stop_hook_active is not consulted: a changed state is asked about again.
#   After the session limit the hook no longer runs its check unless it clears the state earlier
#   (a hook with a cheap clean-tree test, such as review_gate.sh, does).
#
# Globals:
#   HOOK_BLOCK_LIMIT - max reports per unchanged state (default 2)
#   HOOK_SESSION_LIMIT - max reports per session across changing states (default 0 = unlimited)
#   HOOK_STATE_HASH - state hash captured at hook start
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when the hook should pass (limit reached), 1 when it should report
#
#######################################
function is_blocked_state {
    local current="${HOOK_STATE_HASH:-}"
    [[ -n $current ]] || return 1

    local limit="${HOOK_BLOCK_LIMIT:-2}" session_limit="${HOOK_SESSION_LIMIT:-0}"
    [[ $limit =~ ^[0-9]+$ ]] || limit=2
    [[ $session_limit =~ ^[0-9]+$ ]] || session_limit=0

    local file saved="" count=0 total=0
    file=$(blocked_state_file)
    [[ -f $file ]] || return 1
    read -r saved count total < "$file" || true
    [[ ${count:-0} =~ ^[0-9]+$ ]] || count=0
    [[ ${total:-0} =~ ^[0-9]+$ ]] || total=0
    if ((session_limit > 0 && total >= session_limit)); then
        return 0
    fi
    [[ $saved == "$current" ]] || return 1
    ((count >= limit))
}

#######################################
# record_blocked_state: Count one more report for the post-run state
#
# Description:
#   Re-hashes after the tool ran so auto-fixes made by the tool itself are included.
#   The per-state count restarts at 1 when the state differs from the stored one;
#   the session total keeps counting until clear_blocked_state.
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
    local hash file saved="" count=0 total=0
    hash=$(compute_state_hash)
    [[ -n $hash ]] || return 0
    file=$(blocked_state_file)
    if [[ -f $file ]]; then
        read -r saved count total < "$file" || true
    fi
    [[ ${count:-0} =~ ^[0-9]+$ ]] || count=0
    [[ ${total:-0} =~ ^[0-9]+$ ]] || total=0
    if [[ $saved == "$hash" ]]; then
        count=$((count + 1))
    else
        count=1
    fi
    total=$((total + 1))
    {
        mkdir -p "$(dirname "$file")" \
            && printf '%s %s %s\n' "$hash" "$count" "$total" > "$file"
    } 2> /dev/null || true
}

# Agent-specific strings: replace these to adapt the gate to another agent or review command.

#######################################
# detect_agent: Name the agent that sent the hook event
#
# Globals:
#   HOOK_STDIN_DATA - hook event JSON
#
# Arguments:
#   None
#
# Outputs:
#   claude, copilot, cursor or unknown to stdout
#
# Returns:
#   0 always
#
#######################################
function detect_agent {
    if printf '%s' "$HOOK_STDIN_DATA" | jq -e 'has("cursor_version") or has("generation_id") or has("workspace_roots")' > /dev/null 2>&1; then
        echo cursor
    elif printf '%s' "$HOOK_STDIN_DATA" | jq -e 'has("transcriptPath") or has("stopReason")' > /dev/null 2>&1; then
        echo copilot
    elif printf '%s' "$HOOK_STDIN_DATA" | jq -e 'has("transcript_path")' > /dev/null 2>&1; then
        echo claude
    else
        echo unknown
    fi
}

# Agent-managed and generated paths that never need a review (single owner of the ignore list);
# hand-edited files such as .claude/settings.json still count.
REVIEW_IGNORE_PATHS='^(\.agents/|\.codex/|\.kiro/|\.vscode/|apm_modules/|apm\.lock\.yaml$|\.github/hooks/|\.claude/(rules|skills|agents|hooks|commands|tmp)/|\.cursor/(rules|skills|agents|hooks)/)'

#######################################
# get_review_files: Changed files that need a review
#
# Globals:
#   REVIEW_IGNORE_PATHS - ERE of paths to skip
#
# Arguments:
#   None
#
# Outputs:
#   Newline-separated unique existing file paths to stdout
#
# Returns:
#   0 always
#
#######################################
function get_review_files {
    local path
    {
        git diff --name-only --diff-filter=ACMR HEAD 2> /dev/null || true
        git ls-files --others --exclude-standard 2> /dev/null || true
    } | awk 'NF' | grep -v -E "$REVIEW_IGNORE_PATHS" | sort -u | while IFS= read -r path; do
        [[ -f $path ]] && printf '%s\n' "$path"
    done || true
}

#######################################
# set_review_options: Choose the review command and model for the detected agent
#
# Description:
#   Add a case branch to give another agent its own default review command.
#
# Globals:
#   REVIEW_COMMAND - set here (review command named in the block reason)
#   REVIEW_MODEL - set here (model the review should use; empty = session model)
#
# Arguments:
#   $1 - agent name from detect_agent
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
#######################################
function set_review_options {
    local default_command="/code-review"
    case "$1" in
        copilot | cursor) default_command="/review" ;;
        *) ;;
    esac
    # Per-agent override first (REVIEW_GATE_COMMAND_CLAUDE, _COPILOT, _CURSOR), then the global one
    local agent_var="REVIEW_GATE_COMMAND_${1^^}"
    REVIEW_COMMAND="${!agent_var:-${REVIEW_GATE_COMMAND:-$default_command}}"
    # Optional model for the review; empty keeps the session (base) model
    local model_var="REVIEW_GATE_MODEL_${1^^}"
    REVIEW_MODEL="${!model_var-${REVIEW_GATE_MODEL:-}}"
}

#######################################
# main: Entry point
#
# Globals:
#   HOOK_STDIN_DATA - hook event JSON
#   REVIEW_GATE_DISABLED - 1 disables the gate
#   REVIEW_GATE_MAX_PROMPTS - review requests per session (default 3)
#
# Arguments:
#   None
#
# Outputs:
#   Block JSON through report_failure when the working-tree state has not been reported yet
#
# Returns:
#   0 on pass or skip
#
#######################################
function main {
    trap 'exit 0' ERR
    [[ ${REVIEW_GATE_DISABLED:-0} == "1" ]] && exit 0
    command -v jq > /dev/null 2>&1 || exit 0
    command -v git > /dev/null 2>&1 || exit 0
    git rev-parse --is-inside-work-tree > /dev/null 2>&1 || exit 0
    [[ -n $HOOK_STDIN_DATA ]] || exit 0

    local files=()
    mapfile -t files < <(get_review_files)
    if ((${#files[@]} == 0)); then
        clear_blocked_state
        exit 0
    fi

    # Shared loop guard (is_blocked_state): a state that was already reported is not reported again,
    # a changed state asks for a review again, review requests per session are bounded (reset by a
    # clean tree); stop_hook_active is not consulted, so fixes made after a review are asked about again
    local max="${REVIEW_GATE_MAX_PROMPTS:-3}"
    [[ $max =~ ^[1-9][0-9]*$ ]] || max=3
    HOOK_BLOCK_LIMIT="${HOOK_BLOCK_LIMIT:-1}"
    HOOK_SESSION_LIMIT="$max"
    HOOK_STATE_HASH=$(compute_state_hash)
    # No hash tool: a reported state cannot be recognized, so fail open instead of re-asking every stop
    [[ -n $HOOK_STATE_HASH ]] || exit 0
    if is_blocked_state; then
        exit 0
    fi

    set_review_options "$(detect_agent)"
    local model_note=" Prefer a reviewer on a different model than this session's (for example a review subagent) when one is available; you choose the model."
    [[ -z $REVIEW_MODEL ]] || model_note=" Run the review with the model ${REVIEW_MODEL} (use the agent's model option for the review command or its subagent)."
    model_note+=" You also choose the review depth: light for a small follow-up to a diff already reviewed in this session, deeper for new logic or risky changes."
    report_failure "${#files[@]} file(s) changed since the last review request in this session. If this exact diff was already reviewed in this session (by any review tool or skill), say so and finish without reviewing again. Otherwise run ${REVIEW_COMMAND} on the diff, fix the in-scope findings, then report the review and its dispositions.${model_note} Changed: $(printf '%s ' "${files[@]:0:10}")"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
