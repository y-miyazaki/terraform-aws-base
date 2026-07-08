#!/bin/bash
#######################################
# Description: Run deterministic waka readiness checks for a target skill.
#
# Usage: ./validate_waza.sh [options] <skill-name|SKILL.md>
#   options:
#     -h, --help     Display this help message
#     -v, --verbose  Enable verbose output
#
# Output:
# - Full waza check output for the target skill
# - waza run result for eval.yaml in the target skill
# - Token count output for the target SKILL.md file
# - Exit code 0 when all checks succeed, non-zero when any check fails
#
# Design Rules:
# - Resolve skill input deterministically (skill name or SKILL.md path)
# - Execute from <agent-root>/skills root to keep command behavior consistent
# - Require waza from PATH (no hardcoded fallback path)
# - Use shared helpers from scripts/lib/all.sh for logging and error handling
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
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables and default values
#######################################
VERBOSE=false
TARGET_INPUT=""
TARGET_SKILL_NAME=""
EVAL_FILE=""
SKILL_FILE=""
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_ROOT="$(cd "${SKILL_DIR}/.." && pwd)"

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples.
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
Usage: $(basename "$0") [options] <skill-name|SKILL.md>

Description: Run deterministic waza readiness checks for a target skill.

Arguments:
    skill-name     Skill directory name under <agent-root>/skills (for example: terraform-review)
    SKILL.md       Absolute or relative path to <agent-root>/skills/*/SKILL.md
                                 agent-root: .github, .agents, .claude, .cursor, cursor, .kiro, kiro

Options:
  -h, --help     Display this help message
  -v, --verbose  Enable verbose output

Examples:
  $(basename "$0") agent-skills-review
    $(basename "$0") .agents/skills/terraform-review/SKILL.md
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line options and validates the required target input.
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   VERBOSE - Verbose mode flag
#   TARGET_INPUT - Raw target input value
#
# Returns:
#   Exits with error if arguments are invalid
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
            -v | --verbose)
                VERBOSE=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                if [[ -n $TARGET_INPUT ]]; then
                    error_exit "Unexpected argument: $1"
                fi
                TARGET_INPUT="$1"
                shift
                ;;
        esac
    done

    if [[ -z $TARGET_INPUT ]]; then
        error_exit "Target skill is required. Use -h for usage."
    fi
}

#######################################
# resolve_target_skill: Resolve target skill name
#
# Description:
#   Resolves a target input to a concrete skill name accepted by 'waza check'.
#
# Arguments:
#   None (uses global TARGET_INPUT)
#
# Global Variables:
#   TARGET_INPUT - Raw target input value
#   TARGET_SKILL_NAME - Resolved skill directory name
#
# Returns:
#   Exits with error if input cannot be resolved to <agent-root>/skills/*
#
# Usage:
#   resolve_target_skill
#
#######################################
function resolve_target_skill {
    if [[ $TARGET_INPUT == *.md ]]; then
        local target_path
        if [[ ! -f $TARGET_INPUT ]]; then
            error_exit "SKILL.md file not found: $TARGET_INPUT"
        fi

        target_path="$(realpath "$TARGET_INPUT")"
        if [[ ! $target_path =~ /(\.github|\.agents|\.claude|\.cursor|cursor|\.kiro|kiro)/skills/([^/]+)/SKILL\.md$ ]]; then
            error_exit "Path must match <agent-root>/skills/*/SKILL.md where agent-root is one of .github,.agents,.claude,.cursor,cursor,.kiro,kiro: $target_path"
        fi

        TARGET_SKILL_NAME="${BASH_REMATCH[2]}"
    else
        TARGET_SKILL_NAME="$TARGET_INPUT"
    fi

    if [[ ! -d "${SKILLS_ROOT}/${TARGET_SKILL_NAME}" ]]; then
        error_exit "Skill directory not found: ${SKILLS_ROOT}/${TARGET_SKILL_NAME}"
    fi

    SKILL_FILE="${SKILLS_ROOT}/${TARGET_SKILL_NAME}/SKILL.md"
    EVAL_FILE="${SKILLS_ROOT}/${TARGET_SKILL_NAME}/eval.yaml"

    if [[ ! -f ${SKILL_FILE} ]]; then
        error_exit "SKILL.md not found: ${SKILL_FILE}"
    fi

    if [[ ! -f ${EVAL_FILE} ]]; then
        error_exit "eval.yaml not found: ${EVAL_FILE}"
    fi
}

#######################################
# run_waza_check: Run waza check for target skill
#
# Description:
#   Executes 'waza check <skill-name>' in the skills root directory.
#
# Arguments:
#   None (uses resolved globals)
#
# Returns:
#   Exits with non-zero status if waza check fails
#
# Usage:
#   run_waza_check
#
#######################################
function run_waza_check {
    echo_section "Running waza check for ${TARGET_SKILL_NAME}"

    if [[ $VERBOSE == "true" ]]; then
        log "INFO" "Using waza executable from PATH"
        log "INFO" "Working directory: ${SKILLS_ROOT}"
    fi

    (
        cd "${SKILLS_ROOT}" || error_exit "Failed to change directory: ${SKILLS_ROOT}"
        waza check "${TARGET_SKILL_NAME}"
    )
}

#######################################
# run_waza_eval: Run waza eval benchmark for target skill
#
# Description:
#   Executes 'waza run <eval.yaml>' for the target skill.
#
# Arguments:
#   None (uses resolved globals)
#
# Returns:
#   Exits with non-zero status if waza run fails
#
# Usage:
#   run_waza_eval
#
#######################################
function run_waza_eval {
    echo_section "Running waza eval for ${TARGET_SKILL_NAME}"

    (
        cd "${SKILLS_ROOT}" || error_exit "Failed to change directory: ${SKILLS_ROOT}"
        waza run "${EVAL_FILE}"
    )
}

#######################################
# run_waza_tokens_count: Count tokens for target SKILL.md
#
# Description:
#   Executes 'waza tokens count <SKILL.md>' for visibility of token usage.
#
# Arguments:
#   None (uses resolved globals)
#
# Returns:
#   Exits with non-zero status if token counting fails
#
# Usage:
#   run_waza_tokens_count
#
#######################################
function run_waza_tokens_count {
    echo_section "Running waza tokens count for ${TARGET_SKILL_NAME}"

    (
        cd "${SKILLS_ROOT}" || error_exit "Failed to change directory: ${SKILLS_ROOT}"
        waza tokens count "${SKILL_FILE}"
    )
}

#######################################
# main: Main process
#
# Description:
#   Parses input, resolves dependencies, and runs waza check for the target skill.
#
# Arguments:
#   $@ - Command line arguments
#
# Returns:
#   0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    validate_dependencies "realpath" "waza"
    parse_arguments "$@"
    resolve_target_skill
    run_waza_check
    run_waza_eval
    run_waza_tokens_count
}

# Entry point: only execute main if script is run directly (not sourced)
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
