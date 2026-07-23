#!/bin/bash
#######################################
# Description: Detect technical debt signals and hotspots for loop-tech-debt
#
# Usage: ./detect_tech_debt.sh [--scope staged|all|range] [--since <ref>]
#   --scope    Detection scope (default: all)
#              staged: not used for debt sensors (accepted for loop-detect parity)
#              all: scan the full repository tree (default)
#              range: accepted for loop-detect parity (requires --since)
#   --since    Git ref for range scope (commit SHA from loop state)
#
# Output:
# - JSON object with signals[], hotspots[], warnings[], skip boolean,
#   report_file, and previous_report
#
# Design Rules:
# - Emit facts only; Skill builds semantic findings[]
# - Output structured JSON via shared lib/json.sh
# - Exit 0 always (errors reported in JSON status field)
# - Default scan is full repository (scope=all); do not narrow sensors to lint territory
# - Per-sensor recoverable failures append to warnings[] and continue
# - Docs links use self-contained markdown-link-check (mlc) when Node is available
# - Sensor logic lives in detect_tech_debt_sensors.sh (sourced below)
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/ai/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - git
#
# Optional dependencies:
# - jq (package.json dependency sensor; mlc JSON parsing)
# - node, npm (docs link sensor; self-contained markdown-link-check install)
#
# Optional environment:
#   REPO_PATHS_EXTRA_PRUNES           - Comma-separated prune roots (default: parent of TECH_DEBT_DIR)
#   TECH_DEBT_DIR              - Report output directory (default: docs/report/tech-debt)
#   TECH_DEBT_DATE_FORMAT      - UTC strftime for report basename (default: %Y-%m-%d)
#   TECH_DEBT_FILE_EXTENSION   - Report filename extension including dot (default: .md)
#   TECH_DEBT_LEGACY_SEARCH_DIRS - Comma-separated prior-report search roots (default: docs/report/tech-debt)
#   TECH_DEBT_PREVIOUS_GLOB  - Glob for prior report files under search dirs (default: ????-??-??.md)
#   TECH_DEBT_EOL_MODULES           - Comma-separated module paths/names for eol_hint signals
#   TECH_DEBT_STALE_DAYS    - Days before a markdown file is stale (default: 365)
#   TECH_DEBT_SKIP_MLC      - When true, skip broken_doc_ref checks with a warning
#   TECH_DEBT_CHURN_WINDOW  - Git log window for churn hotspots (default: 90d)
#   TECH_DEBT_CHURN_MIN     - Minimum commit touches per path (default: 5)
#   TECH_DEBT_CHURN_TOP     - Maximum churn hotspots to emit (default: 20)
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
REPORT_FILE=""
PREVIOUS_REPORT=""

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
#   None
#
# Returns:
#   Exits with code 0
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << 'EOF'
Usage: detect_tech_debt.sh [--scope staged|all|range] [--since <ref>]

Description:
    Detect technical debt signals and hotspots for the loop-tech-debt skill.

Options:
    --scope    Detection scope (default: all)
               staged: accepted for loop-detect parity (not used by sensors)
               all: scan the full repository tree (default)
               range: accepted for loop-detect parity (requires --since)
    --since    Git ref for range scope (commit SHA from loop state)

Examples:
    ./detect_tech_debt.sh
    ./detect_tech_debt.sh --scope all
    ./detect_tech_debt.sh --scope range --since abc1234
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Git ref for range scope
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Calls output_error on invalid input
#
# Returns:
#   None
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            --scope)
                if [[ $# -lt 2 ]]; then
                    output_error "--scope requires a value"
                fi
                SCOPE="$2"
                shift 2
                ;;
            --since)
                if [[ $# -lt 2 ]]; then
                    output_error "--since requires a value"
                fi
                SINCE_REF="$2"
                shift 2
                ;;
            *)
                output_error "Unknown argument: $1"
                ;;
        esac
    done

    if [[ ${SCOPE} != "staged" && ${SCOPE} != "all" && ${SCOPE} != "range" ]]; then
        output_error "--scope must be staged, all, or range"
    fi

    if [[ ${SCOPE} == "range" && -z ${SINCE_REF} ]]; then
        output_error "--scope range requires --since <ref>"
    fi
}

# shellcheck source=detect_tech_debt_sensors.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/detect_tech_debt_sensors.sh"

#######################################
# output_error: Print structured JSON error and exit
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Git ref for range scope
#   REPORT_FILE - Target report path
#   PREVIOUS_REPORT - Latest prior report path
#   WARNINGS - Warning messages
#
# Arguments:
#   $1 - Error message
#
# Outputs:
#   None
#
# Returns:
#   Exits with code 0
#
# Usage:
#   output_error "Not a git repository"
#
#######################################
function output_error {
    local message="$1"

    resolve_report_file
    resolve_previous_report

    json_object_start
    json_field_string "status" "error" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_bool "skip" "true" ","
    json_field_array "signals" "[]" ","
    json_field_array "hotspots" "[]" ","
    json_field_array "warnings" "$(json_string_array "${WARNINGS[@]}")" ","
    json_field_string "report_file" "${REPORT_FILE}" ","
    json_field_string "previous_report" "${PREVIOUS_REPORT}" ","
    json_field_string "message" "${message}" ""
    json_object_end
    exit 0
}

#######################################
# output_json: Print structured JSON result using lib/json.sh helpers
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Git ref for range scope
#   REPORT_FILE - Target report path
#   PREVIOUS_REPORT - Latest prior report path
#   SIGNALS_JSON - Detected signal objects
#   HOTSPOTS_JSON - Detected hotspot objects
#   WARNINGS - Warning messages
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
# Usage:
#   output_json
#
#######################################
function output_json {
    local skip="false"
    local signals_array hotspots_array warnings_array

    resolve_report_file
    resolve_previous_report

    if [[ ${#SIGNALS_JSON[@]} -eq 0 && ${#HOTSPOTS_JSON[@]} -eq 0 ]]; then
        skip="true"
    fi

    signals_array="$(signals_array_json)"
    hotspots_array="$(hotspots_array_json)"
    warnings_array="$(json_string_array "${WARNINGS[@]}")"

    json_object_start
    json_field_string "status" "ok" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_bool "skip" "${skip}" ","
    json_field_array "signals" "${signals_array}" ","
    json_field_array "hotspots" "${hotspots_array}" ","
    json_field_array "warnings" "${warnings_array}" ","
    json_field_string "report_file" "${REPORT_FILE}" ","
    json_field_string "previous_report" "${PREVIOUS_REPORT}" ""
    json_object_end
}

#######################################
# configure_detect_environment: Normalize domain env into globals once at startup
#
# Globals:
#   TECH_DEBT_DIR - Report output directory
#   TECH_DEBT_DATE_FORMAT - UTC strftime for report basename
#   TECH_DEBT_FILE_EXTENSION - Report filename extension including dot
#   TECH_DEBT_LEGACY_SEARCH_DIRS - Comma-separated prior-report search roots
#   TECH_DEBT_PREVIOUS_GLOB - Glob for prior report files under search dirs
#   REPO_PATHS_EXTRA_PRUNES - Set when unset to parent of TECH_DEBT_DIR
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
# Usage:
#   configure_detect_environment
#
#######################################
function configure_detect_environment {
    TECH_DEBT_DIR="${TECH_DEBT_DIR:-docs/report/tech-debt}"
    TECH_DEBT_DIR="${TECH_DEBT_DIR#./}"
    TECH_DEBT_DATE_FORMAT="${TECH_DEBT_DATE_FORMAT:-%Y-%m-%d}"
    TECH_DEBT_FILE_EXTENSION="${TECH_DEBT_FILE_EXTENSION:-.md}"
    TECH_DEBT_LEGACY_SEARCH_DIRS="${TECH_DEBT_LEGACY_SEARCH_DIRS:-docs/report/tech-debt}"
    TECH_DEBT_PREVIOUS_GLOB="${TECH_DEBT_PREVIOUS_GLOB:-????-??-??.md}"

    if [[ -z ${REPO_PATHS_EXTRA_PRUNES:-} ]]; then
        REPO_PATHS_EXTRA_PRUNES="$(dirname "${TECH_DEBT_DIR}")"
    fi
}

#######################################
# append_report_search_dirs_from_csv: Append unique repository-relative dirs from CSV
#
# Globals:
#   None
#
# Arguments:
#   $1 - Name reference to output directory array
#   $2 - Comma-separated repository-relative directory paths
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   local -a dirs=()
#   append_report_search_dirs_from_csv dirs "${csv}"
#
#######################################
function append_report_search_dirs_from_csv {
    local -n _dirs=$1
    local csv="$2"
    local item trimmed dir existing seen=0

    [[ -z ${csv} ]] && return 0
    while IFS= read -r item || [[ -n ${item} ]]; do
        trimmed="${item#"${item%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        [[ -z ${trimmed} ]] && continue
        dir="${trimmed#./}"
        seen=0
        for existing in "${_dirs[@]}"; do
            if [[ ${existing} == "${dir}" ]]; then
                seen=1
                break
            fi
        done
        [[ ${seen} -eq 1 ]] && continue
        _dirs+=("${dir}")
    done < <(printf '%s' "${csv}" | tr ',' '\n')
}
#######################################
# resolve_previous_report: Set PREVIOUS_REPORT to latest dated report before today
#
# Globals:
#   REPORT_FILE - Today's target report path (excluded from selection)
#   PREVIOUS_REPORT - Latest prior report path (set by this function; empty when none)
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
# Usage:
#   resolve_previous_report
#
#######################################
function resolve_previous_report {
    local report_dir report_base candidate latest="" latest_name="" dir
    local -a search_dirs=()

    report_dir="$(dirname "${REPORT_FILE}")"
    report_base="$(basename "${REPORT_FILE}")"
    PREVIOUS_REPORT=""

    search_dirs=("${report_dir}")
    append_report_search_dirs_from_csv search_dirs "${TECH_DEBT_LEGACY_SEARCH_DIRS}"

    for dir in "${search_dirs[@]}"; do
        [[ -d ${dir} ]] || continue
        shopt -s nullglob
        for candidate in "${dir}"/${TECH_DEBT_PREVIOUS_GLOB}; do
            [[ -f ${candidate} ]] || continue
            candidate_base="$(basename "${candidate}")"
            if [[ ${candidate_base} == "${report_base}" ]]; then
                continue
            fi
            if [[ -z ${latest_name} || ${candidate_base} > ${latest_name} ]]; then
                latest="${candidate}"
                latest_name="${candidate_base}"
            fi
        done
        shopt -u nullglob
    done

    PREVIOUS_REPORT="${latest}"
}

#######################################
# resolve_report_file: Set REPORT_FILE to today's UTC-dated report path
#
# Globals:
#   REPORT_FILE - Target report path (set by this function)
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
# Usage:
#   resolve_report_file
#
#######################################
function resolve_report_file {
    REPORT_FILE="${TECH_DEBT_DIR}/$(date -u +"${TECH_DEBT_DATE_FORMAT}")${TECH_DEBT_FILE_EXTENSION}"
}

#######################################
# signal_object_json: Build one signal object as JSON
#
# Arguments:
#   $1-$6 - kind, path, line, snippet, source, hint (hint optional)
#
# Globals:
#   None
#
# Outputs:
#   JSON object on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   signal_object_json "todo_comment" "pkg/foo.go" "10" "// TODO" "markers" ""
#
#######################################
# signals_array_json: Join signal objects into a JSON array string
#
# Globals:
#   SIGNALS_JSON - Source signal objects
#
# Arguments:
#   None
#
# Outputs:
#   JSON array string on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   signals_array="$(signals_array_json)"
#
#######################################
function signals_array_json {
    local joined=""
    local signal

    if [[ ${#SIGNALS_JSON[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi

    for signal in "${SIGNALS_JSON[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${signal}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# main: Entry point
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
# Usage:
#   main "$@"
#
#######################################
function main {
    configure_detect_environment
    parse_arguments "$@"
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        output_error "Not a git repository"
    fi
    collect_marker_signals
    collect_dependency_signals
    collect_doc_signals
    collect_churn_hotspots
    output_json
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
