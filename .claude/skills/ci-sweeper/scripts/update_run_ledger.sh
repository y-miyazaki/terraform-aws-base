#!/bin/bash
#######################################
# Description: Update ci-sweeper run ledger after a loop execution
#
# Usage: ./update_run_ledger.sh --run-id <id> --workflow <name> --head-sha <sha> --outcome <outcome> [--loop-run-id <id>]
#
# Output:
# - None on success (ledger file updated in place)
# - Warnings on stderr when prerequisites are missing
#
# Design Rules:
# - Exit 0 always; log errors to stderr
# - Merge into existing ledger without dropping unrelated run entries
# - Prune entries older than 30 days (aligned with loop-run-log / state retention)
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/ai/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - jq
#
# Optional environment:
#   CI_SWEEPER_LEDGER_FILE  Ledger path (default: .loop/state-ci-sweeper-run-ledger.json)
#   GITHUB_RUN_ID           Default loop run id when --loop-run-id is omitted
#   TARGET_JSON             target_json from loop-finalize (when CLI args omitted)
#   OUTCOME                 Loop outcome from loop-finalize (when --outcome omitted)
#   VERDICT                 Verifier verdict (maps to ledger outcome when OUTCOME unset)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables
#######################################
LEDGER_FILE="${CI_SWEEPER_LEDGER_FILE:-.loop/state-ci-sweeper-run-ledger.json}"
RUN_ID=""
WORKFLOW_NAME=""
HEAD_SHA=""
OUTCOME="${OUTCOME-}"
LOOP_RUN_ID="${GITHUB_RUN_ID:-}"

#######################################
# show_usage: Display script usage information
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Result text to stdout
#
# Returns:
#   Exits with code 0
#
#######################################
function show_usage {
    cat << 'EOF'
Usage: update_run_ledger.sh --run-id <id> --workflow <name> --head-sha <sha> --outcome <outcome> [--loop-run-id <id>]

Description:
    Update the ci-sweeper run ledger after a loop execution.

Options:
    --run-id         Workflow run ID to record
    --workflow       Workflow display name
    --head-sha       Commit SHA for the failed run
    --outcome        Loop outcome (for example: pr-created, rejected, no-action)
    --loop-run-id    GitHub Actions run ID for the loop execution (optional)

Examples:
    ./update_run_ledger.sh --run-id 123456789 --workflow ci-markdown --head-sha abc1234 --outcome pr-created
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments

# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            --run-id)
                if [[ $# -lt 2 ]]; then
                    log "WARN" "--run-id requires a value"
                    exit 0
                fi
                RUN_ID="$2"
                shift 2
                ;;
            --workflow)
                if [[ $# -lt 2 ]]; then
                    log "WARN" "--workflow requires a value"
                    exit 0
                fi
                WORKFLOW_NAME="$2"
                shift 2
                ;;
            --head-sha)
                if [[ $# -lt 2 ]]; then
                    log "WARN" "--head-sha requires a value"
                    exit 0
                fi
                HEAD_SHA="$2"
                shift 2
                ;;
            --outcome)
                if [[ $# -lt 2 ]]; then
                    log "WARN" "--outcome requires a value"
                    exit 0
                fi
                OUTCOME="$2"
                shift 2
                ;;
            --loop-run-id)
                if [[ $# -lt 2 ]]; then
                    log "WARN" "--loop-run-id requires a value"
                    exit 0
                fi
                LOOP_RUN_ID="$2"
                shift 2
                ;;
            *)
                log "WARN" "Unknown argument: $1"
                exit 0
                ;;
        esac
    done
}

#######################################
# resolve_from_env: Fill missing fields from domain_persistence_script env
#
# Globals:
#   RUN_ID, WORKFLOW_NAME, HEAD_SHA, OUTCOME - Updated when unset
#   TARGET_JSON, VERDICT - Read from environment
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function resolve_from_env {
    if [[ -z ${RUN_ID} && -n ${TARGET_JSON:-} ]]; then
        RUN_ID=$(jq -r '.workflow_run_id // empty' <<< "${TARGET_JSON}" 2> /dev/null || true)
    fi
    if [[ -z ${WORKFLOW_NAME} && -n ${TARGET_JSON:-} ]]; then
        WORKFLOW_NAME=$(jq -r '.workflow_name // empty' <<< "${TARGET_JSON}" 2> /dev/null || true)
    fi
    if [[ -z ${HEAD_SHA} && -n ${TARGET_JSON:-} ]]; then
        HEAD_SHA=$(jq -r '.head_sha // .from.ref // empty' <<< "${TARGET_JSON}" 2> /dev/null || true)
    fi
    if [[ -z ${OUTCOME} ]]; then
        case "${VERDICT:-}" in
            APPROVE) OUTCOME="pr-created" ;;
            REJECT) OUTCOME="rejected" ;;
        esac
    fi
    case "${OUTCOME}" in
        no-changes) OUTCOME="no-action" ;;
        pr-created | rejected | watch | no-action) ;;
        error | escalated)
            OUTCOME=""
            ;;
        *)
            log "WARN" "Unknown ledger outcome '${OUTCOME}'; skipping ledger update."
            OUTCOME=""
            ;;
    esac
}

#######################################
# should_skip_ledger_update: Return 0 when ledger must not be written
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
#   None
#
#######################################
function should_skip_ledger_update {
    [[ -z ${OUTCOME} ]]
}

#######################################
# validate_ledger_file: Ensure ledger path stays under .loop/
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
#   None
#
#######################################
function validate_ledger_file {
    local path="$1"
    if [[ ${path} != .loop/* ]]; then
        log "WARN" "CI_SWEEPER_LEDGER_FILE must be under .loop/ (got: ${path})"
        exit 0
    fi
}

#######################################
# update_ledger: Merge run outcome into the ledger file
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
#   None
#
#######################################
function update_ledger {
    local now cutoff updated
    now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    cutoff="$(date -u -d '30 days ago' +"%Y-%m-%dT%H:%M:%SZ" 2> /dev/null || date -u -v-30d +"%Y-%m-%dT%H:%M:%SZ")"

    if ! updated="$(jq --arg run_id "${RUN_ID}" --arg workflow "${WORKFLOW_NAME}" --arg head_sha "${HEAD_SHA}" --arg outcome "${OUTCOME}" --arg loop_run_id "${LOOP_RUN_ID}" --arg updated_at "${now}" --arg cutoff "${cutoff}" '''
        .runs[$run_id] = {
            workflow_name: $workflow,
            head_sha: $head_sha,
            outcome: $outcome,
            reject_count: (
                if $outcome == "rejected" then
                    ((.runs[$run_id].reject_count // 0) + 1)
                else
                    (.runs[$run_id].reject_count // 0)
                end
            ),
            loop_run_id: $loop_run_id,
            updated_at: $updated_at
        }
        | .runs |= with_entries(select(.value.updated_at >= $cutoff))
        ''' "${LEDGER_FILE}" 2>&1)"; then
        log "WARN" "Failed to update ledger: ${updated}"
        return 1
    fi

    if ! printf '%s\n' "${updated}" > "${LEDGER_FILE}"; then
        log "WARN" "Failed to write ledger file: ${LEDGER_FILE}"
        return 1
    fi
}

#######################################
# main: Entry point
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments

# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function main {
    parse_arguments "$@"
    validate_ledger_file "${LEDGER_FILE}"
    resolve_from_env

    if should_skip_ledger_update; then
        log "WARN" "Ledger update skipped for outcome '${OUTCOME:-<empty>}'."
        exit 0
    fi

    if [[ -z ${RUN_ID} ]]; then
        log "WARN" "No workflow run id; skipping ledger update."
        exit 0
    fi

    if ! command -v jq > /dev/null 2>&1; then
        log "WARN" "jq is required for ledger update."
        exit 0
    fi

    mkdir -p "$(dirname "${LEDGER_FILE}")"
    if [[ ! -f ${LEDGER_FILE} ]]; then
        echo '{"runs":{}}' > "${LEDGER_FILE}"
    fi

    update_ledger || log "WARN" "Ledger update skipped."
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
