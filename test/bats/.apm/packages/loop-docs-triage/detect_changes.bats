#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .apm/packages/loop-docs-triage/.apm/skills/loop-docs-triage/scripts/detect_changes.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

DETECT_SCRIPT="$(apm_skill_script_path loop-docs-triage detect_changes.sh)"

setup() {
    bats_source_apm_skill loop-docs-triage detect_changes.sh
}

@test "trim_whitespace removes leading and trailing spaces" {
    result="$(trim_whitespace '  hello world  ')"
    [ "${result}" = "hello world" ]
}

@test "append_unique_doc adds existing paths once" {
    git_test_repo_setup
    mkdir -p "${GIT_TEST_REPO}/docs"
    printf '# Doc\n' > "${GIT_TEST_REPO}/docs/index.md"
    (
        cd "${GIT_TEST_REPO}" || exit 1
        AFFECTED_DOCS=()
        append_unique_doc "docs/index.md"
        append_unique_doc "docs/index.md"
        [ "${#AFFECTED_DOCS[@]}" -eq 1 ]
        [ "${AFFECTED_DOCS[0]}" = "docs/index.md" ]
    )
}

@test "detect_changes range scope lists affected docs for non-markdown changes" {
    git_test_repo_setup
    mkdir -p "${GIT_TEST_REPO}/docs" "${GIT_TEST_REPO}/src"
    printf '# Docs\n' > "${GIT_TEST_REPO}/docs/index.md"
    printf 'package main\n' > "${GIT_TEST_REPO}/src/app.go"
    touch "${GIT_TEST_REPO}/file.txt"
    git -C "${GIT_TEST_REPO}" add .
    git -C "${GIT_TEST_REPO}" commit -q -m "chore: init"
    local base
    base="$(git -C "${GIT_TEST_REPO}" rev-parse HEAD)"
    printf '\n' >> "${GIT_TEST_REPO}/src/app.go"
    git -C "${GIT_TEST_REPO}" add src/app.go
    git -C "${GIT_TEST_REPO}" commit -q -m "feat: update app"
    git_test_repo_run "env DOCS_TRIAGE_DOC_GLOBS='docs/**/*.md' bash '${DETECT_SCRIPT}' --scope range --since '${base}'"
    [ "$status" -eq 0 ]
    [[ $output == *'"status": "ok"'* ]]
    [[ $output == *'"skip": false'* ]]
    [[ $output == *'"affected_docs":'* ]]
    [[ $output == *"docs/index.md"* ]]
    [[ $output == *"src/app.go"* ]]
}

@test "detect_changes range scope skips when only markdown files change" {
    git_test_repo_setup
    mkdir -p "${GIT_TEST_REPO}/docs"
    printf '# Docs\n' > "${GIT_TEST_REPO}/docs/index.md"
    touch "${GIT_TEST_REPO}/file.txt"
    git -C "${GIT_TEST_REPO}" add .
    git -C "${GIT_TEST_REPO}" commit -q -m "chore: init"
    local base
    base="$(git -C "${GIT_TEST_REPO}" rev-parse HEAD)"
    printf '\nMore docs\n' >> "${GIT_TEST_REPO}/docs/index.md"
    git -C "${GIT_TEST_REPO}" add docs/index.md
    git -C "${GIT_TEST_REPO}" commit -q -m "docs: expand index"
    git_test_repo_run "env DOCS_TRIAGE_DOC_GLOBS='docs/**/*.md' bash '${DETECT_SCRIPT}' --scope range --since '${base}'"
    [ "$status" -eq 0 ]
    assert_detect_changes_ok_json "${output}" "range" "${base}"
    [[ $output == *'"skip": true'* ]]
    [[ $output == *'"affected_docs": []'* ]]
}

@test "detect_changes range scope includes affected docs when markdown is deleted" {
    git_test_repo_setup
    mkdir -p "${GIT_TEST_REPO}/docs"
    printf '# Old\n' > "${GIT_TEST_REPO}/docs/legacy.md"
    printf '# Keep\n' > "${GIT_TEST_REPO}/docs/index.md"
    touch "${GIT_TEST_REPO}/file.txt"
    git -C "${GIT_TEST_REPO}" add .
    git -C "${GIT_TEST_REPO}" commit -q -m "chore: init"
    local base
    base="$(git -C "${GIT_TEST_REPO}" rev-parse HEAD)"
    git -C "${GIT_TEST_REPO}" rm docs/legacy.md
    git -C "${GIT_TEST_REPO}" commit -q -m "docs: remove legacy page"
    git_test_repo_run "env DOCS_TRIAGE_DOC_GLOBS='docs/**/*.md' bash '${DETECT_SCRIPT}' --scope range --since '${base}'"
    [ "$status" -eq 0 ]
    [[ $output == *'"skip": false'* ]]
    [[ $output == *"docs/index.md"* ]]
    [[ $output == *'"deleted_files":'* ]]
    [[ $output == *"docs/legacy.md"* ]]
}

@test "detect_changes rejects range scope without since ref" {
    git_test_repo_setup
    touch "${GIT_TEST_REPO}/file.txt"
    git -C "${GIT_TEST_REPO}" add file.txt
    git -C "${GIT_TEST_REPO}" commit -q -m "chore: init"
    git_test_repo_run "bash '${DETECT_SCRIPT}' --scope range"
    [ "$status" -eq 0 ]
    assert_detect_changes_error_json "${output}" "requires --since"
}

@test "detect_changes script validates ok response format on workspace repo" {
    local workspace since_ref json

    workspace="$(bats_workspace_root)"
    if ! since_ref="$(bats_resolve_since_ref "${workspace}")"; then
        skip "not enough git history for relative since ref"
    fi

    run bash -c "cd '${workspace}' && env DOCS_TRIAGE_DOC_GLOBS='docs/**/*.md,README.md' bash '${DETECT_SCRIPT}' --scope range --since '${since_ref}'"
    [ "$status" -eq 0 ]
    json="${output}"
    assert_detect_changes_ok_json "${json}" "range" "${since_ref}"
    run jq -e --arg since_ref "${since_ref}" '.commit_range == ($since_ref + "..HEAD")' <<< "${json}"
    [ "$status" -eq 0 ]
}
