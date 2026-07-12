#!/usr/bin/env bats

# Tests for .github/actions/loop-execute/lib/usage.sh

setup() {
    # shellcheck disable=SC1091
    source ".github/actions/loop-execute/lib/usage.sh"
    reset_usage_totals
}

@test "reset_usage_totals clears module globals" {
    USAGE_INPUT_TOTAL=100
    USAGE_OUTPUT_TOTAL=50
    USAGE_MODEL="composer-2.5"
    reset_usage_totals
    [ "${USAGE_INPUT_TOTAL}" -eq 0 ]
    [ "${USAGE_OUTPUT_TOTAL}" -eq 0 ]
    [ "${USAGE_MODEL}" = "" ]
}

@test "accumulate_cursor_usage_from_line sums result usage" {
    local line='{"type":"result","usage":{"inputTokens":1200,"outputTokens":300},"model":"composer-2.5"}'
    accumulate_cursor_usage_from_line "${line}"
    [ "${USAGE_INPUT_TOTAL}" -eq 1200 ]
    [ "${USAGE_OUTPUT_TOTAL}" -eq 300 ]
    [ "${USAGE_MODEL}" = "composer-2.5" ]
}

@test "accumulate_cursor_stream_usage reads model from system init" {
    local tmpf
    tmpf="$(mktemp)"
    printf '%s\n' \
        '{"type":"system","subtype":"init","model":"grok-4.5-medium"}' \
        '{"type":"result","usage":{"total_input_tokens":500,"total_output_tokens":100}}' \
        > "${tmpf}"
    accumulate_cursor_stream_usage "${tmpf}"
    rm -f "${tmpf}"
    [ "${USAGE_INPUT_TOTAL}" -eq 500 ]
    [ "${USAGE_OUTPUT_TOTAL}" -eq 100 ]
    [ "${USAGE_MODEL}" = "grok-4.5-medium" ]
}

@test "build_usage_json returns empty when no usage captured" {
    result="$(build_usage_json)"
    [ -z "${result}" ]
}

@test "build_usage_json serializes measured totals" {
    USAGE_INPUT_TOTAL=1000
    USAGE_OUTPUT_TOTAL=250
    USAGE_MODEL="composer-2.5"
    result="$(build_usage_json)"
    [ "$(jq -r '.total_input_tokens' <<< "${result}")" = "1000" ]
    [ "$(jq -r '.total_output_tokens' <<< "${result}")" = "250" ]
    [ "$(jq -r '.model' <<< "${result}")" = "composer-2.5" ]
}

@test "accumulate_cursor_stream_usage parses fixture stream-json with camelCase usage" {
    local fixture="test/fixtures/loop-execute/cursor-stream-json-usage.ndjson"
    [ -f "${fixture}" ]
    accumulate_cursor_stream_usage "${fixture}"
    [ "${USAGE_INPUT_TOTAL}" -eq 1842 ]
    [ "${USAGE_OUTPUT_TOTAL}" -eq 17 ]
    [ "${USAGE_MODEL}" = "composer-2.5" ]
    result="$(build_usage_json)"
    [ "$(jq -r '.total_input_tokens' <<< "${result}")" = "1842" ]
}

@test "is_cursor_stream_json_file detects stream-json captures" {
    is_cursor_stream_json_file test/fixtures/loop-execute/cursor-stream-json-usage.ndjson
    tmpf="$(mktemp)"
    echo "plain text output" > "${tmpf}"
    ! is_cursor_stream_json_file "${tmpf}"
    rm -f "${tmpf}"
}

@test "extract_cursor_stream_text returns assistant markdown with json fence" {
    local fixture="test/fixtures/loop-execute/cursor-stream-json-verifier.ndjson"
    result="$(extract_cursor_stream_text "${fixture}")"
    [[ ${result} == *'```json'* ]]
    [[ ${result} == *'"verdict": "REJECT"'* ]]
}

@test "render_cursor_stream_log_summary omits raw ndjson and includes tool summary" {
    local fixture="test/fixtures/loop-execute/cursor-stream-json-verifier.ndjson"
    accumulate_cursor_stream_usage "${fixture}"
    result="$(render_cursor_stream_log_summary "${fixture}")"
    [[ ${result} == *"Agent summary:"* ]]
    [[ ${result} == *"read docs/explanation/architecture.md"* ]]
    [[ ${result} == *'"verdict": "REJECT"'* ]]
    [[ ${result} != *'"type":"tool_call"'* ]]
}

@test "run_cursor_agent_with_usage captures usage from live cursor stream-json" {
    if [[ -z ${CURSOR_API_KEY:-} ]]; then
        skip "CURSOR_API_KEY not set; export it to run live Cursor usage verification"
    fi
    if ! command -v agent > /dev/null 2>&1; then
        skip "Cursor agent CLI not installed"
    fi

    local rc=0
    run_cursor_agent_with_usage agent \
        -p "Reply with exactly the single word: ok" \
        --print \
        --output-format stream-json \
        --trust || rc=$?

    [ "${rc}" -eq 0 ]
    [ "${USAGE_INPUT_TOTAL}" -gt 0 ]
    [ "${USAGE_OUTPUT_TOTAL}" -gt 0 ]
    result="$(build_usage_json)"
    [ -n "${result}" ]
    [ "$(jq -r '.total_input_tokens' <<< "${result}")" -gt 0 ]
}
