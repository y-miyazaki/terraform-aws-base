#!/bin/bash
#######################################
# Description: Markdown validation for files and directories (syntax and links)
#
# Usage: ./validate.sh [PATH]
#   arguments:
#     PATH           Path to target Markdown file or directory (optional)
#                    Default: .
#
# Output:
# - Human-readable validation results (terminal output)
# - JSON format output for machine parsing
#
# Design Rules:
# - Validate markdown syntax with markdownlint
# - Validate markdown links with markdown-link-check
# - Exit with non-zero status when any check fails
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - find (standard Unix utility)
# - node (Node.js runtime for CLI tools)
# - npm (Node.js package manager)
# - markdownlint (Node.js CLI, installed via npm)
# - markdown-link-check (Node.js CLI, installed via npm)
#######################################

set -euo pipefail

umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

TARGET_PATH="."
declare -a check_names=()
declare -a check_statuses=()
declare -a check_details=()
declare -a markdown_files=()

#######################################
# cleanup: Cleanup hook
#
# Description:
#   No-op cleanup placeholder to keep trap behavior consistent
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
    true
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
Usage: validate.sh [PATH]

Description:
    Deterministic Markdown validation for files and directories.

Arguments:
    PATH        Optional path to target Markdown file or directory
                            Default: /workspace

Validation Checks:
    - Markdown syntax (markdownlint)
    - Markdown links (markdown-link-check)

Examples:
  ./validate.sh
    ./validate.sh /workspace/README.md
    ./validate.sh /workspace/docs/
EOF
    exit 0
}

#######################################
# parse_arguments: Parse and validate command line arguments
#
# Description:
#   Parses optional PATH argument and validates target path
#
# Arguments:
#   $@ - Command line arguments
#
# Global Variables:
#   TARGET_PATH - Normalized target path
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
        TARGET_PATH="$1"
    fi

    if [[ ! -e "${TARGET_PATH}" ]]; then
        error_exit "Error: Path not found: ${TARGET_PATH}"
    fi

    TARGET_PATH="$(realpath "${TARGET_PATH}")"
}

#######################################
# collect_markdown_files: Resolve markdown files from target input
#
# Description:
#   Populates markdown_files based on TARGET_PATH (file or directory)
#
# Arguments:
#   None
#
# Global Variables:
#   TARGET_PATH - Source path to scan
#   markdown_files - Resolved markdown file list
#
# Returns:
#   Exits with error when a file target is not .md
#
# Usage:
#   collect_markdown_files
#
#######################################
function collect_markdown_files {
    markdown_files=()

    if [[ -f "${TARGET_PATH}" ]]; then
        if [[ "${TARGET_PATH}" != *.md ]]; then
            error_exit "Error: File must have .md extension: ${TARGET_PATH}"
        fi
        markdown_files=("${TARGET_PATH}")
        return
    fi

    mapfile -t markdown_files < <(find "${TARGET_PATH}" -type f -name "*.md" ! -path "*/node_modules/*" ! -path "*/.git/*" | sort)
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

#######################################
# validate_markdown_files: Validate Markdown files with markdownlint and markdown-link-check
#
# Description:
#   Runs markdownlint on workspace Markdown files and optionally checks links
#   Skips if tools are not installed
#
# Arguments:
#   None
#
# Returns:
#   None (stores check result)
#
# Usage:
#   validate_markdown_files
#
#######################################
function validate_markdown_files {
    collect_markdown_files

    if ! command -v markdownlint > /dev/null 2>&1; then
        check_names+=("Markdown Syntax")
        check_statuses+=("SKIP")
        check_details+=("markdownlint not installed")
        echo "⊘ Markdown syntax validation skipped (markdownlint not found)"
    else
        if [[ ${#markdown_files[@]} -eq 0 ]]; then
            check_names+=("Markdown Syntax")
            check_statuses+=("SKIP")
            check_details+=("no Markdown files found")
            echo "⊘ Markdown syntax validation skipped (no .md files found)"
        else
            if markdownlint "${markdown_files[@]}" > /dev/null 2>&1; then
                check_names+=("Markdown Syntax")
                check_statuses+=("PASS")
                check_details+=("${#markdown_files[@]} files")
                echo "✓ Markdown files pass markdownlint"
            else
                check_names+=("Markdown Syntax")
                check_statuses+=("FAIL")
                check_details+=("markdownlint validation failed")
                echo "✗ Markdown files fail markdownlint validation"
            fi
        fi
    fi

    if ! command -v markdown-link-check > /dev/null 2>&1; then
        check_names+=("Markdown Links")
        check_statuses+=("SKIP")
        check_details+=("markdown-link-check not installed")
        echo "⊘ Markdown link validation skipped (markdown-link-check not found)"
    else
        if [[ ${#markdown_files[@]} -eq 0 ]]; then
            check_names+=("Markdown Links")
            check_statuses+=("SKIP")
            check_details+=("no Markdown files found")
            echo "⊘ Markdown link validation skipped (no .md files found)"
        else
            local file
            local link_failed=false
            local failing_file=""
            local failing_output=""
            for file in "${markdown_files[@]}"; do
                if ! failing_output="$(markdown-link-check "${file}" 2>&1)"; then
                    link_failed=true
                    failing_file="${file}"
                    echo "${failing_output}"
                    break
                fi
            done

            if [[ "${link_failed}" == true ]]; then
                check_names+=("Markdown Links")
                check_statuses+=("FAIL")
                if [[ -n "${failing_output}" ]]; then
                    failing_output="${failing_output//$'\n'/ }"
                    check_details+=("markdown-link-check failed for ${failing_file}: ${failing_output}")
                else
                    check_details+=("markdown-link-check validation failed for ${failing_file}")
                fi
                echo "✗ Some Markdown links are broken"
            else
                check_names+=("Markdown Links")
                check_statuses+=("PASS")
                check_details+=("${#markdown_files[@]} files")
                echo "✓ Markdown links are valid"
            fi
        fi
    fi
}
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

    validate_markdown_files

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
