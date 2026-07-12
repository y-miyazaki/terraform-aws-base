#!/usr/bin/env bats

# Tests for .github/actions/loop-run-log/lib/append.sh

setup() {
    # shellcheck disable=SC1091
    source ".github/actions/loop-run-log/lib/append.sh"
    TEST_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "${TEST_DIR}"
}

@test "loop_run_log_build_entry includes tokens_estimate by default" {
    result="$(loop_run_log_build_entry "" 12 "" "docs-triage" "skipped" "budget" 52000 "" "12345" "")"
    [ "$(jq -r '.pattern' <<< "${result}")" = "docs-triage" ]
    [ "$(jq -r '.tokens_estimate' <<< "${result}")" = "52000" ]
    [ "$(jq -r '.usage // empty' <<< "${result}")" = "" ]
}

@test "loop_run_log_build_entry merges measured usage_json" {
    local usage='{"total_input_tokens":1842,"total_output_tokens":17,"model":"composer-2.5"}'
    result="$(loop_run_log_build_entry "2" 45 "true" "docs-triage" "pr-created" "none" 52000 "APPROVE" "999" "${usage}")"
    [ "$(jq -r '.tokens_estimate' <<< "${result}")" = "52000" ]
    [ "$(jq -r '.usage.total_input_tokens' <<< "${result}")" = "1842" ]
    [ "$(jq -r '.usage.total_output_tokens' <<< "${result}")" = "17" ]
    [ "$(jq -r '.usage.model' <<< "${result}")" = "composer-2.5" ]
    [ "$(jq -r '.attempts' <<< "${result}")" = "2" ]
    [ "$(jq -r '.has_changes' <<< "${result}")" = "true" ]
    [ "$(jq -r '.verdict' <<< "${result}")" = "APPROVE" ]
}

@test "loop_run_log_compute_duration returns zero for empty start" {
    result="$(loop_run_log_compute_duration "")"
    [ "${result}" = "0" ]
}

@test "loop_run_log_compute_duration returns elapsed seconds" {
    local started
    started="$(date -u -d '10 seconds ago' +%Y-%m-%dT%H:%M:%SZ)"
    result="$(loop_run_log_compute_duration "${started}")"
    [ "${result}" -ge 8 ]
    [ "${result}" -le 15 ]
}

@test "loop_run_log_prune_cutoff_date returns YYYY-MM-DD" {
    result="$(loop_run_log_prune_cutoff_date)"
    [[ ${result} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

@test "loop_run_log_append_entry prunes entries older than 30 days" {
    local log_file="${TEST_DIR}/loop-run-log.md"
    local cutoff old_date recent_date new_entry

    cutoff="$(loop_run_log_prune_cutoff_date)"
    old_date="$(date -u -d "${cutoff} - 1 day" +%Y-%m-%dT%H:%M:%SZ)"
    recent_date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    new_entry='{"run_id":"'"${recent_date}"'","pattern":"docs-triage","duration_s":1,"outcome":"skipped","skip_reason":"budget","tokens_estimate":52000,"workflow_run":"1"}'

    mkdir -p "$(dirname "${log_file}")"
    {
        printf '%s' "${RUN_LOG_HEADER}"
        printf '{"run_id":"%s","pattern":"docs-triage","duration_s":1,"outcome":"skipped","skip_reason":"budget","tokens_estimate":52000,"workflow_run":"0"}\n' "${old_date}"
        printf '{"run_id":"%s","pattern":"docs-triage","duration_s":1,"outcome":"skipped","skip_reason":"none","tokens_estimate":52000,"workflow_run":"2"}\n' "${recent_date}"
    } > "${log_file}"

    loop_run_log_append_entry "${log_file}" "${new_entry}"

    run grep -F "${old_date}" "${log_file}"
    [ "$status" -eq 1 ]
    run grep -F "${recent_date}" "${log_file}"
    [ "$status" -eq 0 ]
    run grep -F "${RUN_LOG_HEADER%%$'\n'*}" "${log_file}"
    [ "$status" -eq 0 ]
}

@test "budget token selection prefers measured usage over tokens_estimate" {
    local line measured_only estimate_only
    line='{"tokens_estimate":52000,"usage":{"total_input_tokens":100,"total_output_tokens":50}}'
    measured_only="$(jq -r '
      if .usage then
        ((.usage.total_input_tokens // .usage.input_tokens // .usage.inputTokens // 0)
         + (.usage.total_output_tokens // .usage.output_tokens // .usage.outputTokens // 0))
      elif .tokens_estimate then
        .tokens_estimate
      else
        0
      end
    ' <<< "${line}")"
    [ "${measured_only}" = "150" ]

    line='{"tokens_estimate":52000}'
    estimate_only="$(jq -r '
      if .usage then
        ((.usage.total_input_tokens // .usage.input_tokens // .usage.inputTokens // 0)
         + (.usage.total_output_tokens // .usage.output_tokens // .usage.outputTokens // 0))
      elif .tokens_estimate then
        .tokens_estimate
      else
        0
      end
    ' <<< "${line}")"
    [ "${estimate_only}" = "52000" ]
}
