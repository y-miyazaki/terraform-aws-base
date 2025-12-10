#!/bin/bash
#######################################
# Description: Upload Docker image to AWS ECR with authentication and build support
# Usage: ./aws_upload_ecr.sh [options] <repository_name>
#   options:
#     -h, --help     Display this help message
#     -v, --verbose  Enable verbose output
#     -d, --dry-run  Run in dry-run mode (no changes made)
#     -r, --region   AWS region (default: $AWS_DEFAULT_REGION or ap-northeast-1)
#     -p, --platform Docker platform (default: linux/amd64)
#     -t, --tag      Image tag (default: latest)
#     -f, --file     Dockerfile path (default: ./Dockerfile)
#     -c, --context  Build context path (default: .)
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
# Global variables and default values
#######################################
AWS_REGION="${AWS_DEFAULT_REGION:-ap-northeast-1}"
VERBOSE=false
DRY_RUN=false
DOCKER_PLATFORM="linux/amd64"
IMAGE_TAG="latest"
DOCKERFILE_PATH="./Dockerfile"
BUILD_CONTEXT="."
REPOSITORY_NAME=""

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Arguments:
#   None
#
# Global Variables:
#   None
#
# Returns:
#   Exits with status 0 after displaying help
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    echo "Usage: $(basename "$0") [options] <repository_name>"
    echo ""
    echo "Description: Upload Docker image to AWS ECR with authentication and build support"
    echo ""
    echo "Options:"
    echo "  -h, --help       Display this help message"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -d, --dry-run    Run in dry-run mode (no changes made)"
    echo "  -r, --region     AWS region (default: \$AWS_DEFAULT_REGION or ap-northeast-1)"
    echo "  -p, --platform   Docker platform (default: linux/amd64)"
    echo "  -t, --tag        Image tag (default: latest)"
    echo "  -f, --file       Dockerfile path (default: ./Dockerfile)"
    echo "  -c, --context    Build context path (default: .)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") my-app-repo"
    echo "  $(basename "$0") -r us-east-1 -t v1.0.0 my-app-repo"
    echo "  $(basename "$0") -p linux/arm64 -d my-app-repo"
    echo "  $(basename "$0") -f ./docker/Dockerfile -c ./docker my-app-repo"
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and validates required repository name
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   AWS_REGION - Set to specified AWS region
#   VERBOSE - Set to true if verbose mode enabled
#   DRY_RUN - Set to true if dry-run mode enabled
#   DOCKER_PLATFORM - Set to specified Docker platform
#   IMAGE_TAG - Set to specified image tag
#   DOCKERFILE_PATH - Set to specified Dockerfile path
#   BUILD_CONTEXT - Set to specified build context
#   REPOSITORY_NAME - Set to specified repository name
#
# Returns:
#   Exits with error if repository name is missing or unknown arguments provided
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
                export VERBOSE
                shift
                ;;
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -r | --region)
                AWS_REGION="$2"
                shift 2
                ;;
            -p | --platform)
                DOCKER_PLATFORM="$2"
                shift 2
                ;;
            -t | --tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            -f | --file)
                DOCKERFILE_PATH="$2"
                shift 2
                ;;
            -c | --context)
                BUILD_CONTEXT="$2"
                shift 2
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Process repository name
                if [[ -z "${REPOSITORY_NAME}" ]]; then
                    REPOSITORY_NAME="$1"
                else
                    error_exit "Unexpected argument: $1"
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "${REPOSITORY_NAME}" ]]; then
        echo "Error: Repository name is required" >&2
        show_usage
    fi
}

#######################################
# authenticate_ecr: Authenticate to ECR
#
# Description:
#   Authenticates Docker to AWS ECR registry using AWS credentials
#
# Arguments:
#   None
#
# Global Variables:
#   AWS_REGION - AWS region for ECR registry
#   DRY_RUN - Whether to run in dry-run mode
#
# Returns:
#   Outputs the ECR registry URL
#
# Usage:
#   registry_url=$(authenticate_ecr)
#
#######################################
function authenticate_ecr {
    local account_id
    local registry_url

    log "INFO" "Getting AWS account ID..."
    if ! account_id=$(get_aws_account_id); then
        error_exit "Failed to get AWS account ID"
    fi

    registry_url="${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    log "INFO" "Using registry URL: $registry_url"
    log "INFO" "AWS Region: $AWS_REGION"

    log "INFO" "Authenticating Docker to ECR registry: $registry_url"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY RUN: Would authenticate to ECR registry: $registry_url"
        return 0
    fi

    # Debug: Show current AWS identity and region
    log "INFO" "Current AWS identity: $(aws sts get-caller-identity --query 'Arn' --output text 2> /dev/null || echo 'Failed to get identity')"
    log "INFO" "Using AWS region: $AWS_REGION"

    # Get ECR login password first, then pipe to docker login
    local login_password
    log "INFO" "Getting ECR login password..."
    if ! login_password=$(aws ecr get-login-password --region "$AWS_REGION" 2>&1); then
        log "ERROR" "Failed to get ECR login password: $login_password"
        error_exit "Failed to get ECR login password"
    fi

    log "INFO" "Authenticating Docker with ECR..."
    if ! echo "$login_password" | docker login --username AWS --password-stdin "$registry_url" > /dev/null 2>&1; then
        error_exit "Failed to authenticate to ECR registry"
    fi

    echo "$registry_url"
}

#######################################
# build_docker_image: Build and tag Docker image
#
# Description:
#   Builds a Docker image with specified parameters and tags it for ECR
#
# Arguments:
#   $1 - Repository name
#   $2 - ECR registry URL
#
# Global Variables:
#   DOCKER_PLATFORM - Docker platform to build for
#   IMAGE_TAG - Image tag to use
#   DOCKERFILE_PATH - Path to Dockerfile
#   BUILD_CONTEXT - Build context path
#   DRY_RUN - Whether to run in dry-run mode
#
# Returns:
#   Outputs the full image name (registry/repository:tag)
#
# Usage:
#   full_image_name=$(build_docker_image "$repo" "$registry_url")
#
#######################################
function build_docker_image {
    local repository_name="$1"
    local registry_url="$2"
    local full_image_name="${registry_url}/${repository_name}:${IMAGE_TAG}"

    log "INFO" "Building Docker image for platform: $DOCKER_PLATFORM"
    log "INFO" "Image will be tagged as: $full_image_name"

    log "INFO" "Docker build context: $(pwd)"
    log "INFO" "Repository: $repository_name"
    log "INFO" "Registry: $registry_url"
    log "INFO" "Tag: $IMAGE_TAG"
    log "INFO" "Dockerfile: $DOCKERFILE_PATH"
    log "INFO" "Build context: $BUILD_CONTEXT"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY RUN: Would build and tag Docker image: $full_image_name"
        log "INFO" "DRY RUN: Would use Dockerfile: $DOCKERFILE_PATH"
        log "INFO" "DRY RUN: Would use build context: $BUILD_CONTEXT"
        echo "$full_image_name"
        return 0
    fi

    # Build multi-platform image with specified Dockerfile and context
    if ! docker build --platform "$DOCKER_PLATFORM" -f "$DOCKERFILE_PATH" -t "$full_image_name" "$BUILD_CONTEXT"; then
        error_exit "Failed to build Docker image"
    fi

    log "INFO" "Docker image built successfully: $full_image_name"
    echo "$full_image_name"
}

#######################################
# push_docker_image: Push Docker image to ECR
#
# Description:
#   Pushes the built Docker image to AWS ECR
#
# Arguments:
#   $1 - Full image name (registry/repository:tag)
#
# Global Variables:
#   DRY_RUN - Whether to run in dry-run mode
#
# Returns:
#   None
#
# Usage:
#   push_docker_image "$full_image_name"
#
#######################################
function push_docker_image {
    local full_image_name="$1"

    log "INFO" "Pushing Docker image to ECR: $full_image_name"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "DRY RUN: Would push Docker image: $full_image_name"
        return 0
    fi

    if ! docker push "$full_image_name"; then
        error_exit "Failed to push Docker image to ECR"
    fi

    log "INFO" "Docker image pushed successfully: $full_image_name"
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the script logic for uploading Docker image to ECR
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   REPOSITORY_NAME - ECR repository name
#   AWS_REGION - AWS region
#   DOCKER_PLATFORM - Docker platform
#   IMAGE_TAG - Image tag
#   DOCKERFILE_PATH - Dockerfile path
#   BUILD_CONTEXT - Build context path
#   DRY_RUN - Whether to run in dry-run mode
#
# Returns:
#   Exits with status 0 on success, non-zero on failure
#
# Usage:
#   main "$@"
#
#######################################
function main {
    # Parse arguments
    parse_arguments "$@"

    # Record start time
    start_time=$(date +%s)

    # Validate dependencies
    validate_dependencies "aws" "docker" "jq"

    # Check AWS credentials before any AWS CLI usage
    if ! check_aws_credentials; then
        error_exit "AWS credentials are not set or invalid. Please configure your AWS CLI credentials."
    fi

    # Confirm AWS account ID after credential validation
    if ! get_aws_account_id > /dev/null 2>&1; then
        error_exit "Unable to retrieve AWS account ID. Please check your credentials and permissions."
    fi

    # Log script start
    echo_section "Starting ECR upload process"
    log "INFO" "Repository: $REPOSITORY_NAME"
    log "INFO" "Region: $AWS_REGION"
    log "INFO" "Platform: $DOCKER_PLATFORM"
    log "INFO" "Tag: $IMAGE_TAG"
    log "INFO" "Dockerfile: $DOCKERFILE_PATH"
    log "INFO" "Build context: $BUILD_CONTEXT"

    if [[ "$DRY_RUN" == "true" ]]; then
        log "INFO" "Running in dry-run mode, no changes will be made"
    fi

    # Set AWS region
    export AWS_DEFAULT_REGION="$AWS_REGION"

    # Step 1: Authenticate to ECR and get registry URL
    local registry_url
    registry_url=$(authenticate_ecr)

    # Step 2: Build and tag Docker image
    local full_image_name
    full_image_name=$(build_docker_image "$REPOSITORY_NAME" "$registry_url")

    # Step 3: Push image to ECR (ECR repository will be created automatically if it doesn't exist)
    push_docker_image "$full_image_name"

    # Record end time and calculate elapsed time
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    log "INFO" "ECR upload completed in ${elapsed} seconds"

    echo_section "ECR upload completed successfully"
    log "INFO" "Image available at: $full_image_name"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
