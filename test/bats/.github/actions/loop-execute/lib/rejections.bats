#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .github/actions/loop-execute/lib/rejections.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

setup() {
    bats_source_rel ".github/actions/loop-execute/lib/rejections.sh"
    OPEN_REJECTIONS_JSON='[]'
    REJECT_FEEDBACK=""
}

@test "append_open_rejection adds structured entry" {
    append_open_rejection 1 "docs/a.md" "wrong scope" "fix heading"
    length=$(jq 'length' <<< "${OPEN_REJECTIONS_JSON}")
    [ "${length}" -eq 1 ]
    issue=$(jq -r '.[0].issue' <<< "${OPEN_REJECTIONS_JSON}")
    [ "${issue}" = "wrong scope" ]
    files=$(jq -r '.[0].files | join(",")' <<< "${OPEN_REJECTIONS_JSON}")
    [ "${files}" = "docs/a.md" ]
}

@test "format_open_rejections_for_prompt renders markdown" {
    OPEN_REJECTIONS_JSON='[{"attempt":2,"files":["docs/a.md"],"issue":"typo","fix":"correct title"}]'
    output=$(format_open_rejections_for_prompt)
    [[ ${output} == *"### Attempt 2"* ]]
    [[ ${output} == *"docs/a.md"* ]]
    [[ ${output} == *"typo"* ]]
}

@test "record_structured_reject writes attempt artifacts" {
    attempt_dir=$(mktemp -d)
    record_structured_reject "${attempt_dir}" 3 "docs/a.md" "issue text" "fix text" "summary line"
    [ "$(cat "${attempt_dir}/verdict")" = "REJECT" ]
    [ "$(cat "${attempt_dir}/reason")" = "summary line" ]
    [ "$(cat "${attempt_dir}/reject-issue")" = "issue text" ]
    [[ ${REJECT_FEEDBACK} == *"issue text"* ]]
    rm -rf "${attempt_dir}"
}
