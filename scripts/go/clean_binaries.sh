#!/bin/bash
#######################################
# Description: Remove Go build binary artifacts from the repository
# Recursively scans for ELF/Mach-O/PE executables and removes them,
# along with common Go build output directories (bin/, dist/, builds/).
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
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load common libraries - ALWAYS use this pattern
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables and default values
#######################################
VERBOSE=false
DRY_RUN=false
ROOT_DIR=""

# Counters
BINARY_COUNT=0
DIR_COUNT=0

# Build output directories to remove (relative to ROOT_DIR)
BUILD_DIRS=(
    "bin"
    "dist"
    "builds"
)

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and sets global variables accordingly
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Returns:
#   None (sets global variables ROOT_DIR, VERBOSE, DRY_RUN)
#
# Usage:
#   parse_arguments "$@"
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
                if [[ -z "$ROOT_DIR" ]]; then
                    ROOT_DIR="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Resolve root directory: argument > git root > pwd
    if [[ -z "$ROOT_DIR" ]]; then
        ROOT_DIR="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
    fi

    if [[ ! -d "$ROOT_DIR" ]]; then
        error_exit "Root directory not found: $ROOT_DIR"
    fi
}

#######################################
# print_summary: Print cleanup summary
#
# Description:
#   Displays a summary of removed (or would-be-removed) files and directories
#
# Arguments:
#   None (reads global BINARY_COUNT, DIR_COUNT, DRY_RUN)
#
# Returns:
#   None (outputs to stderr via log)
#
# Usage:
#   print_summary
#
#######################################
function print_summary {
    echo_section "Summary"
    local mode_label="Removed"
    [[ "$DRY_RUN" == "true" ]] && mode_label="Would remove"

    log "INFO" "${mode_label} ${BINARY_COUNT} binary file(s)"
    log "INFO" "${mode_label} ${DIR_COUNT} build directory/-ies"
}

#######################################
# remove_binary_files: Recursively find and remove ELF/Mach-O/PE binary executables
#
# Description:
#   Walks ROOT_DIR recursively, identifies binary executables via `file` command,
#   and removes them. .git/ is excluded.
#
# Arguments:
#   None (uses global ROOT_DIR, DRY_RUN, VERBOSE)
#
# Returns:
#   None (increments BINARY_COUNT)
#
# Usage:
#   remove_binary_files
#
#######################################
#######################################
# is_binary_executable: Detect if a file is a binary executable
#
# Description:
#   Uses `file` command when available, falls back to magic byte detection
#   via `od` for environments where `file` is not installed.
#   Detects ELF (Linux), Mach-O (macOS), and PE32 (Windows) executables.
#
# Arguments:
#   $1 - File path to check
#
# Returns:
#   0 if file is a binary executable, 1 otherwise
#
# Usage:
#   if is_binary_executable "/path/to/file"; then ...
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

function remove_binary_files {
    echo_section "Scanning for binary executables"

    while IFS= read -r -d '' filepath; do
        if is_binary_executable "$filepath"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log "INFO" "DRY-RUN: Would remove binary: ${filepath}"
            else
                rm -f "$filepath"
                log "INFO" "Removed binary: ${filepath}"
            fi
            ((BINARY_COUNT++)) || true
        else
            [[ "$VERBOSE" == "true" ]] && log "INFO" "Skipped (not binary executable): ${filepath}" || true
        fi
    done < <(find "$ROOT_DIR" -type f ! -path '*/.git/*' -print0)
}

#######################################
# remove_build_dirs: Remove common Go build output directories
#
# Description:
#   Removes well-known build output directories (bin/, dist/, builds/)
#   relative to ROOT_DIR.
#
# Arguments:
#   None (uses global ROOT_DIR, BUILD_DIRS, DRY_RUN, VERBOSE)
#
# Returns:
#   None (increments DIR_COUNT)
#
# Usage:
#   remove_build_dirs
#
#######################################
function remove_build_dirs {
    echo_section "Removing build output directories"

    for dir in "${BUILD_DIRS[@]}"; do
        local target="${ROOT_DIR}/${dir}"
        if [[ -d "$target" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log "INFO" "DRY-RUN: Would remove directory: ${target}"
            else
                rm -rf "$target"
                log "INFO" "Removed directory: ${target}"
            fi
            ((DIR_COUNT++)) || true
        else
            [[ "$VERBOSE" == "true" ]] && log "INFO" "Not found (skip): ${target}" || true
        fi
    done
}

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Arguments:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   show_usage
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
# main: Main function
#
# Description:
#   Entry point: parses arguments, runs cleanup, prints summary
#
# Arguments:
#   $@ - All command line arguments
#
# Returns:
#   0 on success
#
# Usage:
#   main "$@"
#
#######################################
function main {
    parse_arguments "$@"

    log "INFO" "Root directory: ${ROOT_DIR}"
    [[ "$DRY_RUN" == "true" ]] && log "INFO" "Mode: dry-run (no files will be deleted)"

    remove_build_dirs
    remove_binary_files
    print_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
