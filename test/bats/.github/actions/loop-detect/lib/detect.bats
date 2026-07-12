#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .github/actions/loop-detect/lib/detect.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

CHANGELOG_DETECT_SCRIPT="$(apm_skill_script_path loop-changelog detect_changelog_commits.sh)"
DOCS_DETECT_SCRIPT="$(apm_skill_script_path loop-docs-triage detect_changes.sh)"

setup() {
    bats_source_rel ".github/actions/loop-detect/lib/detect.sh"
}

@test "detect_result_skip matches live changelog detect script output" {
    local workspace since_ref json

    workspace="$(bats_workspace_root)"
    if ! since_ref="$(bats_resolve_since_ref "${workspace}")"; then
        skip "not enough git history for relative since ref"
    fi

    run bash -c "cd '${workspace}' && bash '${CHANGELOG_DETECT_SCRIPT}' --scope range --since '${since_ref}'"
    [ "$status" -eq 0 ]
    json="${output}"
    assert_detect_changelog_ok_json "${json}" "range" "${since_ref}"

    if jq -e '.skip == true' <<< "${json}" > /dev/null; then
        run detect_result_skip "${json}"
        [ "$status" -eq 0 ]
    else
        run detect_result_skip "${json}"
        [ "$status" -eq 1 ]
    fi
}

@test "build_verifier_context_from_result formats live docs detect script output" {
    local workspace since_ref json

    workspace="$(bats_workspace_root)"
    if ! since_ref="$(bats_resolve_since_ref "${workspace}")"; then
        skip "not enough git history for relative since ref"
    fi

    run bash -c "cd '${workspace}' && env DOCS_TRIAGE_DOC_GLOBS='docs/**/*.md,README.md' bash '${DOCS_DETECT_SCRIPT}' --scope range --since '${since_ref}'"
    [ "$status" -eq 0 ]
    json="${output}"
    assert_detect_changes_ok_json "${json}" "range" "${since_ref}"

    if jq -e '.skip == false' <<< "${json}" > /dev/null; then
        run build_verifier_context_from_result "${json}"
        [ "$status" -eq 0 ]
        [[ $output == *"## Change Detection"* ]]
        [[ $output == *"affected_docs:"* ]]
    fi
}

@test "write_detect_outputs writes expected action output format" {
    local github_output

    github_output="$(mktemp)"
    GITHUB_OUTPUT="${github_output}"
    write_detect_outputs "false" "no_changes" "[]"

    run grep -Fx 'should_run=false' "${github_output}"
    [ "$status" -eq 0 ]
    run grep -Fx 'skip_reason=no_changes' "${github_output}"
    [ "$status" -eq 0 ]
    run grep -E '^target_matrix<<' "${github_output}"
    [ "$status" -eq 0 ]
    run awk '/^target_matrix<</{found=1;next} found{print; if ($0=="[]") exit}' "${github_output}"
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
}
