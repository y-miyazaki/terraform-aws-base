#!/usr/bin/env bash
# Shared helpers for test/bats suites.
#
# Conventions (all *.bats under test/bats/):
# - Header: `# Tests for <repo-relative path>`
# - Load this file via the walk-up preamble placed after the header in each suite.
# - setup(): source targets with bats_source_rel / bats_source_apm_skill; export temp state.
# - teardown(): remove artifacts created in setup when applicable.
# - Suites assume cwd is the repository root (see scripts/shell-script/validate.sh).

# bats_workspace_root: Print absolute repository root
#
# Returns:
#   Repository root path on stdout
#
function bats_workspace_root {
    local dir
    dir="$(cd "$(dirname "${BATS_TEST_FILENAME}")" && pwd)"
    while [[ ! -f "${dir}/apm.yml" ]]; do
        if [[ ${dir} == "/" ]]; then
            break
        fi
        dir="$(dirname "${dir}")"
    done
    printf '%s' "${dir}"
}

# bats_support_dir: Print absolute test/bats/support directory
#
# Returns:
#   Support directory path on stdout
#
function bats_support_dir {
    local dir
    dir="$(dirname "${BATS_TEST_FILENAME}")"
    while [[ ! -f "${dir}/support/common.bash" ]]; do
        dir="$(dirname "${dir}")"
    done
    printf '%s/support' "${dir}"
}

# bats_source_rel: Source a repository-relative script path
#
# Arguments:
#   $1 - Path relative to repository root
#
function bats_source_rel {
    local rel="$1"
    # shellcheck disable=SC1090,SC1091
    source "${rel}"
}

# apm_skill_script_path: Resolve an APM loop skill script path
#
# Arguments:
#   $1 - Package name (for example loop-changelog)
#   $2 - Script file name (for example detect_changelog_commits.sh)
#
# Returns:
#   Absolute script path on stdout
#
function apm_skill_script_path {
    local package="$1"
    local script="$2"
    printf '%s/.apm/packages/%s/.apm/skills/%s/scripts/%s' \
        "$(bats_workspace_root)" "${package}" "${package}" "${script}"
}

# bats_source_apm_skill: Source an APM loop skill script
#
# Arguments:
#   $1 - Package name
#   $2 - Script file name
#
function bats_source_apm_skill {
    local package="$1"
    local script="$2"
    # shellcheck disable=SC1090,SC1091
    source "$(apm_skill_script_path "${package}" "${script}")"
}

# git_test_repo_setup: Create an isolated git repository for integration tests
#
# Global Variables:
#   GIT_TEST_REPO - Path to the temporary repository
#
function git_test_repo_setup {
    GIT_TEST_REPO="${BATS_TEST_TMPDIR}/repo"
    rm -rf "${GIT_TEST_REPO}"
    mkdir -p "${GIT_TEST_REPO}"
    git -C "${GIT_TEST_REPO}" init -q
    git -C "${GIT_TEST_REPO}" config user.email "test@example.com"
    git -C "${GIT_TEST_REPO}" config user.name "Test User"
}

# git_test_repo_commit: Create a tracked change and commit in GIT_TEST_REPO
#
# Arguments:
#   $1 - Commit subject
#
function git_test_repo_commit {
    local message="$1"
    echo "change-${RANDOM}" >> "${GIT_TEST_REPO}/file.txt"
    git -C "${GIT_TEST_REPO}" add -A
    git -C "${GIT_TEST_REPO}" commit -q -m "${message}"
}

# git_test_repo_run: Run a command with cwd set to GIT_TEST_REPO via bats run
#
# Arguments:
#   $@ - Shell command string passed to bash -c
#
function git_test_repo_run {
    run bash -c "cd '${GIT_TEST_REPO}' && $*"
}

# bats_resolve_since_ref: Pick a relative git ref with enough workspace history
#
# Arguments:
#   $1 - Repository path
#
# Returns:
#   Prints HEAD~N on stdout; exit 1 when no suitable ref exists
#
function bats_resolve_since_ref {
    local workspace="$1"
    local depth

    for depth in 5 3 1; do
        if git -C "${workspace}" rev-parse --verify "HEAD~${depth}" > /dev/null 2>&1; then
            printf 'HEAD~%s' "${depth}"
            return 0
        fi
    done

    return 1
}

# assert_detect_changelog_ok_json: Validate detect_changelog_commits.sh success JSON
function assert_detect_changelog_ok_json {
    local json="$1"
    local expected_scope="${2:-range}"
    local expected_since="${3:-}"

    jq -e --arg expected_scope "${expected_scope}" --arg expected_since "${expected_since}" '
        def commit_object:
            type == "object"
            and (keys | sort) == ["breaking", "scope", "sha", "subject", "type"]
            and (.sha | type == "string" and length > 0)
            and (.type | type == "string" and length > 0)
            and (.scope | type == "string")
            and (.breaking | type == "boolean")
            and (.subject | type == "string" and length > 0);
        type == "object"
        and (keys | sort) == ["changelog_exists", "changelog_file", "commit_range", "commits", "compare_url", "repository", "repository_url", "scope", "since", "skip", "status"]
        and .status == "ok"
        and .scope == $expected_scope
        and (.since | type == "string")
        and ($expected_since == "" or .since == $expected_since)
        and (.changelog_file | type == "string" and length > 0)
        and (.changelog_exists | type == "boolean")
        and (.commit_range | type == "string" and length > 0)
        and (.repository | type == "string")
        and (.repository_url | type == "string")
        and (.compare_url | type == "string")
        and (.skip | type == "boolean")
        and (.commits | type == "array")
        and (.commits | all(commit_object))
        and (if .skip then (.commits | length) == 0 else (.commits | length) > 0 end)
    ' <<< "${json}"
}

# assert_detect_changelog_error_json: Validate detect_changelog_commits.sh error JSON
function assert_detect_changelog_error_json {
    local json="$1"
    local expected_message="${2:-}"

    jq -e --arg expected_message "${expected_message}" '
        type == "object"
        and (keys | sort) == ["changelog_exists", "changelog_file", "commit_range", "commits", "compare_url", "message", "repository", "repository_url", "scope", "since", "skip", "status"]
        and .status == "error"
        and (.scope | type == "string")
        and (.since | type == "string")
        and (.changelog_file | type == "string" and length > 0)
        and (.changelog_exists | type == "boolean")
        and (.commit_range | type == "string")
        and (.repository | type == "string")
        and (.repository_url | type == "string")
        and (.compare_url | type == "string")
        and .skip == true
        and (.commits | type == "array" and length == 0)
        and (.message | type == "string" and length > 0)
        and ($expected_message == "" or (.message | contains($expected_message)))
    ' <<< "${json}"
}

# assert_detect_changes_ok_json: Validate detect_changes.sh success JSON
function assert_detect_changes_ok_json {
    local json="$1"
    local expected_scope="${2:-range}"
    local expected_since="${3:-}"

    jq -e --arg expected_scope "${expected_scope}" --arg expected_since "${expected_since}" '
        def string_array:
            type == "array" and all(type == "string");
        type == "object"
        and (keys | sort) == ["affected_docs", "changed_files", "commit_range", "deleted_files", "renamed_files", "scope", "since", "skip", "status"]
        and .status == "ok"
        and .scope == $expected_scope
        and (.since | type == "string")
        and ($expected_since == "" or .since == $expected_since)
        and (.commit_range | type == "string" and length > 0)
        and (.skip | type == "boolean")
        and (.changed_files | string_array)
        and (.deleted_files | string_array)
        and (.renamed_files | string_array)
        and (.affected_docs | string_array)
        and (if .skip then (.affected_docs | length) == 0 else (.affected_docs | length) > 0 end)
    ' <<< "${json}"
}

# assert_detect_changes_error_json: Validate detect_changes.sh error JSON
function assert_detect_changes_error_json {
    local json="$1"
    local expected_message="${2:-}"

    jq -e --arg expected_message "${expected_message}" '
        type == "object"
        and (keys | sort) == ["message", "status"]
        and .status == "error"
        and (.message | type == "string" and length > 0)
        and ($expected_message == "" or (.message | contains($expected_message)))
    ' <<< "${json}"
}

# assert_detect_ci_failures_ok_json: Validate detect_ci_failures.sh success JSON
function assert_detect_ci_failures_ok_json {
    local json="$1"
    local expected_scope="${2:-range}"
    local expected_since="${3:-}"

    jq -e --arg expected_scope "${expected_scope}" --arg expected_since "${expected_since}" '
        def failure_object:
            type == "object"
            and (keys | sort) == ["failure_type", "head_branch", "head_sha", "job_name", "log_excerpt", "reason", "run_url", "source_commit", "workflow_name", "workflow_run_id"]
            and (.workflow_name | type == "string" and length > 0)
            and (.workflow_run_id | type == "string" and length > 0)
            and (.head_sha | type == "string")
            and (.head_branch | type == "string")
            and (.job_name | type == "string" and length > 0)
            and (.failure_type | type == "string" and length > 0)
            and (.log_excerpt | type == "string")
            and (.run_url | type == "string")
            and (.source_commit | type == "string")
            and (.reason | type == "string" and length > 0);
        def ignored_object:
            type == "object"
            and (keys | sort) == ["failure_type", "head_branch", "job_name", "reason", "workflow_name", "workflow_run_id"]
            and (.workflow_name | type == "string" and length > 0)
            and (.workflow_run_id | type == "string" and length > 0)
            and (.head_branch | type == "string")
            and (.job_name | type == "string")
            and (.failure_type | type == "string")
            and (.reason | type == "string" and length > 0);
        type == "object"
        and (keys | sort) == ["failures", "ignored", "scope", "since", "skip", "status"]
        and .status == "ok"
        and .scope == $expected_scope
        and (.since | type == "string")
        and ($expected_since == "" or .since == $expected_since)
        and (.skip | type == "boolean")
        and (.failures | type == "array")
        and (.ignored | type == "array")
        and (.failures | all(failure_object))
        and (.ignored | all(ignored_object))
        and (if .skip then (.failures | length) == 0 else (.failures | length) > 0 end)
    ' <<< "${json}"
}

# assert_detect_ci_failures_error_json: Validate detect_ci_failures.sh error JSON
function assert_detect_ci_failures_error_json {
    local json="$1"
    local expected_message="${2:-}"

    jq -e --arg expected_message "${expected_message}" '
        type == "object"
        and (keys | sort) == ["failures", "ignored", "message", "scope", "since", "skip", "status"]
        and .status == "error"
        and (.scope | type == "string")
        and (.since | type == "string")
        and .skip == true
        and (.failures | type == "array" and length == 0)
        and (.ignored | type == "array" and length == 0)
        and (.message | type == "string" and length > 0)
        and ($expected_message == "" or (.message | contains($expected_message)))
    ' <<< "${json}"
}

# assert_loop_run_log_entry_json: Validate loop_run_log_build_entry JSON
function assert_loop_run_log_entry_json {
    local json="$1"

    jq -e '
        type == "object"
        and (.run_id | type == "string" and length > 0)
        and (.pattern | type == "string" and length > 0)
        and (.duration_s | type == "number")
        and (.outcome | type == "string" and length > 0)
        and (.skip_reason | type == "string")
        and (.tokens_estimate | type == "number")
        and (.workflow_run | type == "string" and length > 0)
        and (if has("attempts") then .attempts | type == "number" else true end)
        and (if has("has_changes") then .has_changes | type == "boolean" else true end)
        and (if has("verdict") then .verdict | type == "string" else true end)
        and (if has("usage") then .usage | type == "object" else true end)
    ' <<< "${json}"
}

export -f bats_workspace_root bats_support_dir bats_source_rel apm_skill_script_path
export -f bats_source_apm_skill git_test_repo_setup git_test_repo_commit git_test_repo_run
export -f bats_resolve_since_ref
export -f assert_detect_changelog_ok_json assert_detect_changelog_error_json
export -f assert_detect_changes_ok_json assert_detect_changes_error_json
export -f assert_detect_ci_failures_ok_json assert_detect_ci_failures_error_json
export -f assert_loop_run_log_entry_json
