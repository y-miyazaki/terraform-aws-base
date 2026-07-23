#!/bin/bash
#######################################
# Description: Detect failed CI workflow runs and emit structured findings for loop-ci-sweeper
#
# Usage: ./detect_ci_failures.sh [--scope staged|all|range] [--since <ref>]
#   --scope    Change detection scope (default: range)
#              range: consider failures since <ref> (requires --since)
#   --since    Git ref for range scope (commit SHA from loop state)
#
# Output:
# - JSON object with failures[] and skip boolean
#
# Design Rules:
# - Collect failures via gh API (run list/view) filtered by since ref and ledger
# - Return structured JSON via shared lib/json.sh
# - Exit 0 always (errors reported in JSON status field)
# - Skip runs per CI_SWEEPER_REJECT_RETRY_POLICY and ledger state
# - workflow_run event path: match run head branch to loop-detect scan branch
# - Source shared helpers from scripts/lib/all.sh (synced via scripts/self/ai/sync_skill_lib.sh)
#
# Dependencies:
# - bash (POSIX bash, /bin/bash)
# - git
# - gh
# - jq (gh --json parsing only)
#
# Optional environment:
#   CI_SWEEPER_DEBUG_LOG             when true, emit ::notice/::warning diagnostics (also on in GITHUB_ACTIONS)
#   CI_SWEEPER_EVENT_HEAD_BRANCH      workflow_run head branch (stable; not rewritten per scan)
#   CI_SWEEPER_HEAD_BRANCH            per-scan branch context (optional; rewritten by loop-detect)
#   CI_SWEEPER_HEAD_SHA               workflow_run event context (optional)
#   CI_SWEEPER_LEDGER_FILE            Path to run ledger JSON (default: .loop/state-ci-sweeper-run-ledger.json)
#   CI_SWEEPER_REJECT_MAX_RETRIES     Max REJECT retries when policy is limited (default: 3)
#   CI_SWEEPER_REJECT_RETRY_POLICY    block | retry | limited (aliases a/b/c)
#   CI_SWEEPER_RUN_URL                workflow_run event context (optional)
#   CI_SWEEPER_WORKFLOW_NAME          workflow_run event context (optional)
#   CI_SWEEPER_WORKFLOW_RUN_ID        workflow_run event context (optional)
#   DEFAULT_BASE_BRANCH               Fallback branch when checkout context is unavailable
#   DEFAULT_BRANCH                    Alias for DEFAULT_BASE_BRANCH (legacy)
#   GH_TOKEN / GITHUB_TOKEN           GitHub API token
#   SCAN_BRANCH_RUN_LIMIT             Max failed runs to scan per branch (default: 100)
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables
#######################################
SCOPE="range"
SINCE_REF=""

declare -a FAILURES_JSON=()
declare -a IGNORED_JSON=()

#######################################
# show_usage: Display script usage information
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
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
Usage: detect_ci_failures.sh [--scope staged|all|range] [--since <ref>]

Description:
    Detect failed CI workflow runs for the ci-sweeper loop.

Options:
    --scope    Change detection scope (default: range)
               staged: not used for CI detection (accepted for loop-detect parity)
               all: scan recent failures on the checked-out branch (or CI_SWEEPER_HEAD_BRANCH)
               range: consider failures since <ref> (requires --since)
    --since    Git ref for range scope (commit SHA from loop state)

Examples:
    ./detect_ci_failures.sh --scope range --since abc1234
    ./detect_ci_failures.sh --scope all
EOF
    exit 0
}

#######################################
# parse_arguments: Parse command line arguments
#
# Globals:
#   SCOPE - Detection scope
#   SINCE_REF - Git ref for range scope
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   None (calls output_error on invalid input)
#
# Usage:
#   parse_arguments "$@"
#
#######################################
function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help)
                show_usage
                ;;
            --scope)
                if [[ $# -lt 2 ]]; then
                    output_error "--scope requires a value"
                fi
                SCOPE="$2"
                shift 2
                ;;
            --since)
                if [[ $# -lt 2 ]]; then
                    output_error "--since requires a value"
                fi
                SINCE_REF="$2"
                shift 2
                ;;
            *)
                output_error "Unknown argument: $1"
                ;;
        esac
    done

    if [[ ${SCOPE} != "staged" && ${SCOPE} != "all" && ${SCOPE} != "range" ]]; then
        output_error "--scope must be staged, all, or range"
    fi

    if [[ ${SCOPE} == "range" && -z ${SINCE_REF} ]]; then
        output_error "--scope range requires --since <ref>"
    fi
}

#######################################
# output_error: Print structured JSON error and exit
#
# Globals:
#   None
#
# Arguments:
#   $1 - Error message
#
# Outputs:
#   None
#
# Returns:
#   Exits with code 0
#
# Usage:
#   output_error "gh CLI is required"
#
#######################################
function output_error {
    local message="$1"
    json_object_start
    json_field_string "status" "error" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_bool "skip" "true" ","
    json_field_array "failures" "[]" ","
    json_field_array "ignored" "[]" ","
    json_field_string "message" "${message}" ""
    json_object_end
    exit 0
}

#######################################
# validate_ledger_file: Ensure ledger path stays under .loop/
#
# Globals:
#   None
#
# Arguments:
#   $1 - Ledger file path
#
# Outputs:
#   None
#
# Returns:
#   Exits via output_error when invalid
#
#######################################
function validate_ledger_file {
    local path="$1"
    local repo_root resolved ledger_root
    if [[ ${path} != .loop/* ]]; then
        output_error "CI_SWEEPER_LEDGER_FILE must be under .loop/ (got: ${path})"
    fi
    repo_root="$(git rev-parse --show-toplevel 2> /dev/null || pwd)"
    ledger_root="$(realpath -m "${repo_root}/.loop")"
    resolved="$(realpath -m "${repo_root}/${path}")"
    if [[ ${resolved} != "${ledger_root}"/* ]]; then
        output_error "CI_SWEEPER_LEDGER_FILE must stay under .loop/ (got: ${path})"
    fi
}

#######################################
# scan_branch_name: Resolve branch to scan from checkout context
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   Branch name to stdout
#
# Returns:
#   0 on success
#
#######################################
function scan_branch_name {
    local branch="${CI_SWEEPER_HEAD_BRANCH:-}"
    if [[ -z ${branch} ]]; then
        branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null || true)"
    fi
    if [[ -z ${branch} || ${branch} == "HEAD" ]]; then
        branch="${DEFAULT_BRANCH}"
    fi
    printf '%s' "${branch}"
}

#######################################
# is_definition_error_conclusion: Whether the run failed before jobs started
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run conclusion
#
# Outputs:
#   None
#
# Returns:
#   0 when conclusion is a workflow-definition class failure
#
# Usage:
#   if is_definition_error_conclusion "${conclusion}"; then ...
#
#######################################
function is_definition_error_conclusion {
    local conclusion="$1"
    [[ ${conclusion} == "startup_failure" ]]
}

#######################################
# gh_available: Check whether gh and jq are available
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 if available, 1 otherwise
#
# Usage:
#   if ! gh_available; then ...
#
#######################################
function gh_available {
    command -v gh > /dev/null 2>&1 && command -v jq > /dev/null 2>&1
}

#######################################
# commit_is_relevant: Check whether a commit is within the since range
#
# Globals:
#   None
#
# Arguments:
#   $1 - Commit SHA
#
# Outputs:
#   None
#
# Returns:
#   0 if relevant, 1 otherwise
#
# Usage:
#   if commit_is_relevant "${head_sha}"; then ...
#
#######################################
function commit_is_relevant {
    local head_sha="$1"
    if [[ -z ${SINCE_REF} || -z ${head_sha} ]]; then
        return 0
    fi
    if [[ ${SINCE_REF} == "${head_sha}" ]]; then
        return 0
    fi
    if git merge-base --is-ancestor "${SINCE_REF}" "${head_sha}" 2> /dev/null; then
        return 0
    fi
    return 1
}

#######################################
# ledger_outcome_for_run: Read ledger outcome for a workflow run
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#
# Outputs:
#   Outcome string on stdout, empty when not ledgered
#
# Returns:
#   0 on success
#
# Usage:
#   outcome="$(ledger_outcome_for_run "${run_id}")"
#
#######################################
function ledger_outcome_for_run {
    local run_id="$1"
    if [[ ! -f ${LEDGER_FILE} ]]; then
        return 1
    fi
    jq -r --arg run_id "${run_id}" '.runs[$run_id].outcome // empty' "${LEDGER_FILE}" 2> /dev/null || true
}

#######################################
# ledger_reject_count_for_run: Read reject count for a workflow run
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#
# Outputs:
#   Reject count on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   reject_count="$(ledger_reject_count_for_run "${run_id}")"
#
#######################################
function ledger_reject_count_for_run {
    local run_id="$1"
    if [[ ! -f ${LEDGER_FILE} ]]; then
        printf '0'
        return
    fi
    jq -r --arg run_id "${run_id}" '.runs[$run_id].reject_count // 0' "${LEDGER_FILE}" 2> /dev/null || printf '0'
}

#######################################
# normalize_reject_retry_policy: Normalize policy name and aliases
#
# Globals:
#   None
#
# Arguments:
#   $1 - Policy value
#
# Outputs:
#   Normalized policy on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   policy="$(normalize_reject_retry_policy "${REJECT_RETRY_POLICY}")"
#
#######################################
function normalize_reject_retry_policy {
    local policy
    policy="$(printf '%s' "${1:-block}" | tr '[:upper:]' '[:lower:]')"
    case "${policy}" in
        block | retry | limited)
            printf '%s' "${policy}"
            ;;
        a)
            printf 'block'
            ;;
        b)
            printf 'retry'
            ;;
        c)
            printf 'limited'
            ;;
        *)
            printf 'block'
            ;;
    esac
}

#######################################
# run_head_branch_for_run: Resolve head branch for a workflow run ID
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#
# Outputs:
#   Head branch name on stdout, empty when unavailable
#
# Returns:
#   0 on success
#
# Usage:
#   branch="$(run_head_branch_for_run "${run_id}")"
#
#######################################
function run_head_branch_for_run {
    local run_id="$1"
    local branch
    # gh --jq accepts exactly one argument (the expression). Do not pass -r.
    branch="$(gh run view "${run_id}" --json headBranch --jq '.headBranch // empty' 2> /dev/null || true)"
    if [[ -z ${branch} ]]; then
        log_ci_sweeper_warning "head-branch" "run:${run_id}" \
            "gh run view --json headBranch returned empty; falling back to CI_SWEEPER_EVENT_HEAD_BRANCH if set"
    else
        log_ci_sweeper_notice "head-branch" "run:${run_id}" "resolved=${branch}"
    fi
    printf '%s' "${branch}"
}

#######################################
# should_skip_processed_run: Decide whether a run was already processed per policy
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#
# Outputs:
#   None
#
# Returns:
#   0 if the run should be skipped, 1 otherwise
#
# Usage:
#   if should_skip_processed_run "${run_id}"; then ...
#
#######################################
function should_skip_processed_run {
    local run_id="$1"
    local outcome policy reject_count max_retries
    outcome="$(ledger_outcome_for_run "${run_id}")"
    [[ -z ${outcome} ]] && return 1

    policy="$(normalize_reject_retry_policy "${REJECT_RETRY_POLICY}")"
    case "${policy}" in
        block)
            return 0
            ;;
        retry)
            [[ ${outcome} == "pr-created" ]]
            ;;
        limited)
            if [[ ${outcome} == "pr-created" ]]; then
                return 0
            fi
            if [[ ${outcome} == "rejected" ]]; then
                reject_count="$(ledger_reject_count_for_run "${run_id}")"
                max_retries="${REJECT_MAX_RETRIES}"
                [[ ${reject_count} -ge ${max_retries} ]]
                return $?
            fi
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

#######################################
# log_ci_sweeper_notice: Emit a GitHub Actions notice for ci-sweeper detect diagnostics
#
# Globals:
#   None
#
# Arguments:
#   $1 - Stage name
#   $2 - Scope / subject
#   $3 - Detail text
#
# Outputs:
#   None (writes to stderr so stdout JSON/excerpts stay clean)
#
# Returns:
#   0 on success
#
#######################################
function log_ci_sweeper_notice {
    local stage="$1"
    local scope="$2"
    local detail="$3"
    if [[ ${GITHUB_ACTIONS:-} == "true" || ${CI_SWEEPER_DEBUG_LOG:-} == "true" ]]; then
        echo "::notice title=ci-sweeper/${stage}::${scope}: ${detail}" >&2
    fi
}

#######################################
# log_ci_sweeper_warning: Emit a GitHub Actions warning for ci-sweeper detect diagnostics
#
# Globals:
#   None
#
# Arguments:
#   $1 - Stage name
#   $2 - Scope / subject
#   $3 - Detail text
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function log_ci_sweeper_warning {
    local stage="$1"
    local scope="$2"
    local detail="$3"
    if [[ ${GITHUB_ACTIONS:-} == "true" || ${CI_SWEEPER_DEBUG_LOG:-} == "true" ]]; then
        echo "::warning title=ci-sweeper/${stage}::${scope}: ${detail}" >&2
    fi
}

#######################################
# classify_failure_type: Classify failure from log excerpt heuristics
#
# Globals:
#   None
#
# Arguments:
#   $1 - Log excerpt
#
# Outputs:
#   Failure type on stdout (infra, env, flake, regression)
#
# Returns:
#   0 on success
#
# Usage:
#   failure_type="$(classify_failure_type "${log_excerpt}")"
#
#######################################
function classify_failure_type {
    local log_excerpt="$1"
    # Do not match bare 502/503/504 — those appear inside timestamps (e.g. 1850472).
    if grep -qiE 'timeout|timed out|\boom\b|out of memory|\bHTTP[/ ]*50[234]\b|\b50[234] (Bad Gateway|Service Unavailable|Gateway Timeout)\b|service unavailable|registry|rate limit|waiting for a runner|no runners (available|online|found)|runner (has lost|not found|offline|unavailable)|could not acquire a runner|job was not acquired' <<< "${log_excerpt}"; then
        echo "infra"
    elif grep -qiE '(missing|invalid|not found|cannot find).*(secret|credential|api[_-]?key)|(secret|credential|api[_-]?key).*(missing|invalid|not found)|(AWS_|GITHUB_TOKEN|GH_TOKEN).*(missing|invalid|not set)|permission denied.*/(secrets|credentials)' <<< "${log_excerpt}"; then
        echo "env"
    elif grep -qiE '\b(flake|flaky|intermittent)\b|\b(retries|retrying)\b' <<< "${log_excerpt}"; then
        echo "flake"
    else
        echo "regression"
    fi
}

#######################################
# sanitize_log_excerpt: Redact likely secrets from CI log text
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function sanitize_log_excerpt {
    local excerpt="$1"
    excerpt="$(sed -E 's/gh[pousr]_[A-Za-z0-9_]{20,}/[REDACTED]/g' <<< "${excerpt}")"
    excerpt="$(sed -E 's/AKIA[0-9A-Z]{16}/[REDACTED]/g' <<< "${excerpt}")"
    excerpt="$(sed -E 's/(password|secret|token|api[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]\"]+/\1=[REDACTED]/gi' <<< "${excerpt}")"
    excerpt="$(sed -E 's/x-access-token:[A-Za-z0-9._-]+/x-access-token:[REDACTED]/g' <<< "${excerpt}")"
    excerpt="$(sed -E 's/Bearer[[:space:]]+[A-Za-z0-9._-]+/Bearer [REDACTED]/g' <<< "${excerpt}")"
    excerpt="$(sed -E 's/Authorization:[[:space:]]*[^[:space:]\"]+/Authorization: [REDACTED]/gi' <<< "${excerpt}")"
    excerpt="$(sed -E 's/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/[REDACTED-JWT]/g' <<< "${excerpt}")"
    excerpt="$(sed -E 's/-----BEGIN [A-Z ]+-----[^-]*-----END [A-Z ]+-----/[REDACTED-PEM]/g' <<< "${excerpt}")"
    printf '%s' "${excerpt}"
}

#######################################
# fetch_failed_jobs: Fetch failed jobs for a workflow run
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#
# Outputs:
#   JSON lines for failed jobs on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   fetch_failed_jobs "${run_id}"
#
#######################################
function fetch_failed_jobs {
    local run_id="$1"
    gh run view "${run_id}" --json jobs --jq \
        '.jobs[] | select(.conclusion == "failure") | {name: .name, conclusion: .conclusion, url: .html_url}' \
        2> /dev/null || true
}

#######################################
# fetch_log_excerpt: Fetch truncated failed log excerpt for a job
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#   $2 - Job name
#
# Outputs:
#   Log excerpt on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   log_excerpt="$(fetch_log_excerpt "${run_id}" "${job_name}")"
#
#######################################
function fetch_log_excerpt {
    local run_id="$1"
    local job_name="$2"
    local raw excerpt diagnostics mode raw_bytes excerpt_bytes
    raw="$(gh run view "${run_id}" --log-failed 2> /dev/null || true)"
    raw_bytes="${#raw}"
    if [[ -n ${job_name} ]]; then
        excerpt="$(grep -F "${job_name}" <<< "${raw}" || true)"
    fi
    if [[ -z ${excerpt:-} ]]; then
        excerpt="${raw}"
        if [[ -n ${job_name} ]]; then
            log_ci_sweeper_notice "log-excerpt" "run:${run_id}" \
                "job_filter_miss job=${job_name} raw_bytes=${raw_bytes}; using full failed log"
        fi
    fi
    # Prefer actionable diagnostics over trailing summary/cleanup noise.
    diagnostics="$(grep -iE '##\[error\]|##\[warning\]|\bMD[0-9]{3}\b|\berror:|\bfailed:|\bSC[0-9]{4}\b' <<< "${excerpt}" || true)"
    if [[ -n ${diagnostics} ]]; then
        excerpt="${diagnostics}"
        mode="diagnostics"
    else
        excerpt="$(tail -n 80 <<< "${excerpt}" || true)"
        mode="tail80"
        log_ci_sweeper_warning "log-excerpt" "run:${run_id}" \
            "no diagnostic lines for job=${job_name}; using ${mode} (may omit lint rule IDs)"
    fi
    excerpt="${excerpt:0:4000}"
    excerpt="$(sanitize_log_excerpt "${excerpt}")"
    excerpt_bytes="${#excerpt}"
    log_ci_sweeper_notice "log-excerpt" "run:${run_id}" \
        "job=${job_name} mode=${mode} raw_bytes=${raw_bytes} excerpt_bytes=${excerpt_bytes}"
    printf '%s' "${excerpt}"
}

#######################################
# fetch_definition_error_excerpt: Build context for startup_failure runs
#
# Globals:
#   None
#
# Arguments:
#   $1 - Workflow run ID
#   $2 - Workflow run conclusion
#
# Outputs:
#   Log excerpt on stdout
#
# Returns:
#   0 on success
#
# Usage:
#   fetch_definition_error_excerpt "${run_id}" "${conclusion}"
#
#######################################
function fetch_definition_error_excerpt {
    local run_id="$1"
    local conclusion="$2"
    local detail
    detail="$(gh run view "${run_id}" --json event,workflowName,displayTitle,conclusion \
        --jq '"workflow=" + .workflowName + " conclusion=" + .conclusion + " event=" + .event + " title=" + .displayTitle' \
        2> /dev/null || true)"
    printf 'Workflow run failed before jobs started (%s). %s Inspect caller/callee workflow permissions and reusable workflow references.' \
        "${conclusion}" "${detail}"
}

#######################################
# failure_object_json: Build one failure object as JSON
#
# Globals:
#   None
#
# Arguments:
#   $1-$8 - workflow_name, run_id, head_sha, head_branch, run_url, job_name, failure_type, log_excerpt
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   failure_object_json "${workflow_name}" ...
#
#######################################
function failure_object_json {
    local workflow_name="$1"
    local run_id="$2"
    local head_sha="$3"
    local head_branch="$4"
    local run_url="$5"
    local job_name="$6"
    local failure_type="$7"
    local log_excerpt="$8"
    local reason="CI failure in job ${job_name} (${failure_type})"

    cat << EOF
{
  "workflow_name": "$(json_escape "${workflow_name}")",
  "workflow_run_id": "$(json_escape "${run_id}")",
  "head_sha": "$(json_escape "${head_sha}")",
  "head_branch": "$(json_escape "${head_branch}")",
  "job_name": "$(json_escape "${job_name}")",
  "failure_type": "$(json_escape "${failure_type}")",
  "log_excerpt": "$(json_escape "${log_excerpt}")",
  "run_url": "$(json_escape "${run_url}")",
  "source_commit": "$(json_escape "${head_sha}")",
  "reason": "$(json_escape "${reason}")"
}
EOF
}

#######################################
# append_failure: Append one failure object to FAILURES_JSON
#
# Globals:
#   None
#
# Arguments:
#   $1-$8 - workflow_name, run_id, head_sha, head_branch, run_url, job_name, failure_type, log_excerpt
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   append_failure "${workflow_name}" ...
#
#######################################
function append_failure {
    local workflow_name="$1"
    local run_id="$2"
    local head_sha="$3"
    local head_branch="$4"
    local run_url="$5"
    local job_name="$6"
    local failure_type="$7"
    local log_excerpt="$8"

    FAILURES_JSON+=("$(failure_object_json "${workflow_name}" "${run_id}" "${head_sha}" "${head_branch}" \
        "${run_url}" "${job_name}" "${failure_type}" "${log_excerpt}")")
}

#######################################
# ignored_object_json: Build one ignored entry as JSON
#
# Globals:
#   None
#
# Arguments:
#   $1-$6 - workflow_name, run_id, head_branch, job_name, failure_type, reason
#
# Outputs:
#   JSON object to stdout
#
# Returns:
#   0 on success
#
#######################################
function ignored_object_json {
    local workflow_name="$1"
    local run_id="$2"
    local head_branch="$3"
    local job_name="$4"
    local failure_type="$5"
    local reason="$6"

    cat << EOF
{
  "workflow_name": "$(json_escape "${workflow_name}")",
  "workflow_run_id": "$(json_escape "${run_id}")",
  "head_branch": "$(json_escape "${head_branch}")",
  "job_name": "$(json_escape "${job_name}")",
  "failure_type": "$(json_escape "${failure_type}")",
  "reason": "$(json_escape "${reason}")"
}
EOF
}

#######################################
# append_ignored: Append one ignored entry to IGNORED_JSON
#
# Globals:
#   None
#
# Arguments:
#   $1-$6 - workflow_name, run_id, head_branch, job_name, failure_type, reason
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function append_ignored {
    local workflow_name="$1"
    local run_id="$2"
    local head_branch="$3"
    local job_name="$4"
    local failure_type="$5"
    local reason="$6"

    log_ci_sweeper_notice "ignored" "run:${run_id}" \
        "workflow=${workflow_name} branch=${head_branch} job=${job_name} type=${failure_type} reason=${reason}"
    IGNORED_JSON+=("$(ignored_object_json "${workflow_name}" "${run_id}" "${head_branch}" \
        "${job_name}" "${failure_type}" "${reason}")")
}

#######################################
# collect_failures_for_run: Collect failures from one workflow run
#
# Globals:
#   None
#
# Arguments:
#   $1-$5 - workflow_name, run_id, head_sha, head_branch, run_url
#   $6    - Workflow run conclusion (optional; fetched when empty)
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   collect_failures_for_run "${workflow_name}" ...
#
#######################################
function collect_failures_for_run {
    local workflow_name="$1"
    local run_id="$2"
    local head_sha="$3"
    local head_branch="$4"
    local run_url="$5"
    local run_conclusion="${6:-}"
    local ledger_outcome

    if [[ -z ${run_conclusion} ]]; then
        run_conclusion="$(gh run view "${run_id}" --json conclusion --jq '.conclusion // empty' 2> /dev/null || true)"
    fi

    if should_skip_processed_run "${run_id}"; then
        ledger_outcome="$(ledger_outcome_for_run "${run_id}")"
        append_ignored "${workflow_name}" "${run_id}" "${head_branch}" "-" "-" \
            "ledger: ${ledger_outcome:-processed}"
        return 0
    fi

    if ! commit_is_relevant "${head_sha}"; then
        append_ignored "${workflow_name}" "${run_id}" "${head_branch}" "-" "-" \
            "outside since range"
        return 0
    fi

    local job_line job_name log_excerpt failure_type
    if is_definition_error_conclusion "${run_conclusion}" \
        && ! fetch_failed_jobs "${run_id}" | grep -q .; then
        log_excerpt="$(fetch_definition_error_excerpt "${run_id}" "${run_conclusion}")"
        append_failure "${workflow_name}" "${run_id}" "${head_sha}" "${head_branch}" "${run_url}" \
            "workflow" "regression" "${log_excerpt}"
        return 0
    fi

    if ! fetch_failed_jobs "${run_id}" | grep -q .; then
        append_failure "${workflow_name}" "${run_id}" "${head_sha}" "${head_branch}" "${run_url}" \
            "unknown" "regression" "Failed workflow run with no failed job metadata."
        return 0
    fi

    while IFS= read -r job_line; do
        [[ -z ${job_line} ]] && continue
        job_name="$(jq -r '.name' <<< "${job_line}")"
        log_excerpt="$(fetch_log_excerpt "${run_id}" "${job_name}")"
        failure_type="$(classify_failure_type "${log_excerpt}")"
        preview="$(sanitize_log_excerpt "$(printf '%.120s' "${log_excerpt}" | tr -d '\n\r')")"
        log_ci_sweeper_notice "classify" "run:${run_id}" \
            "job=${job_name} failure_type=${failure_type} excerpt_bytes=${#log_excerpt} preview=${preview}"
        append_failure "${workflow_name}" "${run_id}" "${head_sha}" "${head_branch}" "${run_url}" \
            "${job_name}" "${failure_type}" "${log_excerpt}"
    done < <(fetch_failed_jobs "${run_id}")
}

#######################################
# collect_from_workflow_run_event: Collect failures from workflow_run event env context
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   0 when event context is present, 1 otherwise
#
# Usage:
#   if collect_from_workflow_run_event; then ...
#
#######################################
function collect_from_workflow_run_event {
    local run_id="${CI_SWEEPER_WORKFLOW_RUN_ID:-}"
    local workflow_name="${CI_SWEEPER_WORKFLOW_NAME:-}"
    local head_sha="${CI_SWEEPER_HEAD_SHA:-}"
    local head_branch="${CI_SWEEPER_HEAD_BRANCH:-}"
    local run_url="${CI_SWEEPER_RUN_URL:-}"
    local scan_branch actual_head_branch resolved_head_branch event_head_branch

    if [[ -z ${run_id} ]]; then
        return 1
    fi

    scan_branch="$(scan_branch_name)"
    event_head_branch="${CI_SWEEPER_EVENT_HEAD_BRANCH:-}"
    actual_head_branch="$(run_head_branch_for_run "${run_id}")"
    # EVENT_HEAD_BRANCH is set by the caller from workflow_run and must not be
    # overwritten per scan context (loop-detect rewrites CI_SWEEPER_HEAD_BRANCH).
    resolved_head_branch="${actual_head_branch:-${event_head_branch}}"
    log_ci_sweeper_notice "workflow-run" "run:${run_id}" \
        "workflow=${workflow_name} scan=${scan_branch} api_head=${actual_head_branch:-empty} event_head=${event_head_branch:-empty} resolved=${resolved_head_branch:-empty} head_sha=${head_sha}"
    if [[ -z ${resolved_head_branch} ]]; then
        log_ci_sweeper_warning "workflow-run" "run:${run_id}" \
            "IGNORE head branch unknown (api and CI_SWEEPER_EVENT_HEAD_BRANCH empty); refusing to attach failure"
        append_ignored "${workflow_name}" "${run_id}" "${scan_branch}" "-" "-" \
            "head branch unknown"
        return 0
    fi
    if [[ ${resolved_head_branch} != "${scan_branch}" ]]; then
        log_ci_sweeper_notice "workflow-run" "run:${run_id}" \
            "IGNORE branch mismatch (scan=${scan_branch} != resolved=${resolved_head_branch}); not attaching this failure to scan context"
        append_ignored "${workflow_name}" "${run_id}" "${resolved_head_branch}" "-" "-" \
            "branch mismatch (scan=${scan_branch})"
        return 0
    fi

    log_ci_sweeper_notice "workflow-run" "run:${run_id}" \
        "ACCEPT attaching failure to scan=${scan_branch}"
    collect_failures_for_run "${workflow_name}" "${run_id}" "${head_sha}" \
        "${resolved_head_branch}" "${run_url}"
}

#######################################
# collect_recent_failures: Collect recent failed runs from the current scan branch
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   collect_recent_failures
#
#######################################
function collect_recent_failures {
    local runs_json run_line run_id workflow_name head_sha head_branch run_url run_conclusion scan_branch
    local failure_runs startup_runs
    scan_branch="$(scan_branch_name)"
    failure_runs="$(gh run list --branch "${scan_branch}" --status failure --limit "${SCAN_BRANCH_RUN_LIMIT}" --json \
        databaseId,headSha,headBranch,url,workflowName,conclusion 2> /dev/null || echo '[]')"
    startup_runs="$(gh run list --branch "${scan_branch}" --limit "${SCAN_BRANCH_RUN_LIMIT}" --json \
        databaseId,headSha,headBranch,url,workflowName,conclusion 2> /dev/null \
        | jq '[.[] | select(.conclusion == "startup_failure")]' 2> /dev/null || echo '[]')"
    runs_json="$(jq -s 'add | unique_by(.databaseId)' <<< "$(printf '%s\n%s' "${failure_runs}" "${startup_runs}")")"

    while IFS= read -r run_line; do
        [[ -z ${run_line} ]] && continue
        run_id="$(jq -r '.databaseId' <<< "${run_line}")"
        workflow_name="$(jq -r '.workflowName' <<< "${run_line}")"
        head_sha="$(jq -r '.headSha' <<< "${run_line}")"
        head_branch="$(jq -r '.headBranch' <<< "${run_line}")"
        run_url="$(jq -r '.url' <<< "${run_line}")"
        run_conclusion="$(jq -r '.conclusion' <<< "${run_line}")"
        collect_failures_for_run "${workflow_name}" "${run_id}" "${head_sha}" "${head_branch}" \
            "${run_url}" "${run_conclusion}"
    done < <(jq -c '.[]' <<< "${runs_json}")
}

#######################################
# failures_array_json: Join failure objects into a JSON array string
#
# Globals:
#   FAILURES_JSON - Source failure objects
#
# Arguments:
#   None
#
# Outputs:
#   JSON array string to stdout
#
# Returns:
#   0 on success
#
# Usage:
#   failures_array="$(failures_array_json)"
#
#######################################
function failures_array_json {
    local joined=""
    local failure
    if [[ ${#FAILURES_JSON[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi
    for failure in "${FAILURES_JSON[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${failure}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# ignored_array_json: Join ignored objects into a JSON array string
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
#######################################
function ignored_array_json {
    local joined=""
    local ignored
    if [[ ${#IGNORED_JSON[@]} -eq 0 ]]; then
        printf '%s' "[]"
        return
    fi
    for ignored in "${IGNORED_JSON[@]}"; do
        if [[ -n ${joined} ]]; then
            joined+=","
        fi
        joined+="${ignored}"
    done
    printf '[%s]' "${joined}"
}

#######################################
# output_json: Print structured JSON result using lib/json.sh helpers
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   output_json
#
#######################################
function output_json {
    local skip="false"
    local failures_array ignored_array

    if [[ ${#FAILURES_JSON[@]} -eq 0 ]]; then
        skip="true"
    fi

    failures_array="$(failures_array_json)"
    ignored_array="$(ignored_array_json)"

    json_object_start
    json_field_string "status" "ok" ","
    json_field_string "scope" "${SCOPE}" ","
    json_field_string "since" "${SINCE_REF}" ","
    json_field_bool "skip" "${skip}" ","
    json_field_array "failures" "${failures_array}" ","
    json_field_array "ignored" "${ignored_array}" ""
    json_object_end
}

#######################################
# configure_detect_environment: Normalize domain env into globals once at startup
#
# Globals:
#   DEFAULT_BRANCH - Fallback branch when checkout context is unavailable
#   LEDGER_FILE - Path to run ledger JSON
#   SCAN_BRANCH_RUN_LIMIT - Max failed runs to scan per branch
#   REJECT_RETRY_POLICY - block | retry | limited
#   REJECT_MAX_RETRIES - Max REJECT retries when policy is limited
#
# Arguments:
#   None
#
# Outputs:
#   None
#
# Returns:
#   None
#
# Usage:
#   configure_detect_environment
#
#######################################
function configure_detect_environment {
    DEFAULT_BRANCH="${DEFAULT_BASE_BRANCH:-${DEFAULT_BRANCH:-main}}"
    LEDGER_FILE="${CI_SWEEPER_LEDGER_FILE:-.loop/state-ci-sweeper-run-ledger.json}"
    LEDGER_FILE="${LEDGER_FILE#./}"
    SCAN_BRANCH_RUN_LIMIT="${SCAN_BRANCH_RUN_LIMIT:-100}"
    REJECT_RETRY_POLICY="${CI_SWEEPER_REJECT_RETRY_POLICY:-block}"
    REJECT_MAX_RETRIES="${CI_SWEEPER_REJECT_MAX_RETRIES:-3}"
}

#######################################
# main: Entry point
#
# Globals:
#   None
#
# Arguments:
#   $@ - Command line arguments
#
# Outputs:
#   None
#
# Returns:
#   0 always
#
# Usage:
#   main "$@"
#
#######################################
function main {
    configure_detect_environment
    parse_arguments "$@"
    validate_ledger_file "${LEDGER_FILE}"

    if ! gh_available; then
        output_error "gh CLI and jq are required but not installed"
    fi

    if [[ -z ${GH_TOKEN:-} && -z ${GITHUB_TOKEN:-} ]]; then
        output_error "GH_TOKEN or GITHUB_TOKEN is required"
    fi

    export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

    if collect_from_workflow_run_event; then
        log_ci_sweeper_notice "main" "path" "workflow_run event path (CI_SWEEPER_WORKFLOW_RUN_ID set)"
    else
        log_ci_sweeper_notice "main" "path" "recent failures scan path (no workflow_run id)"
        collect_recent_failures
    fi

    log_ci_sweeper_notice "main" "result" \
        "failures=${#FAILURES_JSON[@]} ignored=${#IGNORED_JSON[@]} skip=$([ ${#FAILURES_JSON[@]} -eq 0 ] && echo true || echo false)"

    output_json
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    main "$@"
fi
