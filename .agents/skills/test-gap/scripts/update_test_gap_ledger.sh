#!/bin/bash
#######################################
# Description: Record test files changed by a test-gap run into the run ledger
#
# Usage: ./update_test_gap_ledger.sh
#   Intended as caller domain_persistence_script (loop-finalize). Inputs come from the environment.
#
# Output:
# - None on success (ledger file updated in place)
# - Warnings on stderr when prerequisites are missing or inputs are unusable
#
# Design Rules:
# - Always exit 0 so a ledger problem never blocks finalize (same policy as ci-sweeper update_run_ledger.sh)
# - Record only files in git diff <base>...<EXECUTE_BRANCH>; the maker does not have to cooperate
# - Base branch: TEST_GAP_BASE_BRANCH, else TARGET_JSON .to.branch (loop-finalize passes it), else main
# - loop-finalize passes only EXECUTE_BRANCH, LOOP_NAME, OUTCOME, STATE_FILE, TARGET_JSON, VERDICT to this script;
#   TEST_GAP_LEDGER_FILE and TEST_GAP_RETENTION_DAYS therefore stay at their defaults when run from finalize
# - Skip unchanged, error, escalated, and unknown outcomes
# - Prune entries older than the retention window
# - Write via mktemp + mv; keep unrelated entries intact
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - git
# - jq
#
# Optional environment:
#   OUTCOME                  pr_created | pr_pushed | rejected | watch | unchanged | error | escalated
#   VERDICT                  APPROVE | REJECT (used when OUTCOME is unset)
#   EXECUTE_BRANCH           Agent branch holding the test changes (required to record anything)
#   TARGET_JSON              Loop target JSON; .to.branch is the base branch when TEST_GAP_BASE_BRANCH is unset
#   TEST_GAP_BASE_BRANCH     Base branch for the diff (default: TARGET_JSON .to.branch, else main)
#   TEST_GAP_LEDGER_FILE     Ledger path, repository-relative (default: .loop/state-test-gap-ledger.json)
#   TEST_GAP_RETENTION_DAYS  Days an entry is kept (default: 30)
#   GITHUB_RUN_ID            Recorded as last_loop_run_id
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
OUTCOME="${OUTCOME-}"
LEDGER_FILE="${TEST_GAP_LEDGER_FILE:-.loop/state-test-gap-ledger.json}"
BASE_BRANCH="${TEST_GAP_BASE_BRANCH:-}"
RETENTION_DAYS="${TEST_GAP_RETENTION_DAYS:-30}"

#######################################
# changed_files: List files changed on the execute branch relative to the base
#
# Globals:
#   BASE_BRANCH, EXECUTE_BRANCH - Read
#
# Arguments:
#   None
#
# Outputs:
#   One repository-relative path per line on stdout
#
# Returns:
#   0 on success; 1 when the branch cannot be resolved or git diff fails
#
#######################################
function changed_files {
    local base="${BASE_BRANCH}"
    local head="${EXECUTE_BRANCH:-}"

    [[ -z ${head} ]] && return 1
    if git rev-parse --verify --quiet "origin/${base}^{commit}" > /dev/null 2>&1; then
        base="origin/${base}"
    fi
    git rev-parse --verify --quiet "${base}^{commit}" > /dev/null 2>&1 || return 1
    if git rev-parse --verify --quiet "origin/${head}^{commit}" > /dev/null 2>&1; then
        head="origin/${head}"
    fi
    git rev-parse --verify --quiet "${head}^{commit}" > /dev/null 2>&1 || return 1
    git -c core.quotepath=off diff --name-only "${base}...${head}" 2> /dev/null
}

#######################################
# resolve_base_branch: Decide the base branch for the diff
#
# Globals:
#   BASE_BRANCH - Read; set to TEST_GAP_BASE_BRANCH, else TARGET_JSON .to.branch, else main
#   TARGET_JSON - Read
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0
#
#######################################
function resolve_base_branch {
    local from_target=""

    if [[ -n ${BASE_BRANCH} ]]; then
        return 0
    fi
    if [[ -n ${TARGET_JSON:-} ]]; then
        from_target="$(jq -r '.to.branch // empty' <<< "${TARGET_JSON}" 2> /dev/null)" || from_target=""
    fi
    BASE_BRANCH="${from_target:-main}"
}

#######################################
# resolve_outcome: Normalize OUTCOME (empty means skip)
#
# Globals:
#   OUTCOME, VERDICT - Read; OUTCOME is updated in place
#
# Arguments:
#   None
#
# Outputs:
#   Warning on stderr for unknown outcomes
#
# Returns:
#   0
#
#######################################
function resolve_outcome {
    if [[ -z ${OUTCOME} ]]; then
        case "${VERDICT:-}" in
            APPROVE) OUTCOME="pr_created" ;;
            REJECT) OUTCOME="rejected" ;;
        esac
    fi
    case "${OUTCOME}" in
        pr-created) OUTCOME="pr_created" ;;
        pr_created | pr_pushed | rejected | watch) ;;
        "" | unchanged | no-action | no-changes | error | escalated)
            OUTCOME=""
            ;;
        *)
            log "WARN" "Unknown ledger outcome '${OUTCOME}'; skipping ledger update"
            OUTCOME=""
            ;;
    esac
}

#######################################
# validate_ledger_file: Reject empty, absolute, and parent-relative ledger paths
#
# Globals:
#   None
#
# Arguments:
#   $1 - Ledger path
#
# Outputs:
#   Warning on stderr when rejected
#
# Returns:
#   0 when usable; 1 when rejected
#
#######################################
function validate_ledger_file {
    local path="$1"
    local repo_root resolved

    if [[ -z ${path} ]]; then
        log "WARN" "TEST_GAP_LEDGER_FILE must not be empty"
        return 1
    fi
    if [[ ${path} == /* ]]; then
        log "WARN" "TEST_GAP_LEDGER_FILE must be a repository-relative path (got: ${path})"
        return 1
    fi
    repo_root="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
    if ! resolved="$(realpath -m "${repo_root}/${path}" 2> /dev/null)"; then
        log "WARN" "cannot resolve TEST_GAP_LEDGER_FILE (got: ${path})"
        return 1
    fi
    if [[ ${resolved} != "${repo_root}"/* ]]; then
        log "WARN" "TEST_GAP_LEDGER_FILE must stay under the repository root (got: ${path})"
        return 1
    fi
}

#######################################
# main: Entry point
#
# Globals:
#   OUTCOME, LEDGER_FILE, RETENTION_DAYS - Read; BASE_BRANCH - Set via resolve_base_branch
#
# Arguments:
#   None
#
# Outputs:
#   Warnings on stderr
#
# Returns:
#   0 always
#
#######################################
function main {
    local files now cutoff tmp existing ledger_dir

    if ! command -v jq > /dev/null 2>&1; then
        log "WARN" "jq is required; skipping ledger update"
        return 0
    fi

    if [[ ! ${RETENTION_DAYS} =~ ^[0-9]+$ ]]; then
        log "WARN" "TEST_GAP_RETENTION_DAYS must be a non-negative integer (got: ${RETENTION_DAYS}); using 30"
        RETENTION_DAYS=30
    fi

    resolve_outcome
    if [[ -z ${OUTCOME} ]]; then
        return 0
    fi
    resolve_base_branch

    validate_ledger_file "${LEDGER_FILE}" || return 0

    if ! files="$(changed_files)"; then
        log "WARN" "cannot resolve execute branch '${EXECUTE_BRANCH:-}' against '${BASE_BRANCH}'; skipping ledger update"
        return 0
    fi
    if [[ -z ${files} ]]; then
        return 0
    fi

    existing='{"entries":{}}'
    if [[ -f ${LEDGER_FILE} ]]; then
        if jq -e '.entries | type == "object"' "${LEDGER_FILE}" > /dev/null 2>&1; then
            existing="$(cat "${LEDGER_FILE}")" || existing='{"entries":{}}'
        else
            log "WARN" "ledger file is corrupt; starting from an empty ledger: ${LEDGER_FILE}"
        fi
    fi

    now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    if ! cutoff="$(date -u -d "${RETENTION_DAYS} days ago" +%Y-%m-%dT%H:%M:%SZ 2> /dev/null)"; then
        log "WARN" "cannot compute retention cutoff for ${RETENTION_DAYS} days; skipping ledger update"
        return 0
    fi
    ledger_dir="$(dirname "${LEDGER_FILE}")"
    if ! mkdir -p "${ledger_dir}" 2> /dev/null; then
        log "WARN" "cannot create ledger directory: ${ledger_dir}"
        return 0
    fi
    # Temp file lives beside the ledger so the final mv is an atomic same-filesystem rename
    if ! tmp="$(mktemp "${ledger_dir}/.ledger.XXXXXX" 2> /dev/null)"; then
        log "WARN" "cannot create temp file in ${ledger_dir}; skipping ledger update"
        return 0
    fi
    # shellcheck disable=SC2016  # jq filter; $vars are bound via --arg/--argjson below
    if ! printf '%s\n' "${files}" | jq -R -s -c \
        --argjson ledger "${existing}" \
        --arg now "${now}" \
        --arg cutoff "${cutoff}" \
        --arg outcome "${OUTCOME}" \
        --arg run_id "${GITHUB_RUN_ID:-}" '
        (split("\n") | map(select(length > 0))) as $paths
        | reduce $paths[] as $p ($ledger;
            .entries[$p] = {
              attempts: ((.entries[$p].attempts // 0) + 1),
              last_loop_run_id: $run_id,
              outcome: $outcome,
              processed_at: $now
            })
        | .entries |= with_entries(select((.value.processed_at // "") >= $cutoff))' > "${tmp}"; then
        log "WARN" "ledger update failed; leaving the ledger unchanged"
        rm -f "${tmp}"
        return 0
    fi
    if ! mv "${tmp}" "${LEDGER_FILE}" 2> /dev/null; then
        log "WARN" "cannot write ledger file: ${LEDGER_FILE}"
        rm -f "${tmp}"
    fi
    return 0
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
