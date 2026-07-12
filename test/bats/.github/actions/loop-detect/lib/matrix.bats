#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .github/actions/loop-detect/lib/matrix.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

setup() {
    bats_source_rel ".github/actions/loop-detect/lib/matrix.sh"
}

@test "build_verifier_context_from_result formats changelog commits" {
    local detect_result
    detect_result='{
      "changelog_file": "CHANGELOG.md",
      "commits": [
        {
          "sha": "123456789012",
          "type": "feat",
          "scope": "api",
          "breaking": false,
          "subject": "add endpoint"
        },
        {
          "sha": "123456789012",
          "type": "renovate",
          "scope": "mise",
          "breaking": false,
          "subject": "update pnpm"
        }
      ]
    }'
    run build_verifier_context_from_result "${detect_result}"
    [ "$status" -eq 0 ]
    [[ $output == *"## Changelog Commits"* ]]
    [[ $output == *"file: CHANGELOG.md"* ]]
    [[ $output == *"count: 2"* ]]
    [[ $output == *"**feat(api)**: add endpoint"* ]]
    [[ $output == *"**renovate(mise)**: update pnpm"* ]]
}

@test "build_verifier_context_from_result returns empty for empty commits array" {
    local detect_result='{"commits": []}'
    run build_verifier_context_from_result "${detect_result}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "build_verifier_context_from_result prefers explicit verifier_context" {
    local detect_result='{
      "verifier_context": "custom context",
      "commits": [{"sha": "abc", "type": "feat", "scope": "", "breaking": false, "subject": "x"}]
    }'
    run build_verifier_context_from_result "${detect_result}"
    [ "$status" -eq 0 ]
    [ "$output" = "custom context" ]
}

@test "build_verifier_context_from_result still formats affected_docs" {
    local detect_result='{
      "changed_files": ["src/a.go"],
      "deleted_files": [],
      "renamed_files": [],
      "affected_docs": ["docs/a.md"]
    }'
    run build_verifier_context_from_result "${detect_result}"
    [ "$status" -eq 0 ]
    [[ $output == *"## Change Detection"* ]]
    [[ $output == *"affected_docs: docs/a.md"* ]]
}
