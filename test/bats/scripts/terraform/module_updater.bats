#!/usr/bin/env bats

# Tests for scripts/terraform/module_updater.sh (pure/testable functions)

setup() {
    # Minimal globals required by module_updater.sh
    export VERBOSE=false
    export DRY_RUN=false
    export CHECK_ONLY=false
    export RECURSIVE_SEARCH=false
    export TERRAFORM_DIR=""
    export DEFAULT_ENV="dev"
    export NO_PLAN=false
    export TOTAL_MODULES=0
    export UPDATED_MODULES=0
    export FAILED_MODULES=0
    export CURRENT_FILE_BEING_SCANNED=""

    # shellcheck disable=SC1091
    source "scripts/lib/all.sh"
    # shellcheck disable=SC1091
    source "scripts/terraform/module_updater.sh" 2> /dev/null || true

    # Create temp directory for test fixtures
    TEST_TMPDIR=$(mktemp -d)
    export BACKUP_DIR="$TEST_TMPDIR/backups"
    mkdir -p "$BACKUP_DIR"
}

teardown() {
    rm -rf "${TEST_TMPDIR:-}"
}

@test "artifact_dir_for creates sanitized directory path" {
    run artifact_dir_for "/workspace/terraform/base"
    [ "$status" -eq 0 ]
    [[ "$output" == *"workspace__terraform__base"* ]]
}

@test "artifact_dir_for strips leading slash and replaces separators" {
    run artifact_dir_for "/a/b/c"
    [ "$status" -eq 0 ]
    [[ "$output" == *"a__b__c"* ]]
}

@test "extract_modules_from_file extracts source and version pairs" {
    cat > "$TEST_TMPDIR/test.tf" << 'EOF'
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "my-vpc"
}

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"
}
EOF
    run extract_modules_from_file "$TEST_TMPDIR/test.tf"
    [ "$status" -eq 0 ]
    [[ "$output" == *"terraform-aws-modules/vpc/aws||5.1.0||"* ]]
    [[ "$output" == *"terraform-aws-modules/s3-bucket/aws||3.15.1||"* ]]
}

@test "extract_modules_from_file ignores local modules without version" {
    cat > "$TEST_TMPDIR/local.tf" << 'EOF'
module "internal" {
  source = "../../modules/aws/budgets/create"

  name = "test"
}
EOF
    run extract_modules_from_file "$TEST_TMPDIR/local.tf"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "find_terraform_modules finds files with module declarations" {
    mkdir -p "$TEST_TMPDIR/project"
    cat > "$TEST_TMPDIR/project/main.tf" << 'EOF'
module "test" {
  source = "example/module/aws"
  version = "1.0.0"
}
EOF
    cat > "$TEST_TMPDIR/project/outputs.tf" << 'EOF'
output "id" {
  value = module.test.id
}
EOF
    run find_terraform_modules "$TEST_TMPDIR/project" "false"
    [ "$status" -eq 0 ]
    [[ "$output" == *"main.tf"* ]]
    [[ "$output" != *"outputs.tf"* ]]
}

@test "find_terraform_project_root finds directory with versions.tf" {
    mkdir -p "$TEST_TMPDIR/root/sub"
    touch "$TEST_TMPDIR/root/versions.tf"
    touch "$TEST_TMPDIR/root/sub/main.tf"

    run find_terraform_project_root "$TEST_TMPDIR/root/sub/main.tf"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$TEST_TMPDIR/root"* ]]
}
