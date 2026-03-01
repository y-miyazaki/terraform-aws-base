#!/bin/bash
#######################################
# Description: Deploy ECS scheduled task (task definition + EventBridge rules)
#
# Usage: ./aws_deploy_ecs_scheduled_task.sh [options] [action]
#   actions:
#     apply  Register task definition and apply EventBridge rules (default)
#     diff   Show diff between local config and remote state
#     run    Manually trigger a specific EventBridge rule
#   options:
#     -h, --help             Display this help message
#     -e, --env ENV          Target environment: dev, qa, stg, prd (default: dev)
#     -n, --rule-name NAME   EventBridge rule name to trigger (required for run action)
#     -p, --path PATH        Path to ECS scheduled task directory (required)
#     -r, --region REGION    AWS region (default: auto-detected via aws configure get region)
#
# Design rules:
#   - Rule 1: Render Jsonnet to JSON first (ecschedule does not support --ext-str)
#   - Rule 2: Clean up temp files on exit via trap
#   - Rule 3: Check diffs before deploying; skip if no changes to avoid unnecessary
#             task definition revisions and EventBridge rule updates
#   - Rule 4: ecspresso diff error (e.g., task def not yet registered) is treated as
#             "has changes" to handle first deploys safely
#   - Rule 5: Script-level diff checking limits to ECS configs/templates only.
#             For script deployment tracking across multiple services/tasks, use
#             CI/CD workflow which detects scripts/ changes via git diff
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
ACTION="apply"
ACCOUNT_ID=""
AWS_REGION="${AWS_REGION:-}"
SCHEDULED_TASK_NAME=""
ENV="dev"
RULE_NAME=""
TASK_PATH=""

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including actions, options, and examples
#
# Arguments:
#   None
#
# Returns:
#   None (outputs to stdout, then exits with status 0)
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options] [action]
Description: Deploy ECS scheduled task (task definition + EventBridge rules)

Actions:
  apply  Register task definition and apply EventBridge rules (default)
  diff   Show diff between local config and remote state
  run    Manually trigger a specific EventBridge rule

Options:
  -h, --help             Display this help message
  -e, --env ENV          Target environment: dev, qa, stg, prd (default: dev)
  -n, --rule-name NAME   EventBridge rule name to trigger (required for run action)
  -p, --path PATH        Path to ECS scheduled task directory (required)
  -r, --region REGION    AWS region (default: auto-detected via aws configure)

Examples:
  $(basename "$0") -p ecs/ecs-scheduled-task/test-batch
  $(basename "$0") -p ecs/ecs-scheduled-task/test-batch -e prd apply
  $(basename "$0") --path ecs/ecs-scheduled-task/test-batch --env dev diff
  $(basename "$0") -p ecs/ecs-scheduled-task/test-batch -e dev run -n dev-test-batch
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and validates required options
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   ACTION     - Set to the provided action (apply, diff, run)
#   AWS_REGION - Set to the provided AWS region
#   ENV        - Set to the provided target environment
#   RULE_NAME  - Set to the EventBridge rule name (for run action)
#   TASK_PATH  - Set to the provided ECS scheduled task directory path
#
# Returns:
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
            -e | --env)
                ENV="$2"
                shift 2
                ;;
            -n | --rule-name)
                RULE_NAME="$2"
                shift 2
                ;;
            -p | --path)
                TASK_PATH="$2"
                shift 2
                ;;
            -r | --region)
                AWS_REGION="$2"
                shift 2
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            apply | diff | run)
                ACTION="$1"
                shift
                ;;
            *)
                error_exit "Unexpected argument: $1"
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "${TASK_PATH}" ]]; then
        echo "Error: --path is required" >&2
        show_usage
    fi

    if [[ "$ACTION" == "run" && -z "${RULE_NAME}" ]]; then
        echo "Error: --rule-name is required for the run action" >&2
        show_usage
    fi
}

#######################################
# apply_scheduled_task: Register task definition and apply EventBridge rules
#
# Description:
#   Step 1: Checks diffs to determine what has changed
#   Step 2: Registers task definition via ecspresso if task definition changed
#   Step 3: Applies EventBridge rules via ecschedule if rules changed
#   Skips deploy entirely if neither has changed (prevents unnecessary revisions)
#
# Arguments:
#   $1 - Path to the rendered ecschedule JSON config (temp file)
#
# Global Variables:
#   ACCOUNT_ID - AWS account ID
#   AWS_REGION - AWS region
#   ENV        - Target environment name
#
# Returns:
#   Exits with status 0 if no changes detected, non-zero on failure
#
# Usage:
#   apply_scheduled_task "$tmp_config"
#
#######################################
function apply_scheduled_task {
    local tmp_config="$1"

    # Task definition diff: empty stdout = no changes
    local td_changed=false td_diff actual_td_diff
    if td_diff=$(ecspresso diff \
        --config ecspresso.jsonnet \
        --ext-str ENV="$ENV" \
        --ext-str SCHEDULED_TASK="$SCHEDULED_TASK_NAME" \
        --ext-str ACCOUNT_ID="$ACCOUNT_ID" \
        --ext-str AWS_REGION="$AWS_REGION" 2>&1); then
        # Filter out log messages to get actual diff content
        actual_td_diff=$(echo "$td_diff" | grep -v "^\[" | grep -v "^20[0-9][0-9]" | grep -v "^\s*$" || true)
        if [[ -n "$actual_td_diff" ]]; then
            td_changed=true
            echo "$actual_td_diff"
        else
            log "INFO" "Task definition: no changes"
        fi
    else
        td_changed=true
        log "INFO" "Task definition: cannot compare (may be first deploy), will register"
    fi

    # EventBridge rules diff: use unified diff format for reliable change detection
    # NOTE: ecschedule diff -u produces git-style unified diff output
    # Empty output = no changes; non-empty output = changes detected
    # Filter out log messages to get actual diff content
    local schedule_changed=false schedule_diff actual_schedule_diff
    if schedule_diff=$(ecschedule -conf "$tmp_config" diff -all -u 2>&1); then
        actual_schedule_diff=$(echo "$schedule_diff" | grep -v "^\[" | grep -v "^20[0-9][0-9]" | grep -v "^\s*$" || true)
        if [[ -n "$actual_schedule_diff" ]]; then
            schedule_changed=true
            echo "$actual_schedule_diff"
        else
            log "INFO" "EventBridge rules: no changes"
        fi
    else
        schedule_changed=true
        log "INFO" "EventBridge rules: diff failed, will apply"
    fi

    if [[ "$td_changed" == "false" && "$schedule_changed" == "false" ]]; then
        log "INFO" "No changes detected, skipping deploy"
        return 0
    fi

    # Step 2: Register task definition via ecspresso if changed
    # ecschedule apply requires the task definition to already exist in ECS
    if [[ "$td_changed" == "true" ]]; then
        echo_section "Registering task definition (ecspresso register)"
        ecspresso register \
            --config ecspresso.jsonnet \
            --ext-str ENV="$ENV" \
            --ext-str SCHEDULED_TASK="$SCHEDULED_TASK_NAME" \
            --ext-str ACCOUNT_ID="$ACCOUNT_ID" \
            --ext-str AWS_REGION="$AWS_REGION"
        log "INFO" "Task definition registered"
    fi

    # Step 3: Apply EventBridge rules via ecschedule if changed
    if [[ "$schedule_changed" == "true" ]]; then
        echo_section "Applying EventBridge rules (ecschedule apply)"
        ecschedule -conf "$tmp_config" apply -all -prune
        log "INFO" "Apply completed"
    fi
}

#######################################
# diff_scheduled_task: Show diff between local config and remote state
#
# Description:
#   Displays the task definition diff via ecspresso and EventBridge rules diff
#   via ecschedule for the specified environment
#
# Arguments:
#   $1 - Path to the rendered ecschedule JSON config (temp file)
#
# Global Variables:
#   ACCOUNT_ID - AWS account ID
#   AWS_REGION - AWS region
#   ENV        - Target environment name
#
# Returns:
#   Exits with non-zero status on failure
#
# Usage:
#   diff_scheduled_task "$tmp_config"
#
#######################################
function diff_scheduled_task {
    local tmp_config="$1"

    echo_section "Task definition diff (ecspresso)"
    ecspresso diff \
        --config ecspresso.jsonnet \
        --ext-str ENV="$ENV" \
        --ext-str SCHEDULED_TASK="$SCHEDULED_TASK_NAME" \
        --ext-str ACCOUNT_ID="$ACCOUNT_ID" \
        --ext-str AWS_REGION="$AWS_REGION" \
        || log "INFO" "(task definition not yet registered)"

    echo_section "EventBridge rules diff (ecschedule)"
    ecschedule -conf "$tmp_config" diff -all

    log "INFO" "Diff completed"
}

#######################################
# run_scheduled_task: Manually trigger a specific EventBridge rule
#
# Description:
#   Triggers a specific EventBridge rule immediately via ecschedule run
#
# Arguments:
#   $1 - Path to the rendered ecschedule JSON config (temp file)
#
# Global Variables:
#   RULE_NAME - EventBridge rule name to trigger
#
# Returns:
#   Exits with non-zero status on failure
#
# Usage:
#   run_scheduled_task "$tmp_config"
#
#######################################
function run_scheduled_task {
    local tmp_config="$1"

    ecschedule -conf "$tmp_config" run -rule "$RULE_NAME"
    log "INFO" "Run completed: ${RULE_NAME}"
}

#######################################
# main: Script entry point
#
# Description:
#   Main function to execute the ECS scheduled task deployment workflow.
#   Renders Jsonnet config to a temporary JSON file for ecschedule,
#   then delegates to the appropriate action function.
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Global Variables:
#   ACTION     - Action to perform (apply, diff, run)
#   ACCOUNT_ID - AWS account ID
#   AWS_REGION - AWS region
#   ENV        - Target environment name
#   RULE_NAME  - EventBridge rule name (for run action)
#   TASK_PATH  - Path to ECS scheduled task directory
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

    # Validate required dependencies
    validate_dependencies "aws" "ecschedule" "ecspresso" "jq" "jsonnet"

    # Check AWS credentials before any AWS CLI usage
    check_aws_credentials || error_exit "AWS credentials are not set or invalid."

    # Auto-detect ACCOUNT_ID and AWS_REGION from AWS CLI
    ACCOUNT_ID=$(get_aws_account_id) || error_exit "Failed to get AWS account ID"
    AWS_REGION="${AWS_REGION:-$(get_aws_region)}"

    # Resolve task path to absolute path
    local abs_path
    abs_path="$(cd "${TASK_PATH}" 2> /dev/null && pwd)" \
        || error_exit "Task path does not exist: ${TASK_PATH}"

    echo_section "${ACTION}: ECS scheduled task in ${abs_path} -> ${ENV}"
    log "INFO" "Account ID: ${ACCOUNT_ID}"
    log "INFO" "Region: ${AWS_REGION}"

    # Change to task directory so ecspresso and ecschedule can find their config files
    cd "${abs_path}"

    # Render Jsonnet to a temporary JSON file
    # ecschedule does not support --ext-str; rendering is handled here by the jsonnet CLI
    # ecspresso supports --ext-str natively, so no pre-rendering is needed for task definitions
    local tmp_config
    tmp_config=$(mktemp /tmp/ecschedule-XXXXXX.json)
    trap 'rm -f "${tmp_config:-}"' EXIT

    echo_section "Rendering configs: ENV=${ENV}"
    jsonnet \
        -V ENV="$ENV" \
        -V ACCOUNT_ID="$ACCOUNT_ID" \
        -V AWS_REGION="$AWS_REGION" \
        ecschedule.jsonnet > "${tmp_config}"

    SCHEDULED_TASK_NAME=$(jq -r '.batch_name' "${tmp_config}")
    if [[ -z "$SCHEDULED_TASK_NAME" || "$SCHEDULED_TASK_NAME" == "null" ]]; then
        error_exit "batch_name is missing in ecschedule.jsonnet output"
    fi
    log "INFO" "Scheduled task name: ${SCHEDULED_TASK_NAME}"

    case "$ACTION" in
        apply)
            apply_scheduled_task "$tmp_config"
            ;;
        diff)
            diff_scheduled_task "$tmp_config"
            ;;
        run)
            run_scheduled_task "$tmp_config"
            ;;
        *)
            error_exit "Unknown action: ${ACTION}. Use: apply, diff, run"
            ;;
    esac

    echo_section "Process completed successfully"
}

# Only call main function if script is executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
