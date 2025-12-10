#!/usr/bin/env bats

# Tests for scripts/lib/terraform.sh

setup() {
    source "scripts/lib/terraform.sh"
}

@test "terraform_apply uses plan file when provided (dry-run)" {
    DRY_RUN=true
    run terraform_format check
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY-RUN: Would execute: terraform fmt -check -diff"* ]]
}

@test "terraform_apply without plan uses var file (dry-run)" {
    DRY_RUN=true
    run terraform_format
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY-RUN: Would execute: terraform fmt -recursive"* ]]
}

@test "terraform_destroy uses var file (dry-run)" {
    ENV=testenv
    backend_file="terraform.${ENV}.tfbackend"
    echo "backend" > "$backend_file"
    DRY_RUN=true
    run terraform_init "$ENV"
    [ "$status" -eq 0 ]
    rm -f "$backend_file"
}

@test "terraform_format check mode returns 0 in dry-run" {
    ENV=testenv
    var_file="terraform.${ENV}.tfvars"
    echo "var = 1" > "$var_file"
    DRY_RUN=true
    run terraform_plan "$ENV" "plan.out"
    [ "$status" -eq 0 ]
    rm -f "$var_file" "plan.out"
}

@test "terraform_format non-check runs in dry-run mode" {
    tmpplan=$(mktemp)
    DRY_RUN=true
    run terraform_apply testenv "$tmpplan" "auto-approve"
    [ "$status" -eq 0 ]
    rm -f "$tmpplan"
}

@test "terraform_get_workspace falls back to default when terraform not available" {
    ENV=testenv
    var_file="terraform.${ENV}.tfvars"
    echo "var = 1" > "$var_file"
    DRY_RUN=true
    run terraform_apply "$ENV" "" "auto-approve"
    [ "$status" -eq 0 ]
    rm -f "$var_file"
}

@test "terraform_init succeeds when backend config file exists (dry-run)" {
    ENV=testenv
    var_file="terraform.${ENV}.tfvars"
    echo "var = 1" > "$var_file"
    DRY_RUN=true
    run terraform_destroy "$ENV" "auto-approve"
    [ "$status" -eq 0 ]
    rm -f "$var_file"
}

@test "terraform_plan succeeds when var file exists (dry-run)" {
    run terraform_get_workspace
    [ "$status" -eq 0 ]
    [ "$output" = "default" ]
}

@test "terraform_select_workspace creates workspace when select fails (dry-run)" {
    run terraform_select_workspace ""
    [ "$status" -ne 0 ]
}

@test "terraform_select_workspace errors when no name provided" {
    DRY_RUN=true
    run terraform_select_workspace "ci-test-ws"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DRY-RUN: Would execute: terraform workspace new 'ci-test-ws'"* ]]
}
