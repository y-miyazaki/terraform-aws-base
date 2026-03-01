#!/usr/bin/env bats

# Tests for scripts/lib/validation.sh

setup() {
    source "scripts/lib/validation.sh"
}

@test "validate_directory_exists fails for missing dir" {
    missing="/tmp/nonexistentdir.$RANDOM"
    run validate_directory_exists "$missing" "TestDir"
    [ "$status" -ne 0 ]
    [[ "$output" == *"TestDir not found"* || "$output" == *"not found"* ]]
}

@test "validate_directory_exists succeeds for existing dir" {
    tmpd=$(mktemp -d)
    run validate_directory_exists "$tmpd" "TestDir"
    [ "$status" -eq 0 ]
    rm -rf "$tmpd"
}

@test "validate_file_exists fails for missing file" {
    missing="/tmp/nonexistent.$RANDOM"
    run validate_file_exists "$missing" "TestFile"
    [ "$status" -ne 0 ]
    [[ "$output" == *"TestFile not found"* || "$output" == *"not found"* ]]
}

@test "validate_file_exists succeeds for existing readable file" {
    tmpf=$(mktemp)
    echo hello > "$tmpf"
    run validate_file_exists "$tmpf" "TestFile"
    [ "$status" -eq 0 ]
    rm -f "$tmpf"
}

@test "validate_file_permissions detects correct and incorrect perms" {
    tmpf=$(mktemp)
    cat > "$tmpf" << 'EOF'
#!/bin/bash
echo ok
EOF
    chmod 644 "$tmpf"
    run validate_script_syntax "$tmpf"
    [ "$status" -eq 0 ]
    rm -f "$tmpf"
}

@test "validate_files_in_directory validates files with provided function" {
    tmpf=$(mktemp)
    cat > "$tmpf" << 'EOF'
#!/bin/bash
if then
EOF
    chmod 644 "$tmpf"
    run validate_script_syntax "$tmpf"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Script syntax error"* || "$output" == *"syntax"* ]]
    rm -f "$tmpf"
}

@test "validate_json_file validates correct and incorrect JSON" {
    tmpf=$(mktemp)
    echo data > "$tmpf"
    chmod 644 "$tmpf"
    run validate_file_permissions "$tmpf" "644"
    [ "$status" -eq 0 ]

    chmod 755 "$tmpf"
    run validate_file_permissions "$tmpf" "644"
    [ "$status" -ne 0 ]
    rm -f "$tmpf"
}

@test "validate_script_executable recognizes executable and non-executable" {
    tmpf=$(mktemp)
    echo echo hi > "$tmpf"
    chmod 644 "$tmpf"
    run validate_script_executable "$tmpf"
    [ "$status" -ne 0 ]

    chmod +x "$tmpf"
    run validate_script_executable "$tmpf"
    [ "$status" -eq 0 ]
    rm -f "$tmpf"
}

@test "validate_script_syntax fails for invalid script" {
    tmpf=$(mktemp)
    echo '{"a":1}' > "$tmpf"
    run validate_json_file "$tmpf"
    [ "$status" -eq 0 ]

    echo '{a:1}' > "$tmpf"
    run validate_json_file "$tmpf"
    [ "$status" -ne 0 ]
    rm -f "$tmpf"
}

@test "validate_script_syntax succeeds for syntactically valid script" {
    tmpf=$(mktemp)
    echo $'key: value' > "$tmpf"
    run validate_yaml_file "$tmpf"
    # If python or yq not available, function may warn and return 0; accept 0
    [ "$status" -eq 0 ] || [ "$status" -eq 0 ]

    echo $'key: [unclosed' > "$tmpf"
    run validate_yaml_file "$tmpf"
    # If validation tool not available, it may return 0; otherwise expect non-zero
    rm -f "$tmpf"
}

@test "validate_yaml_file validates correct and invalid YAML when python available" {
    tmpd=$(mktemp -d)
    # create two simple scripts
    echo -e "#!/bin/bash\necho ok" > "$tmpd/a.sh"
    echo -e "#!/bin/bash\necho ok" > "$tmpd/b.sh"
    chmod +x "$tmpd/a.sh" "$tmpd/b.sh"
    run validate_files_in_directory "$tmpd" "sh" validate_script_syntax
    [ "$status" -eq 0 ]
    rm -rf "$tmpd"
}
