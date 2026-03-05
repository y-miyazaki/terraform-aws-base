#!/bin/bash
#######################################
# Description: Deterministic validation for Agent Skills SKILL.md files
#
# Usage: ./validate.sh [SKILL.md]
#   arguments:
#     SKILL.md       Path to SKILL.md file to validate (required)
#
# Output:
# - Human-readable validation results (terminal output)
# - JSON format output for machine parsing
#
# Design Rules:
# - Validates structural completeness and resource organization
# - Input path must match .github/skills/*/SKILL.md pattern
# - Normalizes paths with realpath to prevent path traversal
# - Uses secure defaults (umask 027)
# - Outputs structured JSON for automation
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - grep, wc (standard Unix utilities)
# - yamllint (optional, for YAML syntax validation)
#
# Examples:
#   ./validate.sh .github/skills/agent-skills-review/SKILL.md
#   ./validate.sh /workspace/.github/skills/go-validation/SKILL.md
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
SKILL_FILE=""
declare -a check_names=()
declare -a check_statuses=()
declare -a check_details_json=()
declare -a required_sections=("Purpose" "When to Use This Skill" "Input Specification" "Output Specification" "Execution Scope" "Constraints" "Failure Behavior" "Reference Files Guide" "Workflow")
declare -a required_fields=("name" "description" "license")

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
Usage: $(basename "$0") <SKILL.md>

Description: Deterministic validation for Agent Skills SKILL.md files
             Validates structural completeness and resource organization

Arguments:
  SKILL.md       Path to SKILL.md file to validate (required)
                 Must match pattern: .github/skills/*/SKILL.md

Validation Checks:
  - Structural Completeness: 9 required sections exist
  - YAML Frontmatter Fields: name, description, license fields present
  - Progressive Disclosure: word count < 5,000
  - Resource Separation: scripts/ and reference/ directories exist
  - Reference Mandatory Files: common-checklist.md and common-output-format.md exist

Output Format:
  - Human-readable colored terminal output
  - JSON format for machine parsing

Examples:
  $(basename "$0") .github/skills/agent-skills-review/SKILL.md
  $(basename "$0") /workspace/.github/skills/go-validation/SKILL.md
EOF
    exit 0
}

#######################################
# parse_arguments: Parse and validate command line arguments
#
# Description:
#   Parses command line arguments, validates input, and normalizes paths
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file (normalized with realpath)
#
# Returns:
#   Exits with error if validation fails
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    # Handle help flag
    if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
        show_usage
    fi

    # Validate argument count
    if [[ $# -ne 1 ]]; then
        error_exit "Error: Exactly one argument required (SKILL.md path)"
    fi

    local input_path="$1"

    # Validate file existence before normalization
    if [[ ! -f "$input_path" ]]; then
        error_exit "Error: File not found: $input_path"
    fi

    # Validate file extension
    if [[ ! "$input_path" =~ \.md$ ]]; then
        error_exit "Error: File must have .md extension: $input_path"
    fi

    # Normalize path to prevent path traversal (SEC-03)
    SKILL_FILE="$(realpath "$input_path")"

    # Validate path matches expected pattern (SEC-01)
    if [[ ! "$SKILL_FILE" =~ /.github/skills/.*/SKILL\.md$ ]]; then
        error_exit "Error: File must be in .github/skills/*/SKILL.md structure: $SKILL_FILE"
    fi
}

#######################################
# check_yaml_syntax: Validate YAML syntax with yamllint
#
# Description:
#   Runs yamllint on SKILL.md to validate YAML frontmatter syntax
#   Checks that YAML is well-formed and follows basic rules
#
# Arguments:
#   None (uses global SKILL_FILE)
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file
#   check_names - Array of check names
#   check_statuses - Array of check statuses
#   check_details_json - Array of check details
#
# Returns:
#   None (stores validation results in arrays)
#
# Usage:
#   check_yaml_syntax
#
#######################################
function check_yaml_syntax {
    # Check if yamllint is available
    if ! command -v yamllint &> /dev/null; then
        echo "⊘ YAML syntax validation skipped (yamllint not found)"
        check_names+=("YAML Syntax")
        check_statuses+=("SKIP")
        check_details_json+=("yamllint not installed")
        return
    fi

    local tmp_frontmatter
    mkdir -p /workspace/tmp
    tmp_frontmatter="$(mktemp /workspace/tmp/agent-skill-frontmatter.XXXXXX.yaml)"

    # Extract only frontmatter block between the first two --- markers.
    awk '
        BEGIN { in_frontmatter=0; marker_count=0 }
        /^---$/ {
            marker_count++
            if (marker_count == 1) { in_frontmatter=1; next }
            if (marker_count == 2) { in_frontmatter=0; exit }
        }
        in_frontmatter == 1 { print }
    ' "$SKILL_FILE" > "$tmp_frontmatter"

    if [[ ! -s "$tmp_frontmatter" ]]; then
        rm -f "$tmp_frontmatter"
        echo "✗ YAML syntax errors detected"
        check_names+=("YAML Syntax")
        check_statuses+=("FAIL")
        check_details_json+=("empty frontmatter")
        return
    fi

    if yamllint -d '{extends: default, rules: {document-start: disable, line-length: disable}}' "$tmp_frontmatter" > /dev/null 2>&1; then
        rm -f "$tmp_frontmatter"
        echo "✓ YAML syntax valid"
        check_names+=("YAML Syntax")
        check_statuses+=("PASS")
        check_details_json+=("")
    else
        local yaml_errors
        yaml_errors=$(yamllint -d '{extends: default, rules: {document-start: disable, line-length: disable}}' "$tmp_frontmatter" 2>&1 || true)
        rm -f "$tmp_frontmatter"
        echo "✗ YAML syntax errors detected"
        check_names+=("YAML Syntax")
        check_statuses+=("FAIL")
        check_details_json+=("$yaml_errors")
    fi
}

#######################################
#
# Description:
#   Verifies that SKILL.md contains all 9 required sections:
#   Purpose, When to Use This Skill, Input Specification, Output Specification,
#   Execution Scope, Constraints, Failure Behavior, Reference Files Guide, Workflow
#
# Arguments:
#   None (uses global SKILL_FILE)
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file
#   results - Associative array to store check results
#   required_sections - Array of required section names
#
# Returns:
#   None (stores validation results in results array)
#
# Usage:
#   check_structural_completeness
#
#######################################
function check_structural_completeness {
    local missing_sections=()

    for section in "${required_sections[@]}"; do
        if ! grep -q "^## $section$" "$SKILL_FILE" 2> /dev/null; then
            missing_sections+=("$section")
        fi
    done

    if [[ ${#missing_sections[@]} -eq 0 ]]; then
        echo "✓ Required sections found"
        check_names+=("Structural Completeness")
        check_statuses+=("PASS")
        check_details_json+=("")
    else
        echo "✗ Missing sections: ${missing_sections[*]}"
        check_names+=("Structural Completeness")
        check_statuses+=("FAIL")
        check_details_json+=("${missing_sections[*]}")
    fi
}

#######################################
# check_yaml_frontmatter: Check YAML frontmatter fields
#
# Description:
#   Verifies that SKILL.md contains YAML frontmatter with required fields:
#   name, description, license
#
# Arguments:
#   None (uses global SKILL_FILE)
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file
#   results - Associative array to store check results
#   required_fields - Array of required field names
#
# Returns:
#   None (stores validation results in results array)
#
# Usage:
#   check_yaml_frontmatter
#
#######################################
function check_yaml_frontmatter {
    # Check for --- markers
    if ! grep -q "^---$" "$SKILL_FILE" 2> /dev/null; then
        echo "✗ YAML frontmatter not found"
        check_names+=("YAML Frontmatter Fields")
        check_statuses+=("FAIL")
        check_details_json+=("frontmatter")
        return
    fi

    local missing_fields=()
    for field in "${required_fields[@]}"; do
        if ! grep -q "^$field:" "$SKILL_FILE" 2> /dev/null; then
            missing_fields+=("$field")
        fi
    done

    if [[ ${#missing_fields[@]} -eq 0 ]]; then
        echo "✓ YAML frontmatter fields valid"
        check_names+=("YAML Frontmatter Fields")
        check_statuses+=("PASS")
        check_details_json+=("")
    else
        echo "✗ Missing YAML fields: ${missing_fields[*]}"
        check_names+=("YAML Frontmatter Fields")
        check_statuses+=("FAIL")
        check_details_json+=("${missing_fields[*]}")
    fi
}

#######################################
# check_progressive_disclosure: Check word count threshold
#
# Description:
#   Verifies that SKILL.md word count is under 5,000 words
#   to ensure Progressive Disclosure principle compliance
#
# Arguments:
#   None (uses global SKILL_FILE)
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file
#   results - Associative array to store check results
#
# Returns:
#   None (stores validation results in results array)
#
# Usage:
#   check_progressive_disclosure
#
#######################################
function check_progressive_disclosure {
    local word_count
    word_count=$(wc -w < "$SKILL_FILE" 2> /dev/null || echo "0")
    local limit=5000

    if [[ "$word_count" -lt "$limit" ]]; then
        echo "✓ Word count within limit ($word_count < $limit)"
        check_names+=("Progressive Disclosure")
        check_statuses+=("PASS")
        check_details_json+=("$word_count")
    else
        echo "✗ Word count exceeds limit ($word_count >= $limit)"
        check_names+=("Progressive Disclosure")
        check_statuses+=("FAIL")
        check_details_json+=("$word_count")
    fi
}

#######################################
# check_resource_separation: Check directory structure
#
# Description:
#   Verifies that skill directory contains scripts/ and reference/ directories
#   for proper resource organization
#
# Arguments:
#   None (uses global SKILL_FILE)
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file
#   results - Associative array to store check results
#
# Returns:
#   None (stores validation results in results array)
#
# Usage:
#   check_resource_separation
#
#######################################
function check_resource_separation {
    local skill_dir
    skill_dir="$(dirname "$SKILL_FILE")"

    local scripts_exists=0
    local reference_exists=0

    [[ -d "$skill_dir/scripts" ]] && scripts_exists=1
    [[ -d "$skill_dir/reference" ]] && reference_exists=1

    if [[ "$scripts_exists" -eq 1 ]] && [[ "$reference_exists" -eq 1 ]]; then
        echo "✓ Required directories present (scripts/, reference/)"
        check_names+=("Resource Separation")
        check_statuses+=("PASS")
        check_details_json+=("")
    else
        local missing_dirs=()
        [[ "$scripts_exists" -eq 0 ]] && missing_dirs+=("scripts/")
        [[ "$reference_exists" -eq 0 ]] && missing_dirs+=("reference/")

        echo "✗ Missing directories: ${missing_dirs[*]}"
        check_names+=("Resource Separation")
        check_statuses+=("FAIL")
        check_details_json+=("${missing_dirs[*]}")
    fi
}

#######################################
# check_reference_mandatory_files: Check mandatory reference files
#
# Description:
#   Verifies that reference/ directory contains mandatory files:
#   common-checklist.md and common-output-format.md
#
# Arguments:
#   None (uses global SKILL_FILE)
#
# Global Variables:
#   SKILL_FILE - Path to SKILL.md file
#   check_names - Array of check names
#   check_statuses - Array of check statuses
#   check_details_json - Array of check details
#
# Returns:
#   None (stores validation results in arrays)
#
# Usage:
#   check_reference_mandatory_files
#
#######################################
function check_reference_mandatory_files {
    local skill_dir
    skill_dir="$(dirname "$SKILL_FILE")"
    local ref_dir="$skill_dir/reference"

    # Skip if reference/ directory doesn't exist (already checked by check_resource_separation)
    if [[ ! -d "$ref_dir" ]]; then
        echo "⊘ Reference mandatory files check skipped (reference/ directory not found)"
        check_names+=("Reference Mandatory Files")
        check_statuses+=("SKIP")
        check_details_json+=("reference/ directory not found")
        return
    fi

    local missing_files=()
    [[ ! -f "$ref_dir/common-checklist.md" ]] && missing_files+=("common-checklist.md")
    [[ ! -f "$ref_dir/common-output-format.md" ]] && missing_files+=("common-output-format.md")

    if [[ ${#missing_files[@]} -eq 0 ]]; then
        echo "✓ Reference mandatory files present (common-checklist.md, common-output-format.md)"
        check_names+=("Reference Mandatory Files")
        check_statuses+=("PASS")
        check_details_json+=("")
    else
        echo "✗ Missing reference files: ${missing_files[*]}"
        check_names+=("Reference Mandatory Files")
        check_statuses+=("FAIL")
        check_details_json+=("${missing_files[*]}")
    fi
}

#######################################
# output_json: Generate JSON format output
#
# Description:
#   Outputs validation results in JSON format for machine parsing
#
# Arguments:
#   None (uses global results array)
#
# Global Variables:
#   results - Associative array containing check results
#
# Returns:
#   None (outputs JSON to stdout)
#
# Usage:
#   output_json
#
#######################################
function output_json {
    local overall_status="PASS"

    # Determine overall status
    for status in "${check_statuses[@]}"; do
        [[ "$status" == "FAIL" ]] && overall_status="FAIL"
    done

    # Output JSON header
    cat << 'EOF'
{
  "validation_results": [
EOF

    # Output each validation result
    for i in "${!check_names[@]}"; do
        local check="${check_names[$i]}"
        local status="${check_statuses[$i]}"
        local detail="${check_details_json[$i]}"

        # Add comma separator for all but first item
        [[ $i -gt 0 ]] && cat << 'EOF'
,
EOF

        printf '    {"check": "%s", "status": "%s", "detail": "%s"}' "$check" "$status" "$detail"
    done

    # Output JSON footer
    cat << EOF

  ],
  "overall_status": "$overall_status"
}
EOF
}

#######################################
# main: Main process
#
# Description:
#   Main entry point for the script. Coordinates all validation checks
#   and output generation. Parses arguments, runs all checks, and
#   outputs results in both human-readable and JSON formats.
#
# Arguments:
#   $@ - Command line arguments (SKILL.md file path)
#
# Global Variables:
#   SKILL_FILE - Set by parse_arguments
#
# Returns:
#   Exits with 0 on success, 1 on error
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Validate required dependencies
    validate_dependencies "grep" "wc" "realpath"

    # Parse and validate arguments
    parse_arguments "$@"

    echo_section "Validating SKILL.md: $SKILL_FILE"

    # Run all checks
    check_yaml_syntax
    check_structural_completeness
    check_yaml_frontmatter
    check_progressive_disclosure
    check_resource_separation
    check_reference_mandatory_files

    echo ""
    echo_section "JSON Output"
    output_json
}

# Entry point: only execute main if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
