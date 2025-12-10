#!/bin/bash
#######################################
# Description: Local testing script for Node.js Lambda modules
# Usage: ./test_local.sh [module_name]
#   module_name: Name of the module to test (default: kinesis_data_firehose_cloudwatch_logs_processor)
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
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Arguments:
#   None
#
# Returns:
#   None (outputs to stdout and exits)
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    show_help_header "$(basename "$0")" "Local testing script for Node.js Lambda modules" "[module_name]"
    echo "This script builds and runs tests for Node.js Lambda modules in Docker containers."
    echo ""
    echo "Arguments:"
    echo "  module_name     Name of the module to test (default: kinesis_data_firehose_cloudwatch_logs_processor)"
    echo ""
    echo "Available modules:"
    echo "  - kinesis_data_firehose_cloudwatch_logs_processor (default)"
    echo "  - s3_notification_s3_object_created_for_athena"
    echo ""
    show_help_footer
    echo "Examples:"
    echo "  $0"
    echo "  $0 kinesis_data_firehose_cloudwatch_logs_processor"
    echo "  $0 s3_notification_s3_object_created_for_athena"
    exit 0
}

#######################################
# validate_module: Validate module exists
#
# Description:
#   Checks that the specified Node.js module directory exists
#
# Arguments:
#   $1 - Module name
#
# Returns:
#   None (exits on validation failure)
#
# Usage:
#   validate_module "kinesis_data_firehose_cloudwatch_logs_processor"
#
#######################################
function validate_module {
    local module_name="$1"

    if [ ! -d "/workspace/nodejs/${module_name}" ]; then
        error_exit "Module '${module_name}' not found. Use -h for available modules."
    fi
}

#######################################
# build_docker_image: Build docker image
#
# Description:
#   Builds a Docker image for the specified Node.js module
#
# Arguments:
#   $1 - Module name
#   $2 - Docker image name
#
# Returns:
#   None (exits on build failure)
#
# Usage:
#   build_docker_image "module_name" "image_name"
#
#######################################
function build_docker_image {
    local module_name="$1"
    local image_name="$2"

    log "INFO" "Building Docker image '${image_name}'..."
    if ! execute_command "docker build -t ${image_name} --build-arg MODULE_NAME=${module_name} ."; then
        error_exit "Failed to build Docker image"
    fi
}

#######################################
# run_tests: Run tests in docker
#
# Description:
#   Runs tests for the Node.js module inside a Docker container
#
# Arguments:
#   $1 - Docker image name
#
# Returns:
#   Test exit code (0 on success, non-zero on failure)
#
# Usage:
#   run_tests "image_name"
#
#######################################
function run_tests {
    local image_name="$1"

    log "INFO" "Running tests..."
    if ! execute_command "docker run --rm ${image_name}"; then
        local test_exit_code=$?
        log "ERROR" "Tests failed (exit code: $test_exit_code)"
        return $test_exit_code
    fi

    log "INFO" "Tests completed successfully"
    return 0
}

#######################################
# main: Main function
#
# Description:
#   Main entry point that orchestrates the testing process for Node.js modules
#
# Arguments:
#   $1 - Module name (optional, defaults to kinesis_data_firehose_cloudwatch_logs_processor)
#
# Returns:
#   None (exits with test result code)
#
# Usage:
#   main "module_name"
#
#######################################
function main {
    local module_name="${1:-kinesis_data_firehose_cloudwatch_logs_processor}"

    # Show help if requested
    if [ "$module_name" == "-h" ] || [ "$module_name" == "--help" ]; then
        show_usage
    fi

    # Validate dependencies
    validate_dependencies "docker"

    # Validate module exists
    validate_module "$module_name"

    log "INFO" "Running tests for module '${module_name}'..."

    # Change to nodejs directory
    if ! cd /workspace/nodejs; then
        error_exit "Failed to change to nodejs directory"
    fi

    # Set image name based on module name
    local image_name="${module_name}-test"

    # Build docker image
    build_docker_image "$module_name" "$image_name"

    # Run tests and exit with the same code
    run_tests "$image_name"
    exit $?
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
