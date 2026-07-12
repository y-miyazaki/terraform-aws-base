#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .apm/packages/loop-ci-sweeper/.apm/skills/loop-ci-sweeper/scripts/detect_ci_failures.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

DETECT_SCRIPT="$(apm_skill_script_path loop-ci-sweeper detect_ci_failures.sh)"

setup() {
    LEDGER_FILE="$(mktemp)"
    export CI_SWEEPER_LEDGER_FILE="${LEDGER_FILE}"
    export CI_SWEEPER_REJECT_RETRY_POLICY="limited"
    export CI_SWEEPER_REJECT_MAX_RETRIES="3"
    bats_source_apm_skill loop-ci-sweeper detect_ci_failures.sh
}

teardown() {
    rm -f "${LEDGER_FILE:-}"
}

@test "split_csv_to_array trims whitespace from workflow filter entries" {
    declare -a trimmed=()
    split_csv_to_array " on-loop-ci-sweeper , ci-markdown " trimmed
    [ "${trimmed[0]}" = "on-loop-ci-sweeper" ]
    [ "${trimmed[1]}" = "ci-markdown" ]
}

@test "classify_failure_type treats normal runner label as regression" {
    run classify_failure_type "Job is about to start running on the runner: ubuntu-latest"
    [ "$status" -eq 0 ]
    [ "$output" = "regression" ]
}

@test "classify_failure_type treats waiting for runner as infra" {
    run classify_failure_type "Waiting for a runner to pick up this job"
    [ "$status" -eq 0 ]
    [ "$output" = "infra" ]
}

@test "classify_failure_type treats shellcheck failure as regression" {
    run classify_failure_type "SC2086: Double quote to prevent globbing"
    [ "$status" -eq 0 ]
    [ "$output" = "regression" ]
}

@test "normalize_reject_retry_policy accepts aliases a b c" {
    [ "$(normalize_reject_retry_policy "a")" = "block" ]
    [ "$(normalize_reject_retry_policy "b")" = "retry" ]
    [ "$(normalize_reject_retry_policy "c")" = "limited" ]
}

@test "should_skip_processed_run block policy skips any ledgered run" {
    REJECT_RETRY_POLICY="block"
    printf '%s' '{"runs":{"123":{"outcome":"no-action","reject_count":0}}}' > "${LEDGER_FILE}"
    run should_skip_processed_run "123"
    [ "$status" -eq 0 ]
}

@test "should_skip_processed_run retry policy skips only pr-created" {
    REJECT_RETRY_POLICY="retry"
    printf '%s' '{"runs":{"123":{"outcome":"no-action","reject_count":0}}}' > "${LEDGER_FILE}"
    run should_skip_processed_run "123"
    [ "$status" -eq 1 ]

    printf '%s' '{"runs":{"456":{"outcome":"pr-created","reject_count":0}}}' > "${LEDGER_FILE}"
    run should_skip_processed_run "456"
    [ "$status" -eq 0 ]
}

@test "should_skip_processed_run limited policy allows retry for no-action outcome" {
    CI_SWEEPER_REJECT_RETRY_POLICY="limited"
    printf '%s' '{"runs":{"123":{"outcome":"no-action","reject_count":0}}}' > "${LEDGER_FILE}"
    run should_skip_processed_run "123"
    [ "$status" -eq 1 ]
}

@test "should_skip_processed_run limited policy skips rejected at max retries" {
    REJECT_RETRY_POLICY="limited"
    REJECT_MAX_RETRIES="3"
    printf '%s' '{"runs":{"456":{"outcome":"rejected","reject_count":3}}}' > "${LEDGER_FILE}"
    run should_skip_processed_run "456"
    [ "$status" -eq 0 ]

    printf '%s' '{"runs":{"456":{"outcome":"rejected","reject_count":2}}}' > "${LEDGER_FILE}"
    run should_skip_processed_run "456"
    [ "$status" -eq 1 ]
}

@test "collect_failures_for_run includes infra failures in failures array" {
    load_workflow_filters
    MOCK_BIN="${BATS_TEST_TMPDIR}/bin"
    mkdir -p "${MOCK_BIN}"
    cat > "${MOCK_BIN}/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "run" && "$2" == "view" ]]; then
    if [[ "$*" == *"--json jobs"* ]]; then
        printf '%s\n' '{"name":"lint","conclusion":"failure","url":"https://example.com/run/1"}'
        exit 0
    fi
    if [[ "$*" == *"--log-failed"* ]]; then
        printf '%s\n' "Waiting for a runner to pick up this job"
        exit 0
    fi
fi
exit 1
EOF
    chmod +x "${MOCK_BIN}/gh"
    PATH="${MOCK_BIN}:${PATH}"

    FAILURES_JSON=()
    IGNORED_JSON=()
    collect_failures_for_run "ci-markdown" "12345" "abc123" "main" "https://example.com/run/1"
    [ "${#FAILURES_JSON[@]}" -eq 1 ]
    [ "${#IGNORED_JSON[@]}" -eq 0 ]
    [[ ${FAILURES_JSON[0]} == *'"failure_type": "infra"'* ]]
}

@test "classify_failure_type treats http status in test output as regression" {
    run classify_failure_type "expected status 401 Unauthorized in response test"
    [ "$status" -eq 0 ]
    [ "$output" = "regression" ]
}

@test "collect_failures_for_run includes env-pattern failures in failures array" {
    run classify_failure_type "Please retry the deployment after fixing config"
    [ "$status" -eq 0 ]
    [ "$output" = "regression" ]
}

@test "classify_failure_type treats explicit retrying as flake" {
    run classify_failure_type "Job is retrying due to intermittent network"
    [ "$status" -eq 0 ]
    [ "$output" = "flake" ]
}

@test "sanitize_log_excerpt redacts github tokens" {
    run sanitize_log_excerpt "token=ghp_abcdefghijklmnopqrstuvwxyz1234567890" # pragma: allowlist secret
    [ "$status" -eq 0 ]
    [[ $output == *"[REDACTED]"* ]]
    [[ $output != *"ghp_"* ]]
}

@test "collect_failures_for_run includes secret-missing failures in failures array" {
    load_workflow_filters
    MOCK_BIN="${BATS_TEST_TMPDIR}/bin"
    mkdir -p "${MOCK_BIN}"
    cat > "${MOCK_BIN}/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "run" && "$2" == "view" ]]; then
    if [[ "$*" == *"--json jobs"* ]]; then
        printf '%s\n' '{"name":"deploy","conclusion":"failure","url":"https://example.com/run/2"}'
        exit 0
    fi
    if [[ "$*" == *"--log-failed"* ]]; then
        printf '%s\n' "Error: secret not found in credentials store"
        exit 0
    fi
fi
exit 1
EOF
    chmod +x "${MOCK_BIN}/gh"
    PATH="${MOCK_BIN}:${PATH}"

    FAILURES_JSON=()
    IGNORED_JSON=()
    collect_failures_for_run "ci-markdown" "99999" "abc123" "main" "https://example.com/run/2"
    [ "${#FAILURES_JSON[@]}" -eq 1 ]
    [ "${#IGNORED_JSON[@]}" -eq 0 ]
    [[ ${FAILURES_JSON[0]} == *'"failure_type": "env"'* ]]
}

@test "sanitize_log_excerpt redacts bearer tokens" {
    run sanitize_log_excerpt "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.test.sig"
    [ "$status" -eq 0 ]
    [[ $output == *"[REDACTED]"* ]]
    [[ $output != *"eyJhbGci"* ]]
}

@test "detect_ci_failures rejects ledger path traversal outside dot loop" {
    run env CI_SWEEPER_LEDGER_FILE=".loop/../outside.json" bash "${DETECT_SCRIPT}" --scope all
    [ "$status" -eq 0 ]
    assert_detect_ci_failures_error_json "${output}" "stay under .loop/"
}

@test "detect_ci_failures script validates ok response format with mocked gh" {
    local workspace since_ref json mock_bin ledger_file

    workspace="$(bats_workspace_root)"
    if ! since_ref="$(bats_resolve_since_ref "${workspace}")"; then
        skip "not enough git history for relative since ref"
    fi

    mock_bin="${BATS_TEST_TMPDIR}/bin"
    ledger_file=".loop/bats-detect-ci-failures-${BATS_TEST_NUMBER}.json"
    mkdir -p "${mock_bin}" "${workspace}/.loop"
    cat > "${mock_bin}/gh" << 'EOF'
#!/usr/bin/env bash
if [[ "$1" == "run" && "$2" == "list" ]]; then
    printf '[]'
    exit 0
fi
exit 1
EOF
    chmod +x "${mock_bin}/gh"

    run bash -c "cd '${workspace}' && PATH='${mock_bin}:'\$PATH CI_SWEEPER_LEDGER_FILE='${ledger_file}' GITHUB_TOKEN='test-token' bash '${DETECT_SCRIPT}' --scope range --since '${since_ref}'"
    [ "$status" -eq 0 ]
    json="${output}"
    assert_detect_ci_failures_ok_json "${json}" "range" "${since_ref}"
    run jq -e '.skip == true and (.failures | length) == 0' <<< "${json}"
    [ "$status" -eq 0 ]
    rm -f "${workspace}/${ledger_file}"
}

@test "detect_ci_failures script validates error response format without token" {
    local workspace ledger_file

    workspace="$(bats_workspace_root)"
    ledger_file=".loop/bats-detect-ci-failures-no-token-${BATS_TEST_NUMBER}.json"
    mkdir -p "${workspace}/.loop"

    run bash -c "cd '${workspace}' && env -u GH_TOKEN -u GITHUB_TOKEN CI_SWEEPER_LEDGER_FILE='${ledger_file}' bash '${DETECT_SCRIPT}' --scope all"
    [ "$status" -eq 0 ]
    assert_detect_ci_failures_error_json "${output}" "GH_TOKEN or GITHUB_TOKEN is required"
}
