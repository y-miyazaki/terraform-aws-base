#!/bin/bash

#######################################
# Description: Common utility functions for shell scripts
# Usage: source /path/to/scripts/lib/common.sh
#
# This library provides standard functions used across multiple scripts:
# - Logging and output formatting
# - Error handling and exit functions
# - Help/usage display functions
# - Dependency validation
# - Section headers for organized output
#######################################

#######################################
# echo_section: Display section headers with consistent formatting
#
# Description:
#   Displays formatted section headers for organized output
#
# Arguments:
#   $1 - Section title
#
# Returns:
#   None (outputs to stderr)
#
# Usage:
#   echo_section "Starting deployment"
#
#######################################
function echo_section {
    echo "#--------------------------------------------------------------" >&2
    echo "# $1" >&2
    echo "#--------------------------------------------------------------" >&2
}

#######################################
# end_echo_section: Display section completion with elapsed time
#
# Description:
#   Displays formatted section footer with elapsed time since start
#
# Arguments:
#   $1 - Section title
#   $2 - Start time (epoch seconds)
#
# Returns:
#   None (outputs to stderr)
#
# Usage:
#   end_echo_section "Deployment" "$start_time"
#
#######################################
function end_echo_section {
    local title="$1"
    local start_time="$2"
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - start_time))

    echo "#--------------------------------------------------------------" >&2
    echo "# $title completed in ${elapsed} seconds" >&2
    echo "#--------------------------------------------------------------" >&2
}

#######################################
# error_exit: Display error message and exit
#
# Description:
#   Displays an error message and exits the script with specified code
#
# Arguments:
#   $1 - Error message
#   $2 - Exit code (optional, defaults to 1)
#
# Returns:
#   Exits with specified code (never returns)
#
# Usage:
#   error_exit "Failed to connect to database"
#
#######################################
function error_exit {
    local message="$1"
    local exit_code="${2:-1}"
    echo "ERROR: $message" >&2
    exit "$exit_code"
}

#######################################
# execute_command: Execute command with dry-run support
#
# Description:
#   Executes a command with support for dry-run mode
#
# Arguments:
#   $@ - Command to execute
#
# Returns:
#   Command exit code (or 0 in dry-run mode)
#
# Usage:
#   execute_command aws s3 cp "file.txt" "s3://bucket/"
#
#######################################
function execute_command {
    # Execute a command safely without eval. Accepts arguments and runs them
    # Example: execute_command aws s3 cp "src" "dest"
    if is_dry_run; then
        # Always print dry-run info regardless of VERBOSE so users see planned actions
        echo "DRY-RUN: Would execute: $*" >&2
        return 0
    fi

    log "DEBUG" "Executing: $*"

    # Execute the command. Support two calling styles:
    # 1) execute_command cmd arg1 arg2 ...  --> safe, runs the command directly
    # 2) execute_command "cmd arg1 arg2"   --> common in older scripts; run via bash -lc
    if [[ $# -eq 1 ]]; then
        # Single-string command (may contain spaces/options) — run under bash -lc so
        # shell parsing behaves as the caller expects.
        bash -lc "$1"
    else
        # Multi-argument safe execution
        "${@}"
    fi
}

#######################################
# get_start_time: Get current time for timing measurements
#
# Description:
#   Returns the current epoch time for timing measurements
#
# Arguments:
#   None
#
# Returns:
#   Current epoch time in seconds (to stdout)
#
# Usage:
#   start_time=$(get_start_time)
#
#######################################
function get_start_time {
    date +%s
}

#######################################
# is_dry_run: Check if running in dry-run mode
#
# Description:
#   Checks if the script is running in dry-run mode
#
# Arguments:
#   None
#
# Returns:
#   0 if in dry-run mode, 1 otherwise
#
# Usage:
#   if is_dry_run; then echo "Dry run mode"; fi
#
#######################################
function is_dry_run {
    [[ "${DRY_RUN:-false}" == "true" ]]
}

#######################################
# log: Log messages with timestamp and level
#
# Description:
#   Logs messages with timestamp and log level to stderr
#
# Arguments:
#   $1 - Log level (INFO, WARN, ERROR, DEBUG)
#   $2 - Log message
#
# Returns:
#   None (outputs to stderr)
#
# Usage:
#   log "INFO" "Process completed successfully"
#
#######################################
function log {
    local level="$1"
    local message="$2"

    if [[ "$level" == "ERROR" ]] || [[ "$level" == "WARN" ]] || [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" >&2
    fi
}

#######################################
# show_help_footer: Display standardized help footer
#
# Description:
#   Displays common help options in standardized format
#
# Arguments:
#   None
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   show_help_footer
#
#######################################
function show_help_footer {
    echo ""
    echo "Common Options:"
    echo "  -h, --help     Display this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo "  -d, --dry-run  Run in dry-run mode (no changes made)"
    echo ""
}

#######################################
# show_help_header: Display standardized help message header
#
# Description:
#   Displays formatted help header with script name, description, and usage
#
# Arguments:
#   $1 - Script name
#   $2 - Brief description
#   $3 - Usage pattern
#
# Returns:
#   None (outputs to stdout)
#
# Usage:
#   show_help_header "$(basename "$0")" "Deploy application" "<environment>"
#
#######################################
function show_help_header {
    local script_name="$1"
    local description="$2"
    local usage_pattern="$3"

    echo "Usage: $script_name $usage_pattern"
    echo ""
    echo "Description: $description"
    echo ""
}

#######################################
# start_echo_section: Display section headers and capture start time
#
# Description:
#   Displays formatted section header (used with end_echo_section for timing)
#
# Arguments:
#   $1 - Section title
#
# Returns:
#   None (outputs to stderr)
#
# Usage:
#   start_echo_section "Building application"
#
#######################################
function start_echo_section {
    local title="$1"
    echo "#--------------------------------------------------------------" >&2
    echo "# $title" >&2
    echo "#--------------------------------------------------------------" >&2
}

#######################################
# validate_dependencies: Validate required command line tools
#
# Description:
#   Checks that all required command line tools are available in PATH
#
# Arguments:
#   $@ - List of required tools/commands
#
# Returns:
#   None (exits on missing dependencies)
#
# Usage:
#   validate_dependencies "aws" "jq" "docker"
#
#######################################
function validate_dependencies {
    local required_tools=("$@")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error_exit "Missing required tools: ${missing_tools[*]}. Please install them and ensure they are in PATH."
    fi

    log "INFO" "All required dependencies are available: ${required_tools[*]}"
}

#######################################
# validate_env_vars: Validate required environment variables
#
# Description:
#   Checks that all required environment variables are set
#
# Arguments:
#   $@ - List of required environment variable names
#
# Returns:
#   None (exits on missing variables)
#
# Usage:
#   validate_env_vars "AWS_REGION" "AWS_PROFILE"
#
#######################################
function validate_env_vars {
    local required_vars=("$@")
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        error_exit "Missing required environment variables: ${missing_vars[*]}"
    fi

    log "INFO" "All required environment variables are set: ${required_vars[*]}"
}
