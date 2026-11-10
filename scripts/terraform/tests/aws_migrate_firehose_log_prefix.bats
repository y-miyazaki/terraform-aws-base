#!/usr/bin/env bats
# shellcheck disable=SC2154

# Tests for scripts/terraform/aws_migrate_firehose_log_prefix.sh
#
# Use cases:
# - required options are validated
# - dry-run lists the old and new prefixes without moving objects
# - old prefixes are discovered from S3 and filtered by the name prefix
# - execute moves only prefixes matching the name prefix
# - execute fails when the move fails
# - --jobs must be a positive integer
# - --jobs moves prefixes concurrently, keeps each prefix's output together, and stops
#   starting new prefixes after a failure

bats_require_minimum_version 1.5.0

TARGET_SCRIPT="${BATS_TEST_DIRNAME}/../aws_migrate_firehose_log_prefix.sh"

setup() {
    MOCK_BIN="${BATS_TEST_TMPDIR}/bin"
    export MOCK_STATE="${BATS_TEST_TMPDIR}/state"
    export MOCK_LOG="${BATS_TEST_TMPDIR}/aws.log"
    export MOCK_EVENTS="${BATS_TEST_TMPDIR}/events.log"
    mkdir -p "${MOCK_BIN}" "${MOCK_STATE}"
    : > "${MOCK_LOG}"
    : > "${MOCK_EVENTS}"
    cat > "${MOCK_BIN}/aws" << 'MOCK'
#!/bin/bash
echo "$*" >> "${MOCK_LOG}"
case "$1 $2" in
    "sts get-caller-identity") echo "123456789012" ;;
    "s3 mv")
        name="${3#s3://my-bucket/Logs/}"
        name="${name%/}"
        echo "start ${name}" >> "${MOCK_EVENTS}"
        sleep "${MOCK_MV_SLEEP:-0}"
        if [[ ${name} == "${MOCK_SLOW_NAME:-}" ]]; then sleep 2; fi
        echo "end ${name}" >> "${MOCK_EVENTS}"
        if [[ ${name} == "${MOCK_FAIL_NAME:-}" ]]; then exit 1; fi
        ;;
    "s3api list-objects-v2")
        printf '{"CommonPrefixes":['
        sep=""
        for p in ${MOCK_PREFIXES:-base-app other-app} AWSLogs; do
            printf '%s{"Prefix":"Logs/%s/"}' "${sep}" "${p}"
            sep=","
        done
        printf ']}\n'
        ;;
esac
MOCK
    chmod +x "${MOCK_BIN}/aws"
    export PATH="${MOCK_BIN}:${PATH}"
}

teardown() {
    rm -rf "${BATS_TEST_TMPDIR:?}/bin" "${BATS_TEST_TMPDIR:?}/state" "${BATS_TEST_TMPDIR:?}/aws.log" "${BATS_TEST_TMPDIR:?}/events.log"
}

@test "dry-run lists prefixes and does not move objects" {
    run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1
    [ "$status" -eq 0 ]
    [[ $output == *"s3://my-bucket/Logs/base-app/ -> s3://my-bucket/Logs/AWSLogs/123456789012/cloudwatchlogs/ap-northeast-1/base-app/"* ]]
    [[ $output != *"objects)"* ]]
    run ! grep -q "^s3 mv" "${MOCK_LOG}"
}

@test "dry-run with jobs lists every prefix without moving objects" {
    MOCK_PREFIXES="base-a base-b base-c" run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --jobs 3
    [ "$status" -eq 0 ]
    [[ $output == *"Logs/base-a/ ->"* ]]
    [[ $output == *"Logs/base-b/ ->"* ]]
    [[ $output == *"Logs/base-c/ ->"* ]]
    run ! grep -q "^s3 mv" "${MOCK_LOG}"
}

@test "execute fails when the move fails" {
    MOCK_FAIL_NAME=base-app run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute
    [ "$status" -ne 0 ]
    [[ $output != *"moved"* ]]
}

@test "execute moves only streams matching the name prefix" {
    run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 -n base- --execute
    [ "$status" -eq 0 ]
    grep -q "^s3 mv s3://my-bucket/Logs/base-app/ s3://my-bucket/Logs/AWSLogs/123456789012/cloudwatchlogs/ap-northeast-1/base-app/ --recursive" "${MOCK_LOG}"
    run ! grep -q "other-app" "${MOCK_LOG}"
}

@test "execute with jobs does not start new prefixes after a failure" {
    MOCK_PREFIXES="base-a base-b base-c" MOCK_FAIL_NAME=base-a MOCK_SLOW_NAME=base-b \
        run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute --jobs 2
    [ "$status" -ne 0 ]
    grep -q "^s3 mv s3://my-bucket/Logs/base-b/" "${MOCK_LOG}"
    run ! grep -q "^s3 mv s3://my-bucket/Logs/base-c/" "${MOCK_LOG}"
}

@test "execute with jobs fails and names the failed prefix" {
    MOCK_PREFIXES="base-a base-b base-c" MOCK_FAIL_NAME=base-b \
        run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute --jobs 2
    [ "$status" -ne 0 ]
    [[ $output == *"1 of 3 prefixes failed: base-b"* ]]
}

@test "execute with jobs keeps each prefix's output together" {
    MOCK_PREFIXES="base-a base-b base-c base-d" MOCK_MV_SLEEP=1 \
        run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute --jobs 4
    [ "$status" -eq 0 ]
    local name
    for name in base-a base-b base-c base-d; do
        [ "$(grep -A1 "Logs/${name}/ ->" <<< "${output}" | tail -n 1)" = "  moved" ]
    done
}

@test "execute with jobs moves every prefix exactly once" {
    MOCK_PREFIXES="base-a base-b base-c base-d" \
        run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute --jobs 3
    [ "$status" -eq 0 ]
    [ "$(grep -c '^s3 mv ' "${MOCK_LOG}")" -eq 4 ]
    local name
    for name in base-a base-b base-c base-d; do
        [ "$(grep -c "^s3 mv s3://my-bucket/Logs/${name}/ " "${MOCK_LOG}")" -eq 1 ]
    done
}

@test "execute with jobs one moves prefixes one at a time" {
    MOCK_PREFIXES="base-a base-b" MOCK_MV_SLEEP=1 \
        run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute --jobs 1
    [ "$status" -eq 0 ]
    [ "$(cut -d' ' -f1 "${MOCK_EVENTS}" | paste -sd, -)" = "start,end,start,end" ]
}

@test "execute with jobs starts prefixes concurrently" {
    MOCK_PREFIXES="base-a base-b base-c base-d" MOCK_MV_SLEEP=1 \
        run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --execute --jobs 4
    [ "$status" -eq 0 ]
    [ "$(head -n 4 "${MOCK_EVENTS}" | grep -c '^start')" -eq 4 ]
    [ "$(grep -c '^end' "${MOCK_EVENTS}")" -eq 4 ]
}

@test "jobs must be a positive integer" {
    run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --jobs 0
    [ "$status" -ne 0 ]
    [[ $output == *"--jobs must be a positive integer"* ]]
    run bash "${TARGET_SCRIPT}" -b my-bucket -r ap-northeast-1 --jobs abc
    [ "$status" -ne 0 ]
    [[ $output == *"--jobs must be a positive integer"* ]]
}

@test "missing bucket is rejected" {
    run bash "${TARGET_SCRIPT}" -r ap-northeast-1
    [ "$status" -ne 0 ]
    [[ $output == *"--bucket is required"* ]]
}

@test "missing region is rejected" {
    run bash "${TARGET_SCRIPT}" -b my-bucket
    [ "$status" -ne 0 ]
    [[ $output == *"--region is required"* ]]
}
