#!/bin/bash
#######################################
# Description: Builds Go Lambda functions for deployment (old style)
# This script compiles Go code from the specified directory and packages
# the binaries for AWS Lambda deployment.
#
# Usage: ./build_old.sh <source_dir> <output_dir> [architecture]
#   <source_dir>    Directory containing main.go files (e.g., cmd/api)
#   <output_dir>    Output directory name (e.g., api)
#   [architecture]  Target architecture (default: amd64)
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
# Global variables
#######################################
DIR=""
BINDIR=""
ARCH="amd64" # Default to amd64 for old style

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
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Description: Builds Go Lambda functions for deployment (old style)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Display this help message"
    echo ""
    echo "Arguments:"
    echo "  source_dir      Directory containing main.go files (e.g., cmd/api)"
    echo "  output_dir      Output directory name (e.g., api)"
    echo "  architecture    Target architecture (default: amd64)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") cmd/api api amd64"
    exit 0
}

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
#   None (sets global variables DIR, BINDIR, ARCH)
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
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Process positional arguments
                if [[ -z "$DIR" ]]; then
                    DIR="$1"
                elif [[ -z "$BINDIR" ]]; then
                    BINDIR="$1"
                elif [[ "$ARCH" == "amd64" ]]; then
                    ARCH="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$DIR" ]] || [[ -z "$BINDIR" ]]; then
        echo "Error: Missing required arguments" >&2
        show_usage
    fi

    # Validate directory exists
    if [[ ! -d "$DIR" ]]; then
        error_exit "Source directory does not exist: $DIR"
    fi
}

#######################################
# prepare_build_environment: Prepare the build environment
#
# Description:
#   Sets up the build environment by updating dependencies and creating output directories
#
# Arguments:
#   None
#
# Returns:
#   None
#
# Usage:
#   prepare_build_environment
#
#######################################
function prepare_build_environment {
    echo_section "Building Go Lambda functions from $DIR to $BINDIR ($ARCH)"

    # Download and update dependencies
    log "INFO" "Updating Go modules..."
    go mod download || error_exit "Failed to download Go modules"

    # Clean output directories
    log "INFO" "Cleaning output directories..."
    rm -rf outputs/"${BINDIR}"/* 2> /dev/null || true
    rm -rf bin/"${BINDIR}"/* 2> /dev/null || true

    # Create output directories
    log "INFO" "Creating output directories..."
    mkdir -p bin/"${BINDIR}" || error_exit "Failed to create bin directory"
    mkdir -p outputs/"${BINDIR}" || error_exit "Failed to create outputs directory"
}

#######################################
# build_lambda_functions: Build Lambda functions
#
# Description:
#   Builds Go Lambda functions from main.go files in the source directory
#
# Arguments:
#   None
#
# Returns:
#   Number of functions built (integer)
#
# Usage:
#   count=$(build_lambda_functions)
#
#######################################
function build_lambda_functions {
    log "INFO" "Building Lambda functions..."
    local count=0

    # Better method to handle filenames with spaces or special characters
    while IFS= read -r file; do
        local dir function
        dir=$(dirname "$file")
        function=$(echo "$dir" | sed -e "s/.*\///g")

        log "INFO" "  Building $function..."
        env GOOS=linux GOARCH="${ARCH}" go build -ldflags="-s -w" -o "${function}" "$file" || error_exit "Failed to build $function"

        log "INFO" "  Packaging $function..."
        zip outputs/"${BINDIR}"/"${function}".zip "${function}" || error_exit "Failed to create zip for $function"

        log "INFO" "  Moving binary for $function..."
        mv "${function}" bin/"${BINDIR}"/"${function}" || error_exit "Failed to move binary for $function"

        count=$((count + 1))
    done < <(find "$DIR" -type f -name 'main.go')

    echo "$count"
}

#######################################
# main: Main execution function
#
# Description:
#   Main entry point that orchestrates the build process
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
    # Parse arguments
    parse_arguments "$@"

    # Validate dependencies
    validate_dependencies "go"

    # Prepare build environment
    prepare_build_environment

    # Build Lambda functions
    local count
    count=$(build_lambda_functions)

    echo_section "Build completed successfully! Built $count Lambda functions."
    log "INFO" "All Lambda functions built successfully"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
