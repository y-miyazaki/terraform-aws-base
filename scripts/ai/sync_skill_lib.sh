#!/bin/bash
#######################################
# Description: Sync scripts/lib/ to all skill scripts/lib/ directories
#
# Usage: ./sync_skill_lib.sh [--check]
#   --check    Dry-run mode: report drift without copying (for CI)
#
# Output:
# - List of synced or drifted skill directories
# - Exit 0 if all in sync, exit 1 if drift detected (--check mode)
#
# Design Rules:
# - Source of truth: /workspace/scripts/lib/
# - Targets: all .apm/packages/*/.apm/skills/*/scripts/lib/ directories
# - Recursively discovers skills with scripts/ directory
# - Creates scripts/lib/ if scripts/ exists but lib/ does not
# - Skips skills without scripts/ directory
#
# Dependencies:
# - bash
# - rsync or cp
# - diff (for --check mode)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################
CHECK_MODE="false"
SOURCE_LIB="${SCRIPT_DIR}/../lib"
PACKAGES_DIR="${SCRIPT_DIR}/../../.apm/packages"
DRIFT_COUNT=0
SYNC_COUNT=0

#######################################
# show_usage: Display usage information
#
# Arguments:
#   None
#
# Global Variables:
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
Usage: sync_skill_lib.sh [--check]

Description:
    Sync scripts/lib/ (source of truth) to all skill scripts/lib/ directories.

Options:
    --check    Dry-run mode: report drift without copying (for CI)

Examples:
    ./sync_skill_lib.sh
    ./sync_skill_lib.sh --check
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   CHECK_MODE - Whether to run in check-only mode
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
            --check)
                CHECK_MODE="true"
                shift
                ;;
            *)
                echo "ERROR: Unknown argument: $1" >&2
                exit 1
                ;;
        esac
    done
}

#######################################
# sync_one_skill: Sync lib to a single skill's scripts/lib/
#
# Arguments:
#   $1 - Path to skill's scripts/ directory
#
# Global Variables:
#   SOURCE_LIB - Source lib directory
#   CHECK_MODE - Check-only flag
#   DRIFT_COUNT - Incremented on drift
#   SYNC_COUNT - Incremented on sync
#
# Returns:
#   None
#
# Usage:
#   sync_one_skill "/path/to/skill/scripts"
#
#######################################
function sync_one_skill {
    local target_scripts="$1"
    local target_lib="${target_scripts}/lib"
    local skill_name
    skill_name="$(basename "$(dirname "${target_scripts}")")"

    if [[ ${CHECK_MODE} == "true" ]]; then
        if [[ ! -d ${target_lib} ]]; then
            echo "  DRIFT: ${skill_name} (lib/ missing)"
            DRIFT_COUNT=$((DRIFT_COUNT + 1))
            return
        fi

        if ! diff -qr "${SOURCE_LIB}" "${target_lib}" > /dev/null 2>&1; then
            echo "  DRIFT: ${skill_name}"
            diff -qr "${SOURCE_LIB}" "${target_lib}" 2> /dev/null | sed 's/^/    /'
            DRIFT_COUNT=$((DRIFT_COUNT + 1))
        fi
    else
        mkdir -p "${target_lib}"
        rm -rf "${target_lib:?}"/*
        cp -a "${SOURCE_LIB}"/. "${target_lib}/"
        echo "  SYNCED: ${skill_name}"
        SYNC_COUNT=$((SYNC_COUNT + 1))
    fi
}

#######################################
# main: Find all skills with scripts/ and sync lib
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   None
#
# Returns:
#   0 if all in sync, 1 if drift detected in check mode
#
# Usage:
#   main "$@"
#
#######################################
function main {
    parse_arguments "$@"

    if [[ ! -d ${SOURCE_LIB} ]]; then
        echo "ERROR: Source lib not found: ${SOURCE_LIB}" >&2
        exit 1
    fi

    if [[ ! -d ${PACKAGES_DIR} ]]; then
        echo "ERROR: Packages directory not found: ${PACKAGES_DIR}" >&2
        exit 1
    fi

    if [[ ${CHECK_MODE} == "true" ]]; then
        echo "Checking lib drift..."
    else
        echo "Syncing scripts/lib to all skills..."
    fi

    local scripts_dir
    while IFS= read -r scripts_dir; do
        sync_one_skill "${scripts_dir}"
    done < <(find "${PACKAGES_DIR}" -path "*/.apm/skills/*/scripts" -type d | sort)

    echo ""
    if [[ ${CHECK_MODE} == "true" ]]; then
        if [[ ${DRIFT_COUNT} -gt 0 ]]; then
            echo "FAIL: ${DRIFT_COUNT} skill(s) have drifted lib/. Run: bash scripts/sync_skill_lib.sh"
            exit 1
        else
            echo "OK: All skill lib/ directories are in sync."
            exit 0
        fi
    else
        echo "Done: ${SYNC_COUNT} skill(s) synced."
        exit 0
    fi
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
