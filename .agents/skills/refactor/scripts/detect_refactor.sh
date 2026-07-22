#!/bin/bash
#######################################
# Description: Detect mechanical structure hints for loop-refactor (H1 only)
#
# Usage: ./detect_refactor.sh [--scope staged|all|range] [--since <ref>]
#   --scope    Change detection scope (default: all for integration scan)
#              range: limit scan to files changed in <since>..HEAD
#   --since    Git ref for range scope (commit SHA from loop state)
#
# Output:
# - JSON object with hints[], commit_range, skip
#
# Design Rules:
# - Emit facts only: duplication_block | oversized_unit (closed kinds)
# - duplication_block compares consecutive non-comment, non-blank lines only
# - No lint/SAST smell scores
# - Output structured JSON via shared lib/json.sh
# - Exit 0 always (errors reported in JSON status field)
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/ai/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - git
#
# Optional environment:
#   REFACTOR_DUP_MIN_LINES          Minimum non-comment, non-empty lines for duplication_block (default: 8)
#   REFACTOR_MAX_HINTS              Cap hints emitted per run (default: 20)
#   REFACTOR_OVERSIZED_FILE_LINES   File line threshold for oversized_unit (default: 400)
#   REFACTOR_SCAN_GLOBS             Comma-separated globs to scan (default: .apm/packages/**,scripts/**)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

SCOPE="all"
SINCE_REF=""
COMMIT_RANGE=""

REFACTOR_DUP_MIN_LINES="${REFACTOR_DUP_MIN_LINES:-8}"
REFACTOR_MAX_HINTS="${REFACTOR_MAX_HINTS:-20}"
REFACTOR_OVERSIZED_FILE_LINES="${REFACTOR_OVERSIZED_FILE_LINES:-400}"
REFACTOR_SCAN_GLOBS="${REFACTOR_SCAN_GLOBS:-.apm/packages/**,scripts/**}"

declare -a SCAN_FILES=()
declare -a HINTS_JSON=()

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
Usage: detect_refactor.sh [--scope staged|all|range] [--since <ref>]

Description:
    Detect mechanical structure hints (duplication_block, oversized_unit) for loop-refactor.

Options:
    --scope    Detection scope (default: all)
               all: scan tracked files matching REFACTOR_SCAN_GLOBS
               range: scan only files changed in <since>..HEAD matching globs
               staged: git diff --cached only (parity with sibling detects)
    --since    Git ref for range scope (commit SHA from loop state)

Examples:
    ./detect_refactor.sh --scope all
    ./detect_refactor.sh --scope range --since abc1234
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
#   None
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
                    emit_error_json "missing value for --scope"
                    exit 0
                fi
                SCOPE="$2"
                shift 2
                ;;
            --since)
                if [[ $# -lt 2 ]]; then
                    emit_error_json "missing value for --since"
                    exit 0
                fi
                SINCE_REF="$2"
                shift 2
                ;;
            *)
                emit_error_json "unknown argument: $1"
                exit 0
                ;;
        esac
    done
}

#######################################
# configure_detect_environment: Load domain env into globals
#
# Globals:
#   REFACTOR_* - Detect thresholds and scan globs
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
    :
}

#######################################
# is_pruned_path: Return whether a path must be excluded from scan
#
# Globals:
#   None
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   None
#
# Returns:
#   0 when pruned, 1 when allowed
#
# Usage:
#   if is_pruned_path "${path}"; then continue; fi
#
#######################################
function is_pruned_path {
    local path="$1"
    case "${path}" in
        .git/* | */.git/* | node_modules/* | */node_modules/* | apm_modules/* | */apm_modules/*)
            return 0
            ;;
        docs/report/* | */docs/report/*)
            return 0
            ;;
        .agents/* | .claude/* | .codex/* | .cursor/* | .kiro/* | .vscode/*)
            return 0
            ;;
        */.env | */.env.* | */credentials* | */secrets*)
            return 0
            ;;
    esac
    return 1
}

#######################################
# path_matches_scan_globs: Test path against comma-separated globs
#
# Globals:
#   REFACTOR_SCAN_GLOBS - Comma-separated glob list
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   None
#
# Returns:
#   0 when matched, 1 otherwise
#
# Usage:
#   path_matches_scan_globs "${path}" && collect
#
#######################################
function path_matches_scan_globs {
    local path="$1"
    local glob_part prefix
    local -a globs=()

    IFS=',' read -ra globs <<< "${REFACTOR_SCAN_GLOBS}"
    for glob_part in "${globs[@]}"; do
        glob_part="$(trim_whitespace "${glob_part}")"
        [[ -z ${glob_part} ]] && continue
        if [[ ${glob_part} == *\*\** ]]; then
            prefix="${glob_part%%\*\*}"
            prefix="${prefix%/}"
            if [[ ${path} == "${prefix}" || ${path} == "${prefix}"/* ]]; then
                return 0
            fi
        elif [[ ${path} == "${glob_part}" ]]; then
            return 0
        fi
    done
    return 1
}

#######################################
# append_scan_file: Add a unique scan candidate path
#
# Globals:
#   SCAN_FILES - Output file list
#
# Arguments:
#   $1 - Repository-relative file path
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   append_scan_file "${path}"
#
#######################################
function append_scan_file {
    local path="$1"
    local existing

    [[ -z ${path} ]] && return 0
    is_pruned_path "${path}" && return 0
    path_matches_scan_globs "${path}" || return 0
    [[ -f ${path} ]] || return 0

    for existing in "${SCAN_FILES[@]}"; do
        [[ ${existing} == "${path}" ]] && return 0
    done
    SCAN_FILES+=("${path}")
}

#######################################
# collect_scan_files_from_globs: Populate SCAN_FILES via globstar expansion
#
# Globals:
#   SCAN_FILES, REFACTOR_SCAN_GLOBS
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
#   collect_scan_files_from_globs
#
#######################################
function collect_scan_files_from_globs {
    local glob_part match
    local -a globs=()

    IFS=',' read -ra globs <<< "${REFACTOR_SCAN_GLOBS}"
    shopt -s globstar nullglob
    for glob_part in "${globs[@]}"; do
        glob_part="$(trim_whitespace "${glob_part}")"
        [[ -z ${glob_part} ]] && continue
        for match in ${glob_part}; do
            match="${match#./}"
            append_scan_file "${match}"
        done
    done
    shopt -u globstar nullglob
}

#######################################
# collect_scan_files: Populate SCAN_FILES for the active scope
#
# Globals:
#   SCAN_FILES - Output file list
#   SCOPE, SINCE_REF, COMMIT_RANGE
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
#   collect_scan_files
#
#######################################
function collect_scan_files {
    local -a candidates=()
    local path

    SCAN_FILES=()

    case "${SCOPE}" in
        staged)
            mapfile -t candidates < <(git diff --cached --name-only --diff-filter=ACMR 2> /dev/null || true)
            COMMIT_RANGE="staged"
            for path in "${candidates[@]}"; do
                append_scan_file "${path}"
            done
            ;;
        range)
            if [[ -z ${SINCE_REF} ]]; then
                emit_error_json "range scope requires --since"
                exit 0
            fi
            mapfile -t candidates < <(git diff --name-only --diff-filter=ACMR "${SINCE_REF}"..HEAD 2> /dev/null || true)
            COMMIT_RANGE="${SINCE_REF}..$(git rev-parse HEAD 2> /dev/null || echo HEAD)"
            for path in "${candidates[@]}"; do
                append_scan_file "${path}"
            done
            ;;
        all)
            COMMIT_RANGE="HEAD"
            collect_scan_files_from_globs
            ;;
        *)
            emit_error_json "invalid scope: ${SCOPE}"
            exit 0
            ;;
    esac
}

#######################################
# append_hint_json: Append one hint object string to HINTS_JSON
#
# Globals:
#   HINTS_JSON, REFACTOR_MAX_HINTS
#
# Arguments:
#   $1 - kind
#   $2 - path
#   $3 - detail
#   $4 - lines (number)
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   append_hint_json "oversized_unit" "scripts/foo.sh" "file lines=450" 450
#
#######################################
function append_hint_json {
    local kind="$1"
    local path="$2"
    local detail="$3"
    local lines="$4"
    local escaped_kind escaped_path escaped_detail

    if [[ ${#HINTS_JSON[@]} -ge ${REFACTOR_MAX_HINTS} ]]; then
        return 0
    fi

    escaped_kind="$(json_escape "${kind}")"
    escaped_path="$(json_escape "${path}")"
    escaped_detail="$(json_escape "${detail}")"
    HINTS_JSON+=("{\"kind\":\"${escaped_kind}\",\"path\":\"${escaped_path}\",\"detail\":\"${escaped_detail}\",\"lines\":${lines}}")
}

#######################################
# find_duplication_blocks: Emit duplication_block hints across scan set
#
# Globals:
#   SCAN_FILES, REFACTOR_DUP_MIN_LINES, HINTS_JSON
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
#   find_duplication_blocks
#
#######################################
function find_duplication_blocks {
    local min_lines="${REFACTOR_DUP_MIN_LINES}"
    local tmp_dir
    local index_file

    if [[ ${#SCAN_FILES[@]} -eq 0 ]]; then
        return 0
    fi

    tmp_dir="$(mktemp -d)"
    index_file="${tmp_dir}/blocks.tsv"

    awk -v min_lines="${min_lines}" '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }
        function is_comment_line(line) {
            return line ~ /^#/ \
                || line ~ /^\/\// \
                || line ~ /^\/\*/ \
                || line ~ /^\*/ \
                || line ~ /^--/
        }
        function make_loc(file, start_line, end_line) {
            return file ":" start_line ":" end_line
        }
        FNR == 1 {
            file = FILENAME
            delete buf
            delete phys_line
            buf_count = 0
        }
        {
            line = trim($0)
            if (line == "" || is_comment_line(line)) {
                next
            }
            buf_count++
            buf[buf_count] = line
            phys_line[buf_count] = NR
            if (buf_count < min_lines) {
                next
            }
            start_idx = buf_count - min_lines + 1
            start_phys = phys_line[start_idx]
            end_phys = phys_line[buf_count]
            block = ""
            for (i = start_idx; i <= buf_count; i++) {
                block = block buf[i] "\n"
            }
            key = block
            loc = make_loc(file, start_phys, end_phys)
            if (!(key in seen)) {
                seen[key] = loc
            } else {
                print seen[key] "\t" loc "\t" min_lines
            }
        }
    ' "${SCAN_FILES[@]}" > "${index_file}" || true

    if [[ -s ${index_file} ]]; then
        local first_loc second_loc block_lines rest
        local first_path first_start first_end second_path second_start second_end detail
        while IFS=$'\t' read -r first_loc second_loc block_lines; do
            [[ -z ${first_loc} ]] && continue
            first_path="${first_loc%%:*}"
            rest="${first_loc#*:}"
            first_start="${rest%%:*}"
            first_end="${rest#*:}"
            second_path="${second_loc%%:*}"
            rest="${second_loc#*:}"
            second_start="${rest%%:*}"
            second_end="${rest#*:}"
            detail="lines ${first_start}-${first_end} duplicate ${second_path}:${second_start}-${second_end}"
            append_hint_json "duplication_block" "${first_path}" "${detail}" "${block_lines}"
        done < "${index_file}"
    fi

    rm -rf "${tmp_dir}"
}

#######################################
# find_oversized_units: Emit oversized_unit hints for large files
#
# Globals:
#   SCAN_FILES, REFACTOR_OVERSIZED_FILE_LINES, HINTS_JSON
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
#   find_oversized_units
#
#######################################
function find_oversized_units {
    local path
    local line_count

    for path in "${SCAN_FILES[@]}"; do
        line_count="$(wc -l < "${path}" | tr -d ' ')"
        if [[ ${line_count} -gt ${REFACTOR_OVERSIZED_FILE_LINES} ]]; then
            append_hint_json "oversized_unit" "${path}" "file lines=${line_count}" "${line_count}"
        fi
    done
}

#######################################
# trim_whitespace: Remove leading and trailing whitespace
#
# Globals:
#   None
#
# Arguments:
#   $1 - Input string
#
# Outputs:
#   Trimmed string on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   value="$(trim_whitespace "${input}")"
#
#######################################
function trim_whitespace {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "${value}"
}

#######################################
# emit_error_json: Print error envelope JSON and exit 0
#
# Globals:
#   SCOPE, SINCE_REF
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
#   emit_error_json "reason"
#
#######################################
function emit_error_json {
    local message="$1"

    json_object_start
    json_field_string "status" "error" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_string "commit_range" "" ","
    json_field_bool "skip" "true" ","
    json_field_string "message" "${message}" ","
    echo '  "hints": []'
    json_object_end
}

#######################################
# emit_ok_json: Print success envelope JSON
#
# Globals:
#   HINTS_JSON, SCOPE, SINCE_REF, COMMIT_RANGE
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
#   emit_ok_json
#
#######################################
function emit_ok_json {
    local hints_arr="[]"
    local skip="true"

    if [[ ${#HINTS_JSON[@]} -gt 0 ]]; then
        hints_arr="[$(
            IFS=,
            echo "${HINTS_JSON[*]}"
        )]"
        skip="false"
    fi

    json_object_start
    json_field_string "status" "ok" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_string "commit_range" "${COMMIT_RANGE}" ","
    json_field_bool "skip" "${skip}" ","
    echo "  \"hints\": ${hints_arr}"
    json_object_end
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
    collect_scan_files
    find_duplication_blocks
    find_oversized_units
    emit_ok_json
}

main "$@"
