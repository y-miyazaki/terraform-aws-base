#!/usr/bin/env bash
# Helper utilities to mock the `aws` CLI for bats tests
# Provide setup/teardown functions and a convenience function to write
# a mock aws script to the mock bin.

function mock_aws_setup() {
    MOCK_DIR=$(mktemp -d)
    export MOCK_DIR
    export PATH="$MOCK_DIR:$PATH"

    # Provide a no-op sleep to speed up retry/backoff tests
    cat > "$MOCK_DIR/sleep" << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$MOCK_DIR/sleep"
}

function mock_aws_teardown() {
    if [[ -n "${MOCK_DIR:-}" && -d "$MOCK_DIR" ]]; then
        rm -rf "$MOCK_DIR"
        unset MOCK_DIR
    fi
}

# Convenience: write an aws mock script from stdin
function mock_aws_write() {
    cat > "$MOCK_DIR/aws"
    chmod +x "$MOCK_DIR/aws"
}

# Provide a helper to assert a mock exists for debugging
function mock_aws_path() {
    echo "$MOCK_DIR/aws"
}

export -f mock_aws_setup mock_aws_teardown mock_aws_write mock_aws_path
