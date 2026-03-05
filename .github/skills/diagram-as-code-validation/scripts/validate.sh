#!/bin/bash
#######################################
# Description: Deterministic validation for diagram-as-code-validation SKILL.md
#
# Usage: ./validate.sh [SKILL.md]
#   arguments:
#     SKILL.md       Path to target SKILL.md file (optional)
#                    Default: ../SKILL.md
#
# Output:
# - Human-readable validation results (terminal output)
# - JSON format output for machine parsing
#
# Design Rules:
# - Validate YAML frontmatter syntax and DAC YAML structure
# - Validate required sections and YAML frontmatter fields
# - Validate word count threshold and directory structure
# - Validate DAC files with awsdac if available
# - Exit with non-zero status when any check fails
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - awk, grep, wc, mktemp (standard Unix utilities)
# - yamllint (optional, for frontmatter YAML syntax)
# - awsdac (optional, for DAC file validation)
#######################################

set -euo pipefail

umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

SKILL_FILE="${SCRIPT_DIR}/../SKILL.md"
TMP_FRONTMATTER=""
declare -a check_names=()
declare -a check_statuses=()
declare -a check_details=()
declare -a required_sections=("Purpose" "Input Specification" "Output Specification" "Execution Scope" "Constraints" "Failure Behavior")
declare -a required_fields=("name" "description" "license")

#######################################
# cleanup: Remove temporary files
#
# Description:
#   Removes the temporary frontmatter file when script exits
#
# Arguments:
#   None
#
# Returns:
#   None
#
# Usage:
#   cleanup
#
#######################################
function cleanup {
    if [[ -n "${TMP_FRONTMATTER}" ]] && [[ -f "${TMP_FRONTMATTER}" ]]; then
        rm -f "${TMP_FRONTMATTER}"
    fi
}

#######################################
# show_usage: Display script usage information
#
# Description:
#   Prints usage, options, and examples
#
# Arguments:
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
Usage: validate.sh [SKILL.md]

Description:
  Deterministic validation for github-actions-review SKILL.md.

Arguments:
  SKILL.md    Optional path to target SKILL.md
              Default: ../SKILL.md

Validation Checks:
  - YAML frontmatter syntax (yamllint, if installed)
  - Structural completeness (required H2 sections)
  - YAML frontmatter fields (name, description, license)
  - Word count threshold (< 5000)
  - Resource separation (scripts/ and reference/)

Examples:
  ./validate.sh
  ./validate.sh ../SKILL.md
  ./validate.sh /workspace/.github/skills/github-actions-review/SKILL.md
EOF
    exit 0
}

#######################################
# parse_arguments: Parse and validate command line arguments
#
# Description:
#   Parses optional SKILL.md argument and validates target path
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   SKILL_FILE - Normalized target file path
#
# Returns:
#   Exits with error when input is invalid
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
        show_usage
    fi

    if [[ $# -gt 1 ]]; then
        error_exit "Error: Too many arguments. Expected 0 or 1 argument."
    fi

    if [[ $# -eq 1 ]]; then
        SKILL_FILE="$1"
    fi

    if [[ ! -f "${SKILL_FILE}" ]]; then
        error_exit "Error: File not found: ${SKILL_FILE}"
    fi

    SKILL_FILE="$(realpath "${SKILL_FILE}")"

    if [[ ! "${SKILL_FILE}" =~ /.github/skills/.*/SKILL\.md$ ]]; then
        error_exit "Error: File must match .github/skills/*/SKILL.md: ${SKILL_FILE}"
    fi
}

#######################################
# check_frontmatter_exists: Verify YAML frontmatter markers
#
# Description:
#   Checks whether the file starts with YAML frontmatter markers
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   check_frontmatter_exists
#
#######################################
function check_frontmatter_exists {
    local marker_count
    marker_count=$(grep -c '^---$' "${SKILL_FILE}" || true)

    if [[ "${marker_count}" -ge 2 ]]; then
        check_names+=("YAML Frontmatter Markers")
        check_statuses+=("PASS")
        check_details+=("")
        echo "✓ YAML frontmatter markers found"
    else
        check_names+=("YAML Frontmatter Markers")
        check_statuses+=("FAIL")
        check_details+=("missing frontmatter markers")
        echo "✗ YAML frontmatter markers missing"
    fi
}

#######################################
# check_yaml_syntax: Validate YAML frontmatter syntax
#
# Description:
#   Extracts only frontmatter and runs yamllint against the extracted YAML
#
# Arguments:
#   None
#
# Global Variables:
#   TMP_FRONTMATTER - Temporary frontmatter file path
#
# Returns:
#   None (stores check result)
#
# Usage:
#   check_yaml_syntax
#
#######################################
function check_yaml_syntax {
    if ! command -v yamllint > /dev/null 2>&1; then
        check_names+=("YAML Frontmatter Syntax")
        check_statuses+=("SKIP")
        check_details+=("yamllint not installed")
        echo "⊘ YAML frontmatter syntax skipped (yamllint not found)"
        return
    fi

    local workspace_tmp
    workspace_tmp="/workspace/tmp"
    mkdir -p "${workspace_tmp}"
    TMP_FRONTMATTER="$(mktemp "${workspace_tmp}/github-actions-review-frontmatter.XXXXXX.yaml")"

    awk '
        BEGIN { in_frontmatter=0; marker_count=0 }
        /^---$/ {
            marker_count++
            if (marker_count == 1) { in_frontmatter=1; next }
            if (marker_count == 2) { in_frontmatter=0; exit }
        }
        in_frontmatter == 1 { print }
    ' "${SKILL_FILE}" > "${TMP_FRONTMATTER}"

    if [[ ! -s "${TMP_FRONTMATTER}" ]]; then
        check_names+=("YAML Frontmatter Syntax")
        check_statuses+=("FAIL")
        check_details+=("empty frontmatter")
        echo "✗ YAML frontmatter syntax invalid (empty frontmatter)"
        return
    fi

    if yamllint -d '{extends: default, rules: {document-start: disable, line-length: disable}}' "${TMP_FRONTMATTER}" > /dev/null 2>&1; then
        check_names+=("YAML Frontmatter Syntax")
        check_statuses+=("PASS")
        check_details+=("")
        echo "✓ YAML frontmatter syntax valid"
    else
        local yaml_errors
        yaml_errors=$(yamllint -d '{extends: default, rules: {document-start: disable, line-length: disable}}' "${TMP_FRONTMATTER}" 2>&1 || true)
        check_names+=("YAML Frontmatter Syntax")
        check_statuses+=("FAIL")
        check_details+=("${yaml_errors}")
        echo "✗ YAML frontmatter syntax invalid"
    fi
}

#######################################
# check_required_sections: Verify required H2 sections
#
# Description:
#   Ensures all required sections are present in SKILL.md
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   check_required_sections
#
#######################################
function check_required_sections {
    local missing_sections=()
    local section

    for section in "${required_sections[@]}"; do
        if ! grep -q "^## ${section}$" "${SKILL_FILE}"; then
            missing_sections+=("${section}")
        fi
    done

    if [[ ${#missing_sections[@]} -eq 0 ]]; then
        check_names+=("Structural Completeness")
        check_statuses+=("PASS")
        check_details+=("")
        echo "✓ Required sections found"
    else
        check_names+=("Structural Completeness")
        check_statuses+=("FAIL")
        check_details+=("${missing_sections[*]}")
        echo "✗ Missing sections: ${missing_sections[*]}"
    fi
}

#######################################
# check_yaml_fields: Verify required frontmatter fields
#
# Description:
#   Verifies required YAML frontmatter fields exist
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   check_yaml_fields
#
#######################################
function check_yaml_fields {
    local missing_fields=()
    local field

    for field in "${required_fields[@]}"; do
        if ! grep -q "^${field}:" "${SKILL_FILE}"; then
            missing_fields+=("${field}")
        fi
    done

    if [[ ${#missing_fields[@]} -eq 0 ]]; then
        check_names+=("YAML Frontmatter Fields")
        check_statuses+=("PASS")
        check_details+=("")
        echo "✓ YAML frontmatter fields valid"
    else
        check_names+=("YAML Frontmatter Fields")
        check_statuses+=("FAIL")
        check_details+=("${missing_fields[*]}")
        echo "✗ Missing YAML fields: ${missing_fields[*]}"
    fi
}

#######################################
# check_word_count: Validate progressive disclosure threshold
#
# Description:
#   Ensures SKILL.md word count is lower than 5000 words
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   check_word_count
#
#######################################
function check_word_count {
    local word_count
    word_count=$(wc -w < "${SKILL_FILE}")

    if [[ "${word_count}" -lt 5000 ]]; then
        check_names+=("Progressive Disclosure")
        check_statuses+=("PASS")
        check_details+=("${word_count}")
        echo "✓ Word count within limit (${word_count} < 5000)"
    else
        check_names+=("Progressive Disclosure")
        check_statuses+=("FAIL")
        check_details+=("${word_count}")
        echo "✗ Word count exceeds limit (${word_count} >= 5000)"
    fi
}

#######################################
# check_resource_separation: Verify required resource directories
#
# Description:
#   Ensures scripts/ and reference/ directories exist under skill directory
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   check_resource_separation
#
#######################################
function check_resource_separation {
    local skill_dir
    local missing_dirs=()

    skill_dir="$(dirname "${SKILL_FILE}")"

    if [[ ! -d "${skill_dir}/scripts" ]]; then
        missing_dirs+=("scripts/")
    fi

    if [[ ! -d "${skill_dir}/reference" ]]; then
        missing_dirs+=("reference/")
    fi

    if [[ ${#missing_dirs[@]} -eq 0 ]]; then
        check_names+=("Resource Separation")
        check_statuses+=("PASS")
        check_details+=("")
        echo "✓ Required directories found (scripts/, reference/)"
    else
        check_names+=("Resource Separation")
        check_statuses+=("FAIL")
        check_details+=("${missing_dirs[*]}")
        echo "✗ Missing directories: ${missing_dirs[*]}"
    fi
}

#######################################
# validate_dac_files: Validate DAC YAML files and awsdac generation
#
# Description:
#   Checks DAC files in workspace root and validates with awsdac
#   If no DAC files found, skips validation
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   validate_dac_files
#
#######################################
function validate_dac_files {
    # Check if awsdac is available
    if ! command -v awsdac > /dev/null 2>&1; then
        check_names+=("DAC File Validation")
        check_statuses+=("SKIP")
        check_details+=("awsdac not installed")
        echo "⊘ DAC file validation skipped (awsdac not found)"
        return
    fi

    # Find DAC files in workspace
    local dac_files
    dac_files=$(find /workspace -maxdepth 1 -name "aws_architecture_diagram*.yaml" -o -name "aws_architecture_diagram*.yml" 2> /dev/null | head -5)

    if [[ -z "${dac_files}" ]]; then
        check_names+=("DAC File Validation")
        check_statuses+=("SKIP")
        check_details+=("no DAC files found")
        echo "⊘ DAC file validation skipped (no DAC files in workspace root)"
        return
    fi

    # Test awsdac generation
    local workspace_tmp
    workspace_tmp="/workspace/tmp"
    mkdir -p "${workspace_tmp}"
    local test_output
    test_output="${workspace_tmp}/dac-test-output.png"

    local first_dac_file
    first_dac_file=$(echo "${dac_files}" | head -1)

    if awsdac -d "${first_dac_file}" -o "${test_output}" > /dev/null 2>&1; then
        if [[ -f "${test_output}" ]]; then
            rm -f "${test_output}"
            check_names+=("DAC File Validation")
            check_statuses+=("PASS")
            check_details+=("awsdac generation successful")
            echo "✓ DAC files validate with awsdac"
        else
            check_names+=("DAC File Validation")
            check_statuses+=("FAIL")
            check_details+=("awsdac did not generate output")
            echo "✗ DAC file validation failed (no output generated)"
        fi
    else
        check_names+=("DAC File Validation")
        check_statuses+=("FAIL")
        check_details+=("awsdac generation error")
        echo "✗ DAC file validation failed (awsdac error)"
    fi
}

#######################################
# print_json_results: Print machine-readable JSON output
#
# Description:
#   Prints validation results in JSON format
#
# Arguments:
#   $1 - Overall status (PASS/FAIL)
#
# Returns:
#   None
#
# Usage:
#   print_json_results "PASS"
#
#######################################
function print_json_results {
    local overall_status="$1"
    local i

    echo
    echo "#--------------------------------------------------------------"
    echo "# JSON Output"
    echo "#--------------------------------------------------------------"
    echo "{"
    echo '  "validation_results": ['

    for i in "${!check_names[@]}"; do
        local comma=""
        if [[ "${i}" -lt $((${#check_names[@]} - 1)) ]]; then
            comma=","
        fi

        printf '    {"check": "%s", "status": "%s", "detail": "%s"}%s\n' \
            "${check_names[${i}]//\"/\\\"}" \
            "${check_statuses[${i}]//\"/\\\"}" \
            "${check_details[${i}]//\"/\\\"}" \
            "${comma}"
    done

    echo "  ],"
    echo "  \"overall_status\": \"${overall_status}\""
    echo "}"
}

#######################################
# main: Run validation checks
#
# Description:
#   Parses arguments, executes all checks, prints summary and JSON output
#
# Arguments:
#   $@ - Command line arguments
#
# Returns:
#   0 when all checks pass, 1 otherwise
#
# Usage:
#   main "$@"
#
#######################################
function main {
    trap cleanup EXIT

    parse_arguments "$@"

    check_frontmatter_exists
    check_yaml_syntax
    check_required_sections
    check_yaml_fields
    check_word_count
    check_resource_separation
    validate_dac_files

    local overall_status="PASS"
    local status
    for status in "${check_statuses[@]}"; do
        if [[ "${status}" == "FAIL" ]]; then
            overall_status="FAIL"
            break
        fi
    done

    print_json_results "${overall_status}"

    if [[ "${overall_status}" == "FAIL" ]]; then
        exit 1
    fi

    exit 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
