#!/usr/bin/env bats

# Tests for scripts/terraform/validate.sh (argument parsing)

setup() {
    export VERBOSE=false
    export GENERATE_DOCS=false
    export AUTO_FIX=false
    TARGET_DIRS=()

    # shellcheck disable=SC1091
    source "scripts/lib/all.sh"

    # Source only the parse_arguments function (avoid main execution)
    eval "$(sed -n '/^function parse_arguments/,/^}/p' scripts/terraform/validate.sh)"
}

@test "parse_arguments sets VERBOSE on -v" {
    parse_arguments -v
    [ "$VERBOSE" = "true" ]
}

@test "parse_arguments sets GENERATE_DOCS on -d" {
    parse_arguments -d
    [ "$GENERATE_DOCS" = "true" ]
}

@test "parse_arguments sets AUTO_FIX on -f" {
    parse_arguments -f
    [ "$AUTO_FIX" = "true" ]
}

@test "parse_arguments collects positional args as TARGET_DIRS" {
    parse_arguments "terraform/base" "terraform/monitor"
    [ "${#TARGET_DIRS[@]}" -eq 2 ]
    [ "${TARGET_DIRS[0]}" = "terraform/base" ]
    [ "${TARGET_DIRS[1]}" = "terraform/monitor" ]
}

@test "parse_arguments fails on unknown option" {
    run parse_arguments --unknown
    [ "$status" -ne 0 ]
}
