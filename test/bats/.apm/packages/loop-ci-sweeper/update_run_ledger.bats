#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .apm/packages/loop-ci-sweeper/.apm/skills/loop-ci-sweeper/scripts/update_run_ledger.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

LEDGER_SCRIPT="$(apm_skill_script_path loop-ci-sweeper update_run_ledger.sh)"

setup() {
    mkdir -p .loop
    LEDGER_FILE=".loop/test-ledger-${BATS_TEST_NUMBER}-$$.json"
    printf '%s' '{"runs":{}}' > "${LEDGER_FILE}"
    export CI_SWEEPER_LEDGER_FILE="${LEDGER_FILE}"
}

teardown() {
    rm -f "${LEDGER_FILE:-}"
}

@test "update_run_ledger resolves head_sha from TARGET_JSON head_sha field" {
    export TARGET_JSON='{"workflow_run_id":"789","workflow_name":"ci-markdown","head_sha":"cafebabe","from":{"ref":"deadbeef"}}'
    export OUTCOME="watch"
    run bash "${LEDGER_SCRIPT}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["789"].head_sha == "cafebabe"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["789"].outcome == "watch"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    unset TARGET_JSON OUTCOME
}

@test "update_run_ledger resolves fields from TARGET_JSON env" {
    export TARGET_JSON='{"workflow_run_id":"789","workflow_name":"ci-markdown","from":{"ref":"deadbeef"}}'
    export OUTCOME="pr-created"
    run bash "${LEDGER_SCRIPT}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["789"].outcome == "pr-created"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["789"].head_sha == "deadbeef"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    unset TARGET_JSON OUTCOME
}

@test "update_run_ledger writes a new ledger entry" {
    run bash "${LEDGER_SCRIPT}" \
        --run-id 123 \
        --workflow ci-markdown \
        --head-sha abc1234 \
        --outcome pr-created \
        --loop-run-id 999
    [ "$status" -eq 0 ]
    run jq -e '.runs["123"].outcome == "pr-created"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["123"].workflow_name == "ci-markdown"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["123"].loop_run_id == "999"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
}

@test "update_run_ledger increments reject_count on rejected outcome" {
    printf '%s' '{"runs":{"456":{"outcome":"rejected","reject_count":1,"updated_at":"2026-07-10T00:00:00Z"}}}' > "${LEDGER_FILE}"
    run bash "${LEDGER_SCRIPT}" \
        --run-id 456 \
        --workflow ci-go \
        --head-sha def5678 \
        --outcome rejected
    [ "$status" -eq 0 ]
    run jq -e '.runs["456"].reject_count == 2' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
}

@test "update_run_ledger exits 0 when run-id is omitted" {
    run bash "${LEDGER_SCRIPT}" \
        --workflow ci-markdown \
        --head-sha abc1234 \
        --outcome no-action
    [ "$status" -eq 0 ]
    [[ $output == *"No workflow run id"* ]]
}

@test "update_run_ledger exits 0 on corrupt ledger file" {
    printf '%s' 'not json' > "${LEDGER_FILE}"
    run bash "${LEDGER_SCRIPT}" \
        --run-id 999 \
        --workflow test \
        --head-sha abc \
        --outcome rejected
    [ "$status" -eq 0 ]
    [[ $output == *"Failed to update ledger"* ]]
}

@test "update_run_ledger preserves unrelated run entries" {
    printf '%s' '{"runs":{"111":{"outcome":"pr-created","reject_count":0,"updated_at":"2026-07-10T00:00:00Z","workflow_name":"ci-shell"}}}' > "${LEDGER_FILE}"
    run bash "${LEDGER_SCRIPT}" \
        --run-id 222 \
        --workflow ci-markdown \
        --head-sha abc1234 \
        --outcome no-action
    [ "$status" -eq 0 ]
    run jq -e '.runs["111"].workflow_name == "ci-shell"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
    run jq -e '.runs["222"].outcome == "no-action"' "${LEDGER_FILE}"
    [ "$status" -eq 0 ]
}
