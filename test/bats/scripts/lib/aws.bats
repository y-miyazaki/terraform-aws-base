#!/usr/bin/env bats

# Tests for scripts/lib/aws.sh (pure functions)

setup() {
    # Source library (tests run from repo root)
    source "scripts/lib/aws.sh"

    # Use mock helper to centralize test mock setup
    source "test/bats/support/aws_mock.bash"
    mock_aws_setup
}

teardown() {
    mock_aws_teardown
}

@test "extract_jq_value returns default for empty json" {
    run extract_jq_value "" '.Name' "DEFAULT"
    [ "$status" -eq 0 ]
    [ "$output" = "DEFAULT" ]
}

@test "extract_jq_value extracts value from json" {
    local js
    js='{"Name":"Alice","Age":30}'
    run extract_jq_value "$js" '.Name' "DEFAULT"
    [ "$status" -eq 0 ]
    [ "$output" = "Alice" ]
}

@test "extract_jq_array returns joined quoted list for array" {
    local js
    js='{"Tags":["a","b","c"]}'
    run extract_jq_array "$js" '.Tags'
    [ "$status" -eq 0 ]
    [ "$output" = '"a,b,c"' ]
}

@test "extract_jq_array returns default when key missing" {
    local js
    js='{}'
    run extract_jq_array "$js" '.Tags' 'DEFAULT'
    [ "$status" -eq 0 ]
    [ "$output" = "DEFAULT" ]
}

@test "aws_safe_exec returns stdout on success" {
    run aws_safe_exec "echo hello"
    [ "$status" -eq 0 ]
    [ "$output" = "hello" ]
}

@test "aws_safe_exec returns non-zero on failure" {
    run aws_safe_exec "bash -c 'exit 2'"
    [ "$status" -ne 0 ]
}

@test "is_service_available_in_region returns 0 for iam" {
    run is_service_available_in_region iam
    [ "$status" -eq 0 ]
}

@test "is_service_available_in_region handles lambda with aws success" {
    # mock aws to succeed on lambda list-functions
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"lambda list-functions"* ]]; then
  exit 0
fi
exit 1
EOF
    chmod +x "$MOCK_DIR/aws"

    run is_service_available_in_region lambda us-east-1
    [ "$status" -eq 0 ]
}

@test "get_waf_association returns WebACL ARN" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
echo '{"WebACL":{"ARN":"arn:aws:waf::123:regional/webacl/MyWebACL/uuid"}}'
EOF
    chmod +x "$MOCK_DIR/aws"

    run get_waf_association "arn:aws:apigateway:us-east-1::/restapis/abc" us-east-1
    [ "$status" -eq 0 ]
    [ "$output" = "arn:aws:waf::123:regional/webacl/MyWebACL/uuid" ]
}

@test "format_aws_timestamp converts seconds" {
    run format_aws_timestamp 1609459200
    [ "$status" -eq 0 ]
    [[ "$output" == 2021* ]]
}

@test "format_aws_timestamp handles milliseconds" {
    run format_aws_timestamp 1609459200000
    [ "$status" -eq 0 ]
    [[ "$output" == 2021* ]]
}

@test "parse_arn returns json with components" {
    run parse_arn "arn:aws:ec2:us-east-1:123456789012:instance/i-0123456789abcdef0"
    [ "$status" -eq 0 ]
    [[ "$output" =~ '"service": "ec2"' ]]
    [[ "$output" =~ '"region": "us-east-1"' ]]
}

@test "get_resource_name_from_arn extracts resource name" {
    run get_resource_name_from_arn "arn:aws:ec2:us-east-1:123456789012:instance/i-0123456789abcdef0"
    [ "$status" -eq 0 ]
    [ "$output" = "i-0123456789abcdef0" ]
}

@test "get_waf_name extracts name from ARN path" {
    local arn="arn:aws:wafv2:us-east-1:123456789012:regional/webacl/MyWebACL/uuid"
    run get_waf_name "$arn"
    [ "$status" -eq 0 ]
    [ "$output" = "MyWebACL" ]
}
