#!/usr/bin/env bats

# Tests for aws_paginate_items and aws_retry_exec in scripts/lib/aws.sh

setup() {
    source "scripts/lib/aws.sh"
    source "test/bats/support/aws_mock.bash"
    mock_aws_setup
}

teardown() {
    mock_aws_teardown
}

@test "aws_paginate_items returns nothing for empty array" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
echo '{"UserPools":[]}'
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'UserPools' aws cognito-idp list-user-pools --region us-east-1
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "aws_paginate_items returns items for single page" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
echo '{"UserPools":[{"Id":"1"},{"Id":"2"}]}'
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'UserPools' aws cognito-idp list-user-pools --region us-east-1
    [ "$status" -eq 0 ]
    # Count lines of output
    lines=$(printf "%s\n" "$output" | grep -c '^')
    [ "$lines" -eq 2 ]
}

@test "aws_paginate_items paginates with NextToken" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--next-token"* || "$*" == *"--starting-token"* ]]; then
  echo '{"UserPools":[{"Id":"2"}]}'
else
  echo '{"UserPools":[{"Id":"1"}],"NextToken":"T1"}'
fi
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'UserPools' aws cognito-idp list-user-pools --region us-east-1
    [ "$status" -eq 0 ]
    lines=$(printf "%s\n" "$output" | grep -c '^')
    [ "$lines" -eq 2 ]
}

@test "aws_paginate_items handles CloudFront NextMarker pagination" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--marker"* || "$*" == *"--next-token"* ]]; then
    echo '{"DistributionList":{"Items":[{"Id":"D2"}]}}'
else
    echo '{"DistributionList":{"Items":[{"Id":"D1"}]},"NextMarker":"M1"}'
fi
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'DistributionList.Items' aws cloudfront list-distributions --region us-east-1
    [ "$status" -eq 0 ]
    lines=$(printf "%s
" "$output" | grep -c '^')
    [ "$lines" -eq 2 ]
}

@test "aws_paginate_items handles DynamoDB LastEvaluatedTableName pagination" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--exclusive-start-table-name"* ]]; then
    echo '{"TableNames":["table2"]}'
else
    echo '{"TableNames":["table1"],"LastEvaluatedTableName":"table1"}'
fi
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'TableNames' aws dynamodb list-tables --region us-east-1
    [ "$status" -eq 0 ]
    lines=$(printf "%s
" "$output" | grep -c '^')
    [ "$lines" -eq 2 ]
}

@test "aws_paginate_items handles DynamoDB list-global-tables pagination" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--exclusive-start-global-table-name"* ]]; then
    echo '{"GlobalTables":[{"GlobalTableName":"g2"}]}'
else
    echo '{"GlobalTables":[{"GlobalTableName":"g1"}],"LastEvaluatedGlobalTableName":"g1"}'
fi
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'GlobalTables' aws dynamodb list-global-tables --region us-east-1
    [ "$status" -eq 0 ]
    lines=$(printf "%s
" "$output" | grep -c '^')
    [ "$lines" -eq 2 ]
}

@test "aws_paginate_items values can be unquoted with jq -r for primitive arrays (DynamoDB TableNames)" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--exclusive-start-table-name"* ]]; then
    echo '{"TableNames":["table2"]}'
else
    echo '{"TableNames":["table1"],"LastEvaluatedTableName":"table1"}'
fi
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'TableNames' aws dynamodb list-tables --region us-east-1
    [ "$status" -eq 0 ]
    # Unquote values using jq -r and assert both names exist
    jq_out=$(printf "%s\n" "$output" | jq -r '.')
    [[ "$jq_out" == *"table1"* ]]
    [[ "$jq_out" == *"table2"* ]]
}

@test "aws_paginate_items handles S3 list-objects-v2 ContinuationToken pagination" {
    mock_aws_write << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--continuation-token"* ]]; then
    echo '{"Contents":[{"Key":"obj2"}]}'
else
    echo '{"Contents":[{"Key":"obj1"}],"NextContinuationToken":"ct1"}'
fi
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_paginate_items 'Contents' aws s3api list-objects-v2 --bucket my-bucket --region us-east-1
    [ "$status" -eq 0 ]
    lines=$(printf "%s
" "$output" | grep -c '^')
    [ "$lines" -eq 2 ]
}

@test "aws_retry_exec retries on failure and succeeds" {
    # The mock aws will fail once then succeed
    cat > "$MOCK_DIR/aws" << 'EOF'
#!/usr/bin/env bash
COUNT_FILE="$MOCK_DIR/count.txt"
count=$(cat "$COUNT_FILE" 2> /dev/null || echo 0)
count=$((count + 1))
echo "$count" > "$COUNT_FILE"
if [[ "$count" -lt 2 ]]; then
  echo "transient error" >&2
  exit 1
fi

echo "ok"
EOF
    chmod +x "$MOCK_DIR/aws"

    run aws_retry_exec aws cognito-idp list-user-pools --region us-east-1
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}
