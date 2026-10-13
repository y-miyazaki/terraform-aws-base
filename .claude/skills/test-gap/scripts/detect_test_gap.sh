#!/bin/bash
#######################################
# Description: Detect language-agnostic facts for the test-gap automation (thin detect)
#
# Usage: ./detect_test_gap.sh [--scope staged|all|range] [--since <ref>]
#   --scope    Cursor axis (default: all)
#              all: full pass
#              range: requires --since; echoes since/commit_range
#              staged: accepted for CLI parity; same output as all
#   --since    Git ref for range scope (commit SHA from state cursor)
#
# Output:
# - JSON object: status, scope, since, commit_range, skip (always false),
#   hotspots[] (git churn), ledger {file, processed[]}, warnings[],
#   verifier_context (markdown listing processed ledger paths for the Checker; empty when none)
#
# Design Rules:
# - Emit facts only; never decide that tests are missing (the maker agent selects targets)
# - skip is always false so the schedule always reaches the maker (spec: thin detect)
# - Per-sensor recoverable failures append to warnings[] and continue
# - Fatal errors emit status=error JSON and exit 1
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/apm/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - git
# - jq
#
# Optional environment:
#   TEST_GAP_LEDGER_FILE     Ledger path, repository-relative (default: .loop/state-test-gap-ledger.json)
#   TEST_GAP_CHURN_WINDOW    Git log --since window for churn hotspots (default: 90.days)
#   TEST_GAP_CHURN_MIN       Minimum commit touches per path (default: 3)
#   TEST_GAP_CHURN_TOP       Maximum churn hotspots to emit (default: 20)
#   TEST_GAP_RETENTION_DAYS  Days a ledger entry stays visible (default: 30; a non-numeric value warns and falls back to 30)
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
SCOPE="all"
SINCE_REF=""
COMMIT_RANGE=""
LEDGER_FILE=""
LEDGER_PROCESSED_JSON="[]"
declare -a HOTSPOTS_JSON=()
declare -a WARNINGS=()

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
#   Usage text to stdout
#
# Returns:
#   Exits with code 0
#
#######################################
function show_usage {
    cat << 'EOF'
Usage: detect_test_gap.sh [--scope staged|all|range] [--since <ref>]

Description:
    Emit language-agnostic facts (git churn hotspots, processed ledger entries) for the
    test-gap skill. Never decides that tests are missing; skip is always false.

Options:
    --scope    Cursor axis (default: all)
               all: full pass
               range: requires --since
               staged: accepted for CLI parity
    --since    Git ref for range scope

Examples:
    ./detect_test_gap.sh
    ./detect_test_gap.sh --scope range --since abc1234
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   SCOPE, SINCE_REF - Set
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Calls output_error on invalid input; show_usage on -h/--help
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
            --scope)
                [[ $# -lt 2 ]] && output_error "--scope requires a value"
                SCOPE="$2"
                shift 2
                ;;
            --since)
                [[ $# -lt 2 ]] && output_error "--since requires a value"
                SINCE_REF="$2"
                shift 2
                ;;
            *)
                output_error "Unknown argument: $1"
                ;;
        esac
    done

    case "${SCOPE}" in
        staged | all | range) ;;
        *) output_error "--scope must be staged, all, or range" ;;
    esac
    if [[ ${SCOPE} == "range" && -z ${SINCE_REF} ]]; then
        output_error "--scope range requires --since <ref>"
    fi
}

#######################################
# collect_churn_hotspots: Emit churn hotspots from git log
#
# Globals:
#   HOTSPOTS_JSON - Output array of hotspot objects (appended)
#   WARNINGS - Warning messages (appended)
#   SCOPE, SINCE_REF - Read; range scope limits the log to the since..HEAD range
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 always (failures become warnings)
#
#######################################
function collect_churn_hotspots {
    local window="${TEST_GAP_CHURN_WINDOW:-90.days}"
    local min_count="${TEST_GAP_CHURN_MIN:-3}"
    local top_n="${TEST_GAP_CHURN_TOP:-20}"
    local emitted=0
    local count path log_output
    local -a log_args=(--since="${window}" --name-only --pretty=format:)

    if [[ ${SCOPE} == "range" ]]; then
        if ! git rev-parse --verify --quiet "${SINCE_REF}^{commit}" > /dev/null 2>&1; then
            WARNINGS+=("since ref is not a valid commit: ${SINCE_REF}; churn sensor skipped")
            return 0
        fi
        log_args+=("${SINCE_REF}..HEAD")
    fi

    if ! log_output="$(git log "${log_args[@]}" 2> /dev/null)"; then
        WARNINGS+=("churn sensor skipped: git log failed")
        return 0
    fi
    [[ -z ${log_output} ]] && return 0

    while read -r count path; do
        [[ -z ${path} ]] && continue
        if repo_path_should_skip "${path}"; then
            continue
        fi
        if [[ ${count} -lt ${min_count} ]]; then
            break
        fi
        HOTSPOTS_JSON+=("$(json_object \
            path "${path}" \
            kind "churn" \
            count "$(json_number "${count}")" \
            window "${window}")")
        emitted=$((emitted + 1))
        if [[ ${emitted} -ge ${top_n} ]]; then
            break
        fi
    done < <(
        printf '%s\n' "${log_output}" \
            | grep -v '^[[:space:]]*$' \
            | sort \
            | uniq -c \
            | sort -rn
    )
}

#######################################
# load_ledger_summary: Read recent ledger entries into LEDGER_PROCESSED_JSON
#
# Globals:
#   LEDGER_FILE - Ledger path (repository-relative)
#   TEST_GAP_RETENTION_DAYS - Read (validated; invalid values fall back to 30 with a warning)
#   LEDGER_PROCESSED_JSON - Set to a JSON array of {path, attempts, outcome, processed_at}
#   WARNINGS - Warning messages (appended)
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 always (a missing file is empty; a corrupt file becomes a warning)
#
#######################################
function load_ledger_summary {
    local retention="${TEST_GAP_RETENTION_DAYS:-30}"
    local cutoff

    LEDGER_PROCESSED_JSON="[]"
    if [[ ! ${retention} =~ ^[0-9]+$ ]]; then
        WARNINGS+=("TEST_GAP_RETENTION_DAYS must be a non-negative integer (got: ${retention}); using 30")
        retention=30
    fi
    [[ -f ${LEDGER_FILE} ]] || return 0

    if ! jq -e '.entries | type == "object"' "${LEDGER_FILE}" > /dev/null 2>&1; then
        WARNINGS+=("ledger file is not valid JSON or has no entries object: ${LEDGER_FILE}")
        return 0
    fi

    cutoff="$(date -u -d "${retention} days ago" +%Y-%m-%dT%H:%M:%SZ)"
    LEDGER_PROCESSED_JSON="$(jq -c --arg cutoff "${cutoff}" '
        [.entries | to_entries[]
         | select((.value.processed_at // "") >= $cutoff)
         | {path: .key, attempts: (.value.attempts // 0), outcome: (.value.outcome // ""), processed_at: (.value.processed_at // "")}]
        | sort_by(.path)' "${LEDGER_FILE}")"
}

#######################################
# output_error: Print structured JSON error and exit 1
#
# Globals:
#   SCOPE, SINCE_REF - Read
#
# Arguments:
#   $1 - Error message
#
# Outputs:
#   Error JSON on stdout
#
# Returns:
#   Exits with code 1
#
#######################################
function output_error {
    json_object \
        status "error" \
        scope "${SCOPE}" \
        since "${SINCE_REF}" \
        skip "true" \
        error "$1"
    exit 1
}

#######################################
# output_json: Print the detect result (includes verifier_context markdown built from the ledger)
#
# Globals:
#   SCOPE, SINCE_REF, COMMIT_RANGE, LEDGER_FILE, LEDGER_PROCESSED_JSON, HOTSPOTS_JSON, WARNINGS - Read
#
# Arguments:
#   None
#
# Outputs:
#   Detect JSON on stdout
#
# Returns:
#   0
#
#######################################
function output_json {
    local verifier_context
    verifier_context="$(jq -r --arg file "${LEDGER_FILE}" '
        if length == 0 then ""
        else
            "## test-gap ledger (recently processed test paths)\n"
            + "Source: " + $file + "\n"
            + (map("- " + .path + " (attempts: " + (.attempts | tostring) + ", outcome: " + .outcome + ")") | join("\n"))
            + "\nA target whose test path is listed above must not be selected again unless the PR body states a new reason."
        end' <<< "${LEDGER_PROCESSED_JSON}")"

    json_object \
        status "ok" \
        scope "${SCOPE}" \
        since "${SINCE_REF}" \
        commit_range "${COMMIT_RANGE}" \
        skip "false" \
        hotspots "$(json_array "${HOTSPOTS_JSON[@]}")" \
        ledger "$(json_object file "${LEDGER_FILE}" processed "${LEDGER_PROCESSED_JSON}")" \
        warnings "$(json_string_array "${WARNINGS[@]}")" \
        verifier_context "${verifier_context}"
}

#######################################
# main: Entry point
#
# Globals:
#   SCOPE, SINCE_REF, COMMIT_RANGE, LEDGER_FILE - Set and read
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Detect JSON on stdout
#
# Returns:
#   0 on success; 1 on fatal error (error JSON on stdout)
#
#######################################
function main {
    parse_arguments "$@"

    if ! command -v jq > /dev/null 2>&1; then
        json_emit_minimal_error "jq is required"
        exit 1
    fi
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        output_error "Not a git repository"
    fi

    LEDGER_FILE="${TEST_GAP_LEDGER_FILE:-.loop/state-test-gap-ledger.json}"
    [[ ${SCOPE} == "range" ]] && COMMIT_RANGE="${SINCE_REF}..HEAD"

    collect_churn_hotspots
    load_ledger_summary
    output_json
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
