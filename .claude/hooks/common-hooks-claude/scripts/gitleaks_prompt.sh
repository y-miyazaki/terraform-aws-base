#!/bin/bash
#######################################
# Description: Hook for gitleaks on user prompts.
#              Scans the submitted prompt for secrets before the agent sees it.
#
# Usage: Called by apm hook runner (not invoked directly).
#        Receives the prompt-submit event JSON via stdin.
#
# Design Rules:
#   - Exit 0 if jq/gitleaks is missing, the prompt is empty, or gitleaks itself fails (fail-open)
#   - Never echo the matched value: only rule IDs and line numbers are reported
#   - Block where the agent supports it, otherwise warn:
#       Claude Code (UserPromptSubmit)  : exit 2 + stderr (prompt never reaches the model)
#       Cursor (beforeSubmitPrompt)     : {"continue": false, "user_message": ...}
#       Copilot (userPromptSubmitted)   : stderr + exit 2 (warning only; config-file hooks cannot block)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 077
export LC_ALL=C.UTF-8

# gitleaks exit code that means "leaks found" (distinct from tool errors)
readonly LEAKS_EXIT_CODE=42

#######################################
# detect_agent: Identify the calling agent from the event JSON
#
# Globals:
#   GITHUB_COPILOT_API_TOKEN - optional, marks a Copilot runtime
#
# Arguments:
#   $1 - event JSON
#
# Outputs:
#   claude | cursor | copilot | unknown to stdout
#
# Returns:
#   0 always
#######################################
function detect_agent {
    local json="$1"
    if jq -e 'has("cursor_version") or .hook_event_name == "beforeSubmitPrompt"' <<< "$json" > /dev/null 2>&1; then
        echo "cursor"
    elif jq -e 'has("sessionId")' <<< "$json" > /dev/null 2>&1; then
        echo "copilot"
    elif [[ -n ${GITHUB_COPILOT_API_TOKEN:-} ]]; then
        echo "copilot"
    elif jq -e '.hook_event_name == "UserPromptSubmit"' <<< "$json" > /dev/null 2>&1; then
        echo "claude"
    else
        echo "unknown"
    fi
}

#######################################
# report_leak: Emit the detection in the format the agent expects, then exit
#
# Globals:
#   None
#
# Arguments:
#   $1 - agent name
#   $2 - human-readable message
#
# Outputs:
#   Does not return. Exits with 0 (Cursor JSON block) or 2 (stderr).
#
# Returns:
#   None
#######################################
function report_leak {
    local agent="$1"
    local message="$2"
    case "$agent" in
        cursor)
            jq -n --arg m "$message" '{continue: false, user_message: $m}'
            exit 0
            ;;
        *)
            echo "$message" >&2
            exit 2
            ;;
    esac
}

#######################################
# scan_prompt: Run gitleaks on the prompt text
#
# Globals:
#   LEAKS_EXIT_CODE
#
# Arguments:
#   $1 - prompt text
#
# Outputs:
#   One "RuleID (line N)" per finding to stdout (secret values are redacted)
#
# Returns:
#   0 when leaks were found, 1 when clean or gitleaks failed
#######################################
function scan_prompt {
    local prompt="$1"
    local report rc=0
    local -a config_args=()
    [[ -f .gitleaks.toml ]] && config_args=(--config=.gitleaks.toml)

    report=$(mktemp) || return 1
    printf '%s' "$prompt" \
        | gitleaks stdin --no-banner --redact --exit-code "$LEAKS_EXIT_CODE" \
            --report-format json --report-path "$report" "${config_args[@]}" > /dev/null 2>&1 || rc=$?
    if ((rc == LEAKS_EXIT_CODE)); then
        jq -r '.[] | "\(.RuleID) (line \(.StartLine))"' "$report" 2> /dev/null | sort -u
        rm -f "$report"
        return 0
    fi
    rm -f "$report"
    return 1
}

#######################################
# main: Entry point
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
#   0 when clean or skipped
#######################################
function main {
    command -v jq > /dev/null 2>&1 || exit 0
    command -v gitleaks > /dev/null 2>&1 || exit 0
    [[ -t 0 ]] && exit 0

    local json prompt agent findings
    json=$(cat)
    prompt=$(jq -r '.prompt // empty' <<< "$json" 2> /dev/null || true)
    [[ -n $prompt ]] || exit 0

    local root
    root=$(git rev-parse --show-toplevel 2> /dev/null) || root=$(jq -r '.cwd // empty' <<< "$json" 2> /dev/null || true)
    [[ -n $root && -d $root ]] && cd "$root"

    findings=$(scan_prompt "$prompt") || exit 0
    [[ -n $findings ]] || exit 0

    agent=$(detect_agent "$json")
    local action="Remove the secret and resubmit the prompt."
    [[ $agent == "copilot" ]] && action="This agent cannot block the prompt: treat the secret as exposed and rotate it."
    report_leak "$agent" "gitleaks found potential secrets in your prompt:
${findings}
${action}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
