# Scripts Library

This directory contains common utility functions that can be shared across multiple shell scripts in the project.

## Library Files

### `all.sh` (Unified Library Loader)
**NEW: Simplified library loading system**
- **Purpose**: Single-line library loading to prevent import errors
- **Usage**: `source "${SCRIPT_DIR}/../lib/all.sh"` loads all libraries at once
- **Benefits**: Eliminates the possibility of missing library imports and simplifies maintenance
- **Implementation**: Sources all individual libraries with duplicate loading prevention

### `common.sh`
Basic utility functions used across all scripts:
- **Logging**: `log()`, structured logging with levels
- **Error handling**: `error_exit()`, standardized error handling
- **Output formatting**: `echo_section()`, consistent section headers
- **Argument parsing**: `parse_common_args()`, common CLI argument handling
- **Dependency validation**: `validate_dependencies()`, `validate_env_vars()`
- **Dry-run support**: `is_dry_run()`, `execute_command()`

### `aws.sh`
AWS-specific utility functions:
- **JSON parsing**: `extract_jq_value()`, `extract_jq_array()`, enhanced jq wrappers with defaults and custom separators
- **AWS utilities**: `get_aws_account_id()`, `get_aws_region()`, `validate_aws_config()`
- **ARN parsing**: `parse_arn()`, `get_resource_name_from_arn()`
- **Service checks**: `is_service_available_in_region()`
- **WAF integration**: `get_waf_association()`
- **Timestamp formatting**: `format_aws_timestamp()`
- **Safe execution**: `aws_safe_exec()`

### `terraform.sh`
Terraform workflow and utility functions:
- **Environment setup**: `validate_terraform_env()`, environment validation
- **Workflow operations**: `terraform_init()`, `terraform_plan()`, `terraform_apply()`
- **Formatting**: `terraform_format()`, code formatting utilities
- **Workspace management**: `terraform_get_workspace()`, `terraform_select_workspace()`
- **Complete workflows**: `terraform_workflow()`, end-to-end automation

### `validation.sh`
File and configuration validation functions:
- **File validation**: `validate_file_exists()`, `validate_directory_exists()`
- **Script validation**: `validate_script_syntax()`, `validate_script_executable()`
- **Permission checks**: `validate_file_permissions()`
- **Format validation**: `validate_json_file()`, `validate_yaml_file()`
- **Network validation**: `validate_network_connectivity()`, `validate_port_availability()`
- **Batch validation**: `validate_files_in_directory()`

## Usage

### Unified Library Loading (Recommended)

```bash
#!/bin/bash

# Load all libraries with a single line
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/all.sh"

# All functions from all libraries are now available
validate_dependencies "aws" "jq"
log "INFO" "Starting script"

aws_account_id=$(get_aws_account_id)
log "INFO" "AWS Account: $aws_account_id"
```

### Complete Example - AWS Resource Script

```bash
#!/bin/bash
set -e

# Source all libraries with unified loader
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/all.sh"

# Global variables
VERBOSE=false
DRY_RUN=false
AWS_REGION="ap-northeast-1"

# Usage function
function show_usage {
    show_help_header "$(basename "$0")" "Collect AWS resources" "[options]"
    echo "Options:"
    echo "  -r, --region    AWS region (default: ap-northeast-1)"
    show_help_footer
}

# Parse arguments
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -r|--region)
                AWS_REGION="$2"
                shift 2
                ;;
            *)
                remaining_args=$(parse_common_args "$@")
                eval set -- "$remaining_args"
                break
                ;;
        esac
    done
}

# Main function
function main {
    parse_arguments "$@"
    
    # Validate environment
    validate_aws_config
    
    echo_section "Collecting AWS Resources"
    log "INFO" "Region: $AWS_REGION"
    
    # Use AWS functions
    local account_id
    account_id=$(get_aws_account_id)
    log "INFO" "Account ID: $account_id"
    
    # Example: List S3 buckets
    local buckets_json
    buckets_json=$(aws_safe_exec "aws s3api list-buckets --region $AWS_REGION")
    
    local bucket_count
    bucket_count=$(extract_jq_value "$buckets_json" '.Buckets | length' '0')
    log "INFO" "Found $bucket_count S3 buckets"
    
    # Example: Process Bedrock foundation models with array data
    local bedrock_json
    bedrock_json=$(aws_safe_exec "aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[0]'")
    
    local input_modalities output_modalities inference_types
    input_modalities=$(extract_jq_array "$bedrock_json" '.inputModalities')
    output_modalities=$(extract_jq_array "$bedrock_json" '.outputModalities')
    inference_types=$(extract_jq_array "$bedrock_json" '.inferenceTypesSupported' 'N/A' '|')
    
    log "INFO" "Model supports input: $input_modalities, output: $output_modalities"
    log "INFO" "Inference types (pipe-separated): $inference_types"
}

# Execute main function
main "$@"
```

### Complete Example - Terraform Deployment Script

```bash
#!/bin/bash
set -e

# Source all libraries with unified loader
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/all.sh"

# Global variables
ENV=""
WORKFLOW_TYPE="apply"
AUTO_APPROVE=false

# Usage function
function show_usage {
    show_help_header "$(basename "$0")" "Deploy Terraform configuration" "[options] <directory>"
    echo "Arguments:"
    echo "  directory       Target directory (optional, defaults to current)"
    echo ""
    echo "Options:"
    echo "  -e, --env       Environment name (required)"
    echo "  -w, --workflow  Workflow type: plan, apply, destroy (default: apply)"
    echo "  -y, --yes       Auto-approve (skip confirmation)"
    show_help_footer
    echo "Environment Variables:"
    echo "  ENV                     Environment name"
    echo "  TF_PLUGIN_CACHE_DIR     Terraform plugin cache directory"
    echo ""
    echo "Examples:"
    echo "  ENV=dev $0 -w plan ./terraform/base"
    echo "  $0 -e prod -y ./terraform/application"
}

# Parse arguments
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -e|--env)
                ENV="$2"
                shift 2
                ;;
            -w|--workflow)
                WORKFLOW_TYPE="$2"
                shift 2
                ;;
            -y|--yes)
                AUTO_APPROVE=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Remaining argument is directory
                TARGET_DIR="$1"
                shift
                ;;
        esac
    done
}

# Main function
function main {
    parse_arguments "$@"
    
    # Set default directory
    local target_dir="${TARGET_DIR:-.}"
    
    # Change to target directory
    if ! cd "$target_dir"; then
        error_exit "Failed to change to directory: $target_dir"
    fi
    
    echo_section "Terraform Deployment"
    log "INFO" "Directory: $(pwd)"
    log "INFO" "Environment: ${ENV}"
    log "INFO" "Workflow: ${WORKFLOW_TYPE}"
    
    # Determine auto-approve setting
    local auto_approve_flag=""
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        auto_approve_flag="auto-approve"
    fi
    
    # Run Terraform workflow
    terraform_workflow "$ENV" "$WORKFLOW_TYPE" "$auto_approve_flag"
    
    echo_section "Deployment Complete"
}

# Execute main function
main "$@"
```

## Integration with Existing Scripts

### Migrating Existing Scripts

1. **Identify common functions** in your existing scripts
2. **Replace individual library imports** with the unified loader
3. **Replace duplicate functions** with library calls
4. **Update function calls** to use the standardized names

## Best Practices

1. **Use the unified library loader** (`all.sh`) for new scripts to eliminate import errors
2. **Use absolute paths with SCRIPT_DIR** when sourcing to maintain portability
3. **Check for function availability** before calling library functions (if needed)
4. **Follow consistent error handling** using the library functions
5. **Use structured logging** with appropriate log levels
6. **Validate dependencies** before executing main logic
7. **Migrate existing scripts** to use the unified loader when modifying them

## Dependencies

The libraries require the following tools to be installed:
- `bash` (version 4.0+)
- `jq` (for JSON processing)
- `aws` (AWS CLI v2 recommended)
- `terraform` (for Terraform libraries)

Optional tools for enhanced functionality:
- `curl` or `wget` (for network validation)
- `nc` or `telnet` (for port validation)
- `yq` or `python3` (for YAML validation)
