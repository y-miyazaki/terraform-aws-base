#!/usr/bin/env bats

# Tests for .github/actions/loop-execute/lib/push.sh

setup() {
    # shellcheck disable=SC1091
    source ".github/actions/loop-execute/lib/push.sh"
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
