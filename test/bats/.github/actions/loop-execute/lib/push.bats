#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .github/actions/loop-execute/lib/push.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

setup() {
    bats_source_rel ".github/actions/loop-execute/lib/push.sh"
    GITHUB_OUTPUT=$(mktemp)
}

teardown() {
    rm -f "${GITHUB_OUTPUT:-}"
}

@test "main rejects invalid branch names" {
    BRANCH='loop/bad branch'
    GH_TOKEN='test-token'
    LOOP_HAS_CHANGES='true'
    WORKTREE_PATH='/tmp/worktree'
    run main
    [ "$status" -eq 1 ]
    [[ $output == *"Invalid branch name"* ]]
}

@test "main writes has_changes=false when loop produced no commits" {
    BRANCH='loop/docs-triage-abc'
    GH_TOKEN='test-token'
    LOOP_HAS_CHANGES='false'
    WORKTREE_PATH='/tmp/worktree'
    run main
    [ "$status" -eq 0 ]
    grep -q '^has_changes=false$' "${GITHUB_OUTPUT}"
}

@test "main accepts valid branch name characters" {
    BRANCH='loop/docs-triage_1.2'
    GH_TOKEN='test-token'
    LOOP_HAS_CHANGES='false'
    WORKTREE_PATH='/tmp/worktree'
    run main
    [ "$status" -eq 0 ]
}
