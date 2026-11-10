#!/bin/bash
#######################################
# Description: Moves CloudWatch Logs objects delivered by Firehose from the old S3 layout
#   <prefix>/<stream>/... to <prefix>/AWSLogs/<account-id>/cloudwatchlogs/<region>/<stream>/...
#
# Usage: ./aws_migrate_firehose_log_prefix.sh [options]
#   options:
#     -h, --help               Display this help message
#     -b, --bucket NAME        (Required) Destination S3 bucket name
#     -r, --region REGION      (Required) Region the old objects were delivered from (used in the new key)
#     -n, --name-prefix PREFIX Only move old prefixes starting with this (default: base-)
#     -p, --prefix PREFIX      Key prefix used by Firehose (default: Logs/)
#     -j, --jobs N             Number of old prefixes processed concurrently (default: 1)
#     -x, --execute            Actually move objects (default: dry-run, list only)
#
# Output:
# - Per old prefix: source/destination prefixes
#
# Design Rules:
# - Dry-run by default; --execute is required to modify the bucket
# - Targets old prefixes found by listing S3 under the key prefix, not Firehose, so objects of
#   deleted delivery streams and of names truncated to 63 chars by Firehose are also moved
# - Only prefixes starting with the name prefix are moved (AWSLogs/CloudFront/Athena/canary are untouched)
# - Uses `aws s3 mv --recursive`, which copies then deletes each object (S3 has no rename)
# - Old keys lack the region. If same-named streams exist in several regions, their
#   objects are mixed in the old prefix and all of them move to the region given here
# - --jobs runs one `aws s3 mv` per old prefix at a time, up to N. Each `aws s3 mv` already
#   issues parallel requests itself, so total concurrency is about N x the AWS CLI's
#   max_concurrent_requests (default 10). Source and destination prefixes never overlap
#   between jobs. Output is buffered per prefix and printed when it finishes. After a failure,
#   no new prefix is started and running ones finish; the exit status is non-zero
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables
#######################################
BUCKET=""
REGION=""
NAME_PREFIX="base-"
KEY_PREFIX="Logs/"
EXECUTE=false
JOBS=1
# Scratch directory for per-prefix output of concurrent jobs; removed on exit
WORK_DIR=""

#######################################
# show_usage: Display script usage information
#
# Description:
#   Displays usage information for the script, including options and examples
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Writes to stdout
#
# Returns:
#   None
#
# Usage:
#   show_usage
#
#######################################
function show_usage {
    cat << EOF
Usage: $(basename "$0") [options]

Description: Moves Firehose-delivered CloudWatch Logs objects to the AWSLogs layout
             (old prefixes are discovered from S3, not from Firehose).
             Runs as a dry-run unless --execute is given.

Options:
  -h, --help                Display this help message
  -b, --bucket NAME         (Required) Destination S3 bucket name
  -r, --region REGION       (Required) Region the old objects were delivered from
  -n, --name-prefix PREFIX  Only move old prefixes starting with this (default: ${NAME_PREFIX})
  -p, --prefix PREFIX       Key prefix used by Firehose (default: ${KEY_PREFIX})
  -j, --jobs N              Old prefixes processed concurrently (default: ${JOBS})
  -x, --execute             Actually move objects (default: dry-run)

Example: $(basename "$0") -b base-aws-log-application-123456789012 -r ap-northeast-1
         $(basename "$0") -b base-aws-log-application-123456789012 -r ap-northeast-1 --execute
         $(basename "$0") -b base-aws-log-application-123456789012 -r ap-northeast-1 --execute --jobs 8
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Description:
#   Parses command line arguments and options, handling help and unknown options
#
# Globals:
#   BUCKET, REGION, NAME_PREFIX, KEY_PREFIX, EXECUTE, JOBS
#
# Arguments:
#   $@ - All command line arguments passed to the script
#
# Outputs:
#   None
#
# Returns:
#   Exits with error if unknown or missing arguments are provided
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
            -b | --bucket)
                [[ $# -ge 2 ]] || error_exit "Option $1 requires a value"
                BUCKET="$2"
                shift 2
                ;;
            -r | --region)
                [[ $# -ge 2 ]] || error_exit "Option $1 requires a value"
                REGION="$2"
                shift 2
                ;;
            -n | --name-prefix)
                [[ $# -ge 2 ]] || error_exit "Option $1 requires a value"
                NAME_PREFIX="$2"
                shift 2
                ;;
            -p | --prefix)
                [[ $# -ge 2 ]] || error_exit "Option $1 requires a value"
                KEY_PREFIX="$2"
                shift 2
                ;;
            -j | --jobs)
                [[ $# -ge 2 ]] || error_exit "Option $1 requires a value"
                [[ $2 =~ ^[1-9][0-9]*$ ]] || error_exit "--jobs must be a positive integer: $2"
                JOBS="$2"
                shift 2
                ;;
            -x | --execute)
                EXECUTE=true
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                error_exit "Unexpected argument: $1"
                ;;
        esac
    done

    [[ -n $BUCKET ]] || error_exit "--bucket is required"
    [[ -n $REGION ]] || error_exit "--region is required"
    # Normalize to exactly one trailing slash
    KEY_PREFIX="${KEY_PREFIX%/}/"
}

#######################################
# flush_finished: Print output of finished concurrent jobs once
#
# Description:
#   Scans the first N launched jobs, prints the buffered output of each finished job that has
#   not been printed yet, and records the prefix name of every failed job
#
# Globals:
#   WORK_DIR, UNIT_NAMES, FAILED_NAMES
#
# Arguments:
#   $1 - Number of jobs launched so far
#
# Outputs:
#   Buffered job output to stdout
#
# Returns:
#   0 always
#
# Usage:
#   flush_finished "$launched"
#
#######################################
function flush_finished {
    local launched="$1"
    local idx rc

    for ((idx = 0; idx < launched; idx++)); do
        [[ -f "${WORK_DIR}/${idx}.rc" && ! -f "${WORK_DIR}/${idx}.done" ]] || continue
        cat "${WORK_DIR}/${idx}.out"
        rc=$(< "${WORK_DIR}/${idx}.rc")
        if [[ $rc -ne 0 ]]; then
            FAILED_NAMES+=("${UNIT_NAMES[idx]}")
        fi
        : > "${WORK_DIR}/${idx}.done"
    done
}

#######################################
# list_old_prefix_names: List old-layout directory names in the bucket
#
# Description:
#   Lists first-level directories under KEY_PREFIX whose name starts with NAME_PREFIX,
#   excluding the new AWSLogs layout. Does not call Firehose, so deleted delivery streams
#   and names truncated by Firehose are included.
#
# Globals:
#   BUCKET, KEY_PREFIX, NAME_PREFIX
#
# Arguments:
#   None
#
# Outputs:
#   Directory names without prefix or trailing slash, one per line
#
# Returns:
#   0 on success
#
# Usage:
#   mapfile -t names < <(list_old_prefix_names)
#
#######################################
function list_old_prefix_names {
    aws s3api list-objects-v2 --bucket "$BUCKET" --prefix "$KEY_PREFIX" --delimiter / --output json \
        | jq -r --arg k "$KEY_PREFIX" --arg p "$NAME_PREFIX" \
            '(.CommonPrefixes // [])[].Prefix | ltrimstr($k) | rtrimstr("/") | select(startswith($p))'
}

#######################################
# migrate_all: Migrate every old prefix, up to JOBS at a time
#
# Description:
#   With JOBS=1 prefixes are processed in order and stream their output. With JOBS>1 each
#   prefix runs in a background job whose output is buffered and printed when it finishes.
#   After the first failure no new prefix is started; running jobs finish, then the script
#   exits non-zero naming the failed prefixes.
#
# Globals:
#   JOBS, WORK_DIR, UNIT_NAMES, FAILED_NAMES
#
# Arguments:
#   $@ - Old prefix directory names
#
# Outputs:
#   Progress messages to stdout
#
# Returns:
#   0 on success, exits on failure
#
# Usage:
#   migrate_all "${names[@]}"
#
#######################################
function migrate_all {
    UNIT_NAMES=("$@")
    FAILED_NAMES=()
    local total=${#UNIT_NAMES[@]}
    local launched=0 running=0 not_started msg names_joined

    if [[ $JOBS -le 1 ]]; then
        local name
        for name in "${UNIT_NAMES[@]}"; do
            migrate_stream "$name"
        done
        return 0
    fi

    WORK_DIR="$(mktemp -d)"
    trap 'rm -rf "${WORK_DIR}"' EXIT

    while [[ $launched -lt $total ]]; do
        if [[ $running -ge $JOBS ]]; then
            wait -n || true
            running=$((running - 1))
            flush_finished "$launched"
        fi
        [[ ${#FAILED_NAMES[@]} -eq 0 ]] || break
        run_unit "$launched" "${UNIT_NAMES[launched]}" &
        launched=$((launched + 1))
        running=$((running + 1))
    done
    wait
    flush_finished "$launched"

    if [[ ${#FAILED_NAMES[@]} -gt 0 ]]; then
        not_started=$((total - launched))
        names_joined="$(printf '%s, ' "${FAILED_NAMES[@]}")"
        msg="${#FAILED_NAMES[@]} of ${total} prefixes failed: ${names_joined%, }"
        [[ $not_started -eq 0 ]] || msg="${msg}; ${not_started} not started"
        error_exit "$msg"
    fi
}

#######################################
# migrate_stream: Move objects of one old prefix
#
# Description:
#   Moves objects from the old prefix to the new prefix. Object counts are not taken (listing
#   every object is slow on large prefixes); a failed `aws s3 mv` aborts via errexit.
#
# Globals:
#   BUCKET, KEY_PREFIX, EXECUTE, ACCOUNT_ID, REGION
#
# Arguments:
#   $1 - Old prefix directory name
#
# Outputs:
#   Progress messages to stdout
#
# Returns:
#   0 on success, non-zero when the move fails
#
# Usage:
#   migrate_stream "base-foo"
#
#######################################
function migrate_stream {
    local name="$1"
    local src="${KEY_PREFIX}${name}/"
    local dst="${KEY_PREFIX}AWSLogs/${ACCOUNT_ID}/cloudwatchlogs/${REGION}/${name}/"

    echo "s3://${BUCKET}/${src} -> s3://${BUCKET}/${dst}"

    if [[ $EXECUTE != true ]]; then
        return 0
    fi

    aws s3 mv "s3://${BUCKET}/${src}" "s3://${BUCKET}/${dst}" --recursive --only-show-errors
    echo "  moved"
}

#######################################
# run_unit: Run migrate_stream as a background job with buffered output
#
# Description:
#   Runs migrate_stream in a subshell with errexit enabled, writes its output to
#   WORK_DIR/<index>.out and its exit status to WORK_DIR/<index>.rc. errexit is enabled inside
#   the subshell (not via `|| rc=$?`) because a subshell on the left of `||` ignores `set -e`,
#   which would let a failed step fall through to the next one.
#
# Globals:
#   WORK_DIR
#
# Arguments:
#   $1 - Job index
#   $2 - Old prefix directory name
#
# Outputs:
#   None (writes files under WORK_DIR)
#
# Returns:
#   0 always; the job status is in the .rc file
#
# Usage:
#   run_unit 0 "base-foo" &
#
#######################################
function run_unit {
    local idx="$1"
    local name="$2"
    local rc

    set +e
    (
        set -e
        migrate_stream "$name"
    ) > "${WORK_DIR}/${idx}.out" 2>&1
    rc=$?
    set -e
    echo "$rc" > "${WORK_DIR}/${idx}.rc"
}

#######################################
# main: Entry point
#
# Description:
#   Resolves the account ID and migrates every old prefix found in S3
#
# Globals:
#   ACCOUNT_ID, EXECUTE, BUCKET, REGION
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   Progress messages to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   main "$@"
#
#######################################
function main {
    parse_arguments "$@"
    require_dependencies aws jq

    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

    if [[ $EXECUTE == true ]]; then
        echo_section "Migrating (EXECUTE) bucket=${BUCKET} region=${REGION}"
    else
        echo_section "Dry-run (no changes) bucket=${BUCKET} region=${REGION}; add --execute to move"
    fi

    local names=()
    mapfile -t names < <(list_old_prefix_names)
    [[ ${#names[@]} -gt 0 ]] || error_exit "No old prefixes starting with '${NAME_PREFIX}' under s3://${BUCKET}/${KEY_PREFIX}"

    migrate_all "${names[@]}"
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
