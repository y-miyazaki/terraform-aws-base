#!/bin/bash
#######################################
# Description:
#   Reorder function documentation blocks to canonical section order:
#   Globals, Arguments, Outputs, Returns.
#
# Usage:
#   bash fix_function_doc_order.sh [OPTIONS] [path1 path2 ...]
#
#   Each path may be a shell script file or a directory (recursively processes *.sh
#   and executable non-.sh files with a shell shebang).
#
# Options:
#   -h, --help     Display this help message
#   -n, --dry-run  Print changes without modifying files
#   -q, --quiet    Suppress non-error output
#
# Output:
#   Writes updated script content to each target file (unless --dry-run).
#
# Returns:
#   0 when all targets are already canonical or were fixed successfully.
#   1 when a target could not be processed.
#
# Design Rules:
# - Preserve non-section comment lines inside each function doc block
# - Only rewrite blocks that declare at least one canonical section header
# - Leave files unchanged when already canonical (unless reporting dry-run)
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
DRY_RUN=false
QUIET=false
declare -a TARGET_PATHS=()
readonly CANONICAL_SECTIONS=(Globals Arguments Outputs Returns)
readonly SEPARATOR='#######################################'
declare -a FIX_DOC_TEMP_FILES=()

#######################################
# cleanup_fix_doc_temp_files: Remove tracked temporary files
#
# Globals:
#   FIX_DOC_TEMP_FILES
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#######################################
function cleanup_fix_doc_temp_files {
    local f
    for f in "${FIX_DOC_TEMP_FILES[@]}"; do
        rm -f "${f}"
    done
}
trap cleanup_fix_doc_temp_files EXIT

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
#   Writes usage text to stdout.
#
# Returns:
#   None
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [path1 path2 ...]

Reorder function doc blocks to: Globals, Arguments, Outputs, Returns.

Options:
  -h, --help     Display this help message
  -n, --dry-run  Print changes without modifying files
  -q, --quiet    Suppress non-error output

Examples:
  $(basename "$0") scripts/lib/common.sh
  $(basename "$0") --dry-run scripts/shell-script
EOF
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   DRY_RUN
#   QUIET
#   TARGET_PATHS
#
# Arguments:
#   $@
#
# Outputs:
#   None
#
# Returns:
#   None
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                exit 0
                ;;
            -n | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -q | --quiet)
                QUIET=true
                shift
                ;;
            --)
                shift
                TARGET_PATHS+=("$@")
                break
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                TARGET_PATHS+=("$1")
                shift
                ;;
        esac
    done
}

#######################################
# block_needs_reorder: Detect non-canonical section order in a block
#
# Globals:
#   None
#
# Arguments:
#   $1 - Path to block lines temp file
#
# Outputs:
#   None
#
# Returns:
#   0 when reorder is needed, 1 when already canonical.
#######################################
function block_needs_reorder {
    local block_file="$1"
    local last_index=-1
    local line

    while IFS= read -r line || [[ -n $line ]]; do
        if ! is_section_header "$line"; then
            continue
        fi
        local name
        name="$(section_name_from_header "$line")"
        if ! is_canonical_section "$name"; then
            continue
        fi
        local current_index
        current_index="$(canonical_order_index "$name")"
        if [[ $current_index -le $last_index ]]; then
            return 0
        fi
        last_index=$current_index
    done < "$block_file"

    return 1
}

#######################################
# canonical_order_index: Return canonical index for a section name
#
# Globals:
#   CANONICAL_SECTIONS
#
# Arguments:
#   $1 - Section name
#
# Outputs:
#   Index to stdout, or -1 when not canonical.
#
# Returns:
#   0 on success.
#######################################
function canonical_order_index {
    local name="$1"
    local index=0
    local section

    for section in "${CANONICAL_SECTIONS[@]}"; do
        if [[ $section == "$name" ]]; then
            echo "$index"
            return 0
        fi
        index=$((index + 1))
    done
    echo "-1"
}

#######################################
# expand_target_paths: Expand a file or directory into shell script paths
#
# Globals:
#   None
#
# Arguments:
#   $1 - File or directory path
#
# Outputs:
#   Shell script paths to stdout (one per line)
#
# Returns:
#   0 on success, 1 when path does not exist
#######################################
function expand_target_paths {
    local target="$1"
    local -a scripts=()
    local script entry already

    if [[ -f $target ]]; then
        printf '%s\0' "$target"
        return 0
    fi

    if [[ ! -d $target ]]; then
        error_exit "File not found: $target"
    fi

    while IFS= read -r -d '' script; do
        scripts+=("$script")
    done < <(find "$target" -type f -name "*.sh" -print0 2> /dev/null)

    while IFS= read -r -d '' script; do
        if [[ -f $script ]] && head -1 "$script" 2> /dev/null | grep -q "^#!/.*sh"; then
            already=false
            for entry in "${scripts[@]}"; do
                if [[ $entry == "$script" ]]; then
                    already=true
                    break
                fi
            done
            if [[ $already == "false" ]]; then
                scripts+=("$script")
            fi
        fi
    done < <(find "$target" -type f ! -name "*.sh" -executable -print0 2> /dev/null)

    for entry in "${scripts[@]}"; do
        printf '%s\0' "$entry"
    done
}

#######################################
# is_canonical_section: Test whether a section name is canonical
#
# Globals:
#   CANONICAL_SECTIONS
#
# Arguments:
#   $1 - Section name
#
# Outputs:
#   None
#
# Returns:
#   0 when canonical, 1 otherwise.
#######################################
function is_canonical_section {
    local name="$1"
    local section

    for section in "${CANONICAL_SECTIONS[@]}"; do
        if [[ $section == "$name" ]]; then
            return 0
        fi
    done
    return 1
}

#######################################
# is_section_header: Test whether a line is a section header
#
# Globals:
#   None
#
# Arguments:
#   $1 - Line to test
#
# Outputs:
#   None
#
# Returns:
#   0 when the line is a section header, 1 otherwise.
#######################################
function is_section_header {
    [[ $1 =~ ^#\ [A-Za-z][A-Za-z\ ]*:[[:space:]]*$ ]]
}

#######################################
# process_file: Reorder function doc blocks in one script file
#
# Globals:
#   DRY_RUN
#   QUIET
#   SEPARATOR
#
# Arguments:
#   $1 - Script path
#
# Outputs:
#   Status messages to stderr unless quiet.
#
# Returns:
#   0 on success, 1 on failure.
#######################################
function process_file {
    local script="$1"
    local -a input_lines=()
    local -a output_lines=()
    local -a block_lines=()
    local changed=false
    local line
    local index

    if [[ ! -f $script ]]; then
        error_exit "File not found: $script"
    fi

    mapfile -t input_lines < "$script"

    index=0
    while [[ $index -lt ${#input_lines[@]} ]]; do
        line="${input_lines[$index]}"

        if [[ $line == "$SEPARATOR" ]]; then
            local start_index=$((index + 1))
            local end_index=$start_index
            local next_is_function=false

            while [[ $end_index -lt ${#input_lines[@]} && ${input_lines[$end_index]} != "$SEPARATOR" ]]; do
                end_index=$((end_index + 1))
            done

            if [[ $end_index -lt ${#input_lines[@]} ]]; then
                local after_sep_index=$((end_index + 1))
                if [[ $after_sep_index -lt ${#input_lines[@]} ]] && [[ ${input_lines[$after_sep_index]} =~ ^function\  ]]; then
                    next_is_function=true
                fi
            fi

            if [[ $next_is_function == "true" ]]; then
                block_lines=()
                local block_index=$start_index
                while [[ $block_index -lt $end_index ]]; do
                    block_lines+=("${input_lines[$block_index]}")
                    block_index=$((block_index + 1))
                done

                local block_file
                block_file="$(mktemp)"
                FIX_DOC_TEMP_FILES+=("${block_file}")
                if [[ ${#block_lines[@]} -gt 0 ]]; then
                    printf '%s\n' "${block_lines[@]}" > "$block_file"
                else
                    : > "$block_file"
                fi

                output_lines+=("$SEPARATOR")
                if block_needs_reorder "$block_file"; then
                    changed=true
                    mapfile -t block_lines < <(reorder_doc_block "$block_file")
                fi
                if [[ ${#block_lines[@]} -gt 0 ]]; then
                    output_lines+=("${block_lines[@]}")
                fi
                output_lines+=("$SEPARATOR")
                rm -f "$block_file"

                index=$((end_index + 1))
                if [[ $index -lt ${#input_lines[@]} ]]; then
                    output_lines+=("${input_lines[$index]}")
                    index=$((index + 1))
                fi
                continue
            fi
        fi

        output_lines+=("$line")
        index=$((index + 1))
    done

    if [[ $changed != "true" ]]; then
        [[ $QUIET != "true" ]] && log "INFO" "No function doc reorder needed: $script"
        return 0
    fi

    if [[ $DRY_RUN == "true" ]]; then
        [[ $QUIET != "true" ]] && log "INFO" "Would reorder function docs: $script"
        return 0
    fi

    local output_file
    output_file="$(mktemp)"
    FIX_DOC_TEMP_FILES+=("${output_file}")
    printf '%s\n' "${output_lines[@]}" > "$output_file"
    mv "$output_file" "$script"
    rm -f "$output_file"
    [[ $QUIET != "true" ]] && log "INFO" "Reordered function docs: $script"
    return 0
}

#######################################
# reorder_doc_block: Reorder one function documentation block
#
# Globals:
#   CANONICAL_SECTIONS
#
# Arguments:
#   $1 - Path to a temp file containing block lines without separators
#
# Outputs:
#   Reordered block lines to stdout.
#
# Returns:
#   0 on success.
#######################################
function reorder_doc_block {
    local block_file="$1"
    local -a lines=()
    local -a preamble=()
    local -a before_sections=()
    local -a after_sections=()
    local -a current_section=()
    local current_name=""
    local current_kind="preamble"
    local saw_canonical=false
    local line

    mapfile -t lines < "$block_file"

    flush_section() {
        if [[ ${#current_section[@]} -eq 0 ]]; then
            return 0
        fi
        case "$current_kind" in
            preamble)
                preamble+=("${current_section[@]}")
                ;;
            before)
                before_sections+=("${current_section[@]}")
                ;;
            after)
                after_sections+=("${current_section[@]}")
                ;;
            canonical)
                :
                ;;
        esac
        current_section=()
    }

    for line in "${lines[@]}"; do
        if is_section_header "$line"; then
            flush_section
            current_name="$(section_name_from_header "$line")"
            current_section=("$line")
            if is_canonical_section "$current_name"; then
                current_kind="canonical"
                saw_canonical=true
            elif [[ $saw_canonical == "false" ]]; then
                current_kind="before"
            else
                current_kind="after"
            fi
        else
            current_section+=("$line")
        fi
    done
    flush_section

    declare -A canon_lines=()
    current_name=""
    current_section=()
    current_kind="preamble"

    store_canonical_block() {
        if [[ $current_kind != "canonical" || -z $current_name ]]; then
            return 0
        fi
        local serialized=""
        local entry
        for entry in "${current_section[@]}"; do
            serialized+="${entry}"$'\n'
        done
        canon_lines["$current_name"]="$serialized"
    }

    for line in "${lines[@]}"; do
        if is_section_header "$line"; then
            store_canonical_block
            current_name="$(section_name_from_header "$line")"
            current_section=("$line")
            if is_canonical_section "$current_name"; then
                current_kind="canonical"
            else
                current_kind="other"
                current_name=""
                current_section=()
            fi
        elif [[ $current_kind == "canonical" ]]; then
            current_section+=("$line")
        fi
    done
    store_canonical_block

    if [[ ${#preamble[@]} -gt 0 ]]; then
        printf '%s\n' "${preamble[@]}"
    fi
    if [[ ${#before_sections[@]} -gt 0 ]]; then
        printf '%s\n' "${before_sections[@]}"
    fi
    local section
    for section in "${CANONICAL_SECTIONS[@]}"; do
        if [[ -n ${canon_lines[$section]+x} ]]; then
            printf '%s' "${canon_lines[$section]}"
        fi
    done
    if [[ ${#after_sections[@]} -gt 0 ]]; then
        printf '%s\n' "${after_sections[@]}"
    fi
}

#######################################
# section_name_from_header: Extract section name from a header line
#
# Globals:
#   None
#
# Arguments:
#   $1 - Section header line
#
# Outputs:
#   Section name to stdout.
#
# Returns:
#   0 on success.
#######################################
function section_name_from_header {
    local line="$1"
    line="${line#\# }"
    line="${line%:}"
    printf '%s' "$line"
}

#######################################
# main: Entry point
#
# Globals:
#   TARGET_PATHS
#
# Arguments:
#   $@
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure.
#######################################
function main {
    parse_arguments "$@"

    if [[ ${#TARGET_PATHS[@]} -eq 0 ]]; then
        show_usage
        exit 1
    fi

    local target script
    for target in "${TARGET_PATHS[@]}"; do
        if [[ ! -e $target ]]; then
            error_exit "File not found: $target"
        fi
        while IFS= read -r -d '' script; do
            if ! process_file "$script"; then
                exit 1
            fi
        done < <(expand_target_paths "$target")
    done
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
