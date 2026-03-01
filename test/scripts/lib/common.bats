#!/usr/bin/env bats

# Tests for scripts/lib/common.sh

setup() {
    # Source library (tests run from repo root)
    source "scripts/lib/common.sh"
}

@test "execute_command executes the command and logs when VERBOSE=true" {
    DRY_RUN=false
    VERBOSE=true
    run execute_command echo hi_there
    [ "$status" -eq 0 ]
    # Should include the debug log line about Executing and the command output
    [[ "$output" == *"Executing: echo hi_there"* ]]
    [[ "$output" == *"hi_there"* ]]
}

@test "execute_command in dry-run mode only logs planned command" {
    DRY_RUN=true
    run execute_command echo hello world
    [ "$status" -eq 0 ]
    # Use substring match to avoid regex quoting issues
    [[ "$output" == *"DRY-RUN: Would execute: echo hello world"* ]]
}

@test "is_dry_run returns non-zero when DRY_RUN is false/unset" {
    unset DRY_RUN
    run is_dry_run
    [ "$status" -ne 0 ]
}

@test "is_dry_run returns success when DRY_RUN=true" {
    DRY_RUN=true
    run is_dry_run
    [ "$status" -eq 0 ]
}

@test "log prints ERROR messages regardless of VERBOSE" {
    unset VERBOSE
    run log ERROR "fatal"
    [ "$status" -eq 0 ]
    [[ "$output" == *"[ERROR] fatal"* ]]
}
