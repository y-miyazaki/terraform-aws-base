#!/bin/bash
#######################################
# Description: Deploys Go Lambda functions to AWS using Serverless Framework
# This script handles the deployment process of Go Lambda functions by
# installing dependencies, building the project, and deploying to AWS.
#
# Usage: ./deploy.sh <stage>
#   <stage>    Deployment stage/environment (e.g., dev, staging, prod)
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
#   $1 - Error message to display (optional)
#
# Returns:
#   None (outputs to stdout and exits with code 1)
#
# Usage:
#   show_usage "error message"
#
#######################################
function show_usage {
    local error_msg="$1"

    if [ -n "$error_msg" ]; then
        echo "Error: $error_msg" >&2
        echo ""
    fi

    show_help_header "$(basename "$0")" "Deploy Go Lambda functions to AWS using Serverless Framework" "<stage>"
    echo "This script handles the deployment process of Go Lambda functions by"
    echo "installing dependencies, building the project, and deploying to AWS."
    echo ""
    echo "Arguments:"
    echo "  stage       Deployment stage/environment (e.g., dev, staging, prod)"
    echo ""
    show_help_footer
    echo "Examples:"
    echo "  $0 dev"
    echo "  $0 staging"
    echo "  $0 prod"
    exit 1
}

#######################################
# build_project: Build project
#
# Description:
#   Builds the Go Lambda project using make build
#
# Arguments:
#   None
#
# Returns:
#   None (exits on failure)
#
# Usage:
#   build_project
#
#######################################
function build_project {
    log "INFO" "Building project..."
    if ! execute_command "make build"; then
        error_exit "Failed to build project"
    fi
}

#######################################
# deploy_to_aws: Deploy to AWS
#
# Description:
#   Deploys the built Lambda functions to AWS using Serverless Framework
#
# Arguments:
#   $1 - Deployment stage (dev, staging, prod)
#
# Returns:
#   None (exits on failure)
#
# Usage:
#   deploy_to_aws "dev"
#
#######################################
function deploy_to_aws {
    local stage="$1"

    log "INFO" "Deploying to AWS ($stage)..."
    if ! execute_command "make deploy STAGE=${stage}"; then
        error_exit "Failed to deploy to $stage environment"
    fi
}

#######################################
# install_dependencies: Install dependencies
#
# Description:
#   Installs project dependencies using npm ci
#
# Arguments:
#   None
#
# Returns:
#   None (exits on failure)
#
# Usage:
#   install_dependencies
#
#######################################
function install_dependencies {
    log "INFO" "Installing dependencies..."
    if ! execute_command "npm ci"; then
        error_exit "Failed to install dependencies"
    fi
}

#######################################
# validate_arguments: Validate input arguments
#
# Description:
#   Validates that required arguments are provided
#
# Arguments:
#   $1 - Deployment stage
#
# Returns:
#   None (exits on validation failure)
#
# Usage:
#   validate_arguments "dev"
#
#######################################
function validate_arguments {
    local stage="$1"

    if [ -z "$stage" ]; then
        show_usage "Stage argument is required"
    fi
}

#######################################
# main: Main execution function
#
# Description:
#   Main entry point that orchestrates the deployment process
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Returns:
#   None (exits with appropriate status code)
#
# Usage:
#   main "$@"
#
#######################################
function main {
    local stage="$1"

    # Show usage if -h or --help is provided
    if [ "$stage" = "-h" ] || [ "$stage" = "--help" ]; then
        show_usage
    fi

    # Validate input arguments
    validate_arguments "$stage"

    echo_section "Deploying Lambda functions to $stage environment"

    # Install dependencies
    install_dependencies

    # Build project
    build_project

    # Deploy to AWS
    deploy_to_aws "$stage"

    echo_section "Deployment completed successfully!"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
