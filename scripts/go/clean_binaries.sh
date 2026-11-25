#!/bin/bash
#######################################
# Description: Remove Go build binary artifacts from the repository
# Recursively scans for ELF/Mach-O/PE executables and removes them,
# along with common Go build output directories (bin/, dist/, builds/).
# Files tracked by git are never removed.
#
# Usage: ./clean_binaries.sh [options] [root_dir]
#   options:
#     -h, --help      Display this help message
#     -v, --verbose   Enable verbose output
#     -d, --dry-run   Show files that would be removed without deleting
#   arguments:
#     root_dir        Root directory to scan (default: git root or current dir)
#
# Output:
# - Removed binary files listed to stdout
# - Removed build directories listed to stdout
#
# Design Rules:
# - Rule 1: Binary detection uses `file` command (ELF/Mach-O/PE), falls back to magic bytes via `od` -- name-agnostic
# - Rule 2: .git/ directory is always excluded from scan
# - Rule 3: Dry-run mode never deletes; shows what would be removed
# - Rule 4: Files tracked by git are never removed (they are sources, not build artifacts)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################
VERBOSE=false
DRY_RUN=false
ROOT_DIR=""

# Counters
BINARY_COUNT=0
DIR_COUNT=0

# Paths (relative to ROOT_DIR) tracked by git; never removed
declare -A TRACKED_FILES=()
TRACKED_LOADED=false

# Build output directories to remove (relative to ROOT_DIR)
BUILD_DIRS=(
    "bin"
    "dist"
    "builds"
)

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Writes to stdout
#
# Returns:
#   None
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options] [root_dir]

Description: Remove Go build binary artifacts from the repository.
             Recursively scans for ELF/Mach-O/PE executables and removes them,
             along with common build output directories (bin/, dist/, builds/).

Options:
  -h, --help      Display this help message
  -v, --verbose   Enable verbose output
  -d, --dry-run   Show files that would be removed without deleting

Arguments:
  root_dir        Root directory to scan
                  If not provided, uses git repository root or current directory

Examples:
  $(basename "$0")                        # Remove binaries from git root
  $(basename "$0") --dry-run              # Preview what would be removed
  $(basename "$0") --verbose              # Remove with detailed output
  $(basename "$0") /path/to/repo          # Remove from specific directory
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables accordingly
#
# Globals:
#   ROOT_DIR - Root directory to scan
#   VERBOSE - Enable verbose output
#   DRY_RUN - Enable dry-run mode
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
#
# Returns:
#   None (sets global variables ROOT_DIR, VERBOSE, DRY_RUN)
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                show_usage
                ;;
            -v | --verbose)
                VERBOSE=true
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                if [[ -z $ROOT_DIR ]]; then
                    ROOT_DIR="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Resolve root directory: argument > git root > pwd
    if [[ -z $ROOT_DIR ]]; then
        ROOT_DIR="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
    fi

    if [[ ! -d $ROOT_DIR ]]; then
        error_exit "Root directory not found: $ROOT_DIR"
    fi

    # Refuse roots where a recursive binary sweep would be destructive
    ROOT_DIR="$(cd "$ROOT_DIR" && pwd -P)"
    if [[ $ROOT_DIR == "/" || $ROOT_DIR == "${HOME:-}" ]]; then
        error_exit "Refusing to clean unsafe root directory: $ROOT_DIR"
    fi
}

#######################################
# is_binary_executable: Detect if a file is a binary executable
#
# Description:
#   Uses `file` command when available, falls back to magic byte detection
#   via `od` for environments where `file` is not installed.
#   Detects ELF (Linux), Mach-O (macOS), and PE32 (Windows) executables.
#
# Globals:
#   None
#
# Arguments:
#   $1 - File path to check
#
# Outputs:
#   None
#
# Returns:
#   0 if file is a binary executable, 1 otherwise
#
#######################################
function is_binary_executable {
    local filepath="$1"

    # Prefer `file` command when available
    if command -v file > /dev/null 2>&1; then
        local file_type
        file_type="$(file --brief "$filepath" 2> /dev/null || true)"
        if echo "$file_type" | grep -qE "^ELF.*executable|^Mach-O.*executable|^PE32.*executable"; then
            return 0
        fi
        return 1
    fi

    # Fallback: detect via magic bytes using `od`
    local magic
    magic="$(od -A n -t x1 -N 4 "$filepath" 2> /dev/null | tr -d ' ')" || return 1

    case "$magic" in
        7f454c46) return 0 ;;                                  # ELF
        feedface | feedfacf | cefaedfe | cffaedfe) return 0 ;; # Mach-O
        4d5a*) return 0 ;;                                     # PE (MZ header)
    esac
    return 1
}

#######################################
# load_tracked_files: Load git-tracked paths so they are never removed
#
# Description:
#   Fills TRACKED_FILES with the paths git tracks under ROOT_DIR
#   (relative to ROOT_DIR, submodule contents included) once per run. Does nothing when ROOT_DIR is not in
#   a git work tree; exits when ROOT_DIR holds a .git that git cannot read.
#
# Globals:
#   ROOT_DIR - Root directory to scan
#   TRACKED_FILES - Populated (associative array, key = relative path)
#   TRACKED_LOADED - Set once the list was loaded
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
function load_tracked_files {
    [[ $TRACKED_LOADED == "true" ]] && return 0

    TRACKED_FILES=()
    if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        # A repository git cannot read (dubious ownership, missing git) must not be swept blindly
        local ancestor="$ROOT_DIR"
        while true; do
            if [[ -e "${ancestor}/.git" ]]; then
                error_exit "Cannot determine git-tracked files in ${ROOT_DIR}; refusing to delete"
            fi
            [[ $ancestor == "/" ]] && break
            ancestor="$(dirname "$ancestor")"
        done
        TRACKED_LOADED=true
        return 0
    fi

    # NUL-separated so that paths containing newlines stay one key; the list goes through a temp
    # file so that a failing git ls-files is noticed instead of being hidden by a pipe
    local tracked list_file
    list_file="$(mktemp)"
    if ! git -C "$ROOT_DIR" ls-files -z --recurse-submodules > "$list_file"; then
        rm -f "$list_file"
        error_exit "git ls-files failed in ${ROOT_DIR}"
    fi
    while IFS= read -r -d '' tracked; do
        TRACKED_FILES["$tracked"]=1
    done < "$list_file"
    rm -f "$list_file"
    TRACKED_LOADED=true
}

#######################################
# print_summary: Print cleanup summary
#
# Description:
#   Displays a summary of removed (or would-be-removed) files and directories
#
# Globals:
#   BINARY_COUNT - Number of binary files removed
#   DIR_COUNT - Number of directories removed
#   DRY_RUN - Whether running in dry-run mode
#
# Arguments:
#   None
#
# Outputs:
#   None (outputs to stderr via log)
#
# Returns:
#   0 on success
#
#######################################
function print_summary {
    echo_section "Summary"
    local mode_label="Removed"
    [[ $DRY_RUN == "true" ]] && mode_label="Would remove"

    log "INFO" "${mode_label} ${BINARY_COUNT} binary file(s)"
    log "INFO" "${mode_label} ${DIR_COUNT} build directory/-ies"
}

#######################################
# remove_binary_files: Recursively find and remove ELF/Mach-O/PE binary executables
#
# Description:
#   Walks ROOT_DIR recursively, identifies binary executables via `file` command,
#   and removes them. .git/ is excluded and files tracked by git are skipped.
#
# Globals:
#   ROOT_DIR - Root directory to scan
#   TRACKED_FILES - Git-tracked paths that are skipped
#   DRY_RUN - Whether running in dry-run mode
#   VERBOSE - Whether to show verbose output
#   BINARY_COUNT - Incremented for each binary found
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None (increments BINARY_COUNT)
#
#######################################
function remove_binary_files {
    echo_section "Scanning for binary executables"

    load_tracked_files

    while IFS= read -r -d '' filepath; do
        if [[ -n ${TRACKED_FILES["${filepath#"${ROOT_DIR}"/}"]+x} ]]; then
            if [[ $VERBOSE == "true" ]]; then
                log "INFO" "Skipped (tracked by git): ${filepath}"
            fi
            continue
        fi
        if is_binary_executable "$filepath"; then
            if [[ $DRY_RUN == "true" ]]; then
                log "INFO" "DRY-RUN: Would remove binary: ${filepath}"
            else
                rm -f "$filepath"
                log "INFO" "Removed binary: ${filepath}"
            fi
            ((BINARY_COUNT++)) || true
        else
            if [[ $VERBOSE == "true" ]]; then
                log "INFO" "Skipped (not binary executable): ${filepath}"
            fi
        fi
    done < <(find "$ROOT_DIR" -type f ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/.venv/*' -print0)
}

#######################################
# remove_build_dirs: Remove common Go build output directories
#
# Description:
#   Removes well-known build output directories (bin/, dist/, builds/)
#   relative to ROOT_DIR. A directory holding files tracked by git keeps those
#   files; only its untracked content is removed.
#
# Globals:
#   ROOT_DIR - Root directory to scan
#   BUILD_DIRS - Array of directories to remove
#   TRACKED_FILES - Git-tracked paths; directories containing any are skipped
#   DRY_RUN - Whether running in dry-run mode
#   VERBOSE - Whether to show verbose output
#   DIR_COUNT - Incremented for each directory removed
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None (increments DIR_COUNT)
#
#######################################
function remove_build_dirs {
    echo_section "Removing build output directories"

    load_tracked_files

    for dir in "${BUILD_DIRS[@]}"; do
        local target="${ROOT_DIR}/${dir}"
        if [[ -d $target ]]; then
            local tracked
            for tracked in "${!TRACKED_FILES[@]}"; do
                if [[ $tracked == "${dir}/"* ]]; then
                    remove_untracked_in_dir "$dir" "$target"
                    continue 2
                fi
            done
            if [[ $DRY_RUN == "true" ]]; then
                log "INFO" "DRY-RUN: Would remove directory: ${target}"
            else
                rm -rf "$target"
                log "INFO" "Removed directory: ${target}"
            fi
            ((DIR_COUNT++)) || true
        else
            if [[ $VERBOSE == "true" ]]; then
                log "INFO" "Not found (skip): ${target}"
            fi
        fi
    done
}

#######################################
# remove_untracked_in_dir: Remove untracked files from a directory holding tracked files
#
# Description:
#   Removes every file or link under the directory that git does not track, then
#   prunes directories left empty. Tracked files stay in place.
#
# Globals:
#   ROOT_DIR - Root directory to scan
#   TRACKED_FILES - Git-tracked paths that are kept
#   DRY_RUN - Whether running in dry-run mode
#
# Arguments:
#   $1 - Directory relative to ROOT_DIR
#   $2 - Absolute directory path
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function remove_untracked_in_dir {
    local rel_dir="$1"
    local target="$2"
    local filepath

    log "INFO" "Keeping ${rel_dir}/ (contains files tracked by git); removing its untracked content only"

    while IFS= read -r -d '' filepath; do
        if [[ -n ${TRACKED_FILES["${filepath#"${ROOT_DIR}"/}"]+x} ]]; then
            continue
        fi
        if [[ $DRY_RUN == "true" ]]; then
            log "INFO" "DRY-RUN: Would remove untracked file: ${filepath}"
        else
            rm -f "$filepath"
            log "INFO" "Removed untracked file: ${filepath}"
        fi
    done < <(find "$target" ! -type d -print0)

    if [[ $DRY_RUN != "true" ]]; then
        find "$target" -mindepth 1 -type d -empty -delete
    fi
}

#######################################
# main: Main function
#
# Description:
#   Entry point: parses arguments, runs cleanup, prints summary
#
# Globals:
#   None
#
# Arguments:
#   $@ - All command line arguments
#
# Outputs:
#   None
#
# Returns:
#   0 on success
#
#######################################
function main {
    parse_arguments "$@"

    log "INFO" "Root directory: ${ROOT_DIR}"
    [[ $DRY_RUN == "true" ]] && log "INFO" "Mode: dry-run (no files will be deleted)"

    remove_build_dirs
    remove_binary_files
    print_summary
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
