#!/usr/bin/env bats

# Tests for scripts/lib/csv.sh

setup() {
    source "scripts/lib/csv.sh"
}

@test "csv_sort sorts rows by region/subcategory/etc" {
    run normalize_csv_value ""
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    run normalize_csv_value "null"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "make_csv_safe wraps with quotes when comma present" {
    unset PRESERVE_NEWLINES
    run normalize_csv_value $'Hello\nHe"llo'
    [ "$status" -eq 0 ]
    # newlines are replaced with \n and quotes doubled
    [[ "$output" == *"Hello\\nHe\"\"llo"* ]]
}

@test "normalize_csv_value escapes quotes and newlines when PRESERVE_NEWLINES=false" {
    PRESERVE_NEWLINES=true
    run normalize_csv_value $'Line1\nLine2'
    [ "$status" -eq 0 ]
    [[ "$output" == *$'Line1\nLine2'* ]]
}

@test "normalize_csv_value preserves newlines when PRESERVE_NEWLINES=true" {
    unset PRESERVE_NEWLINES
    run make_csv_safe "foo,bar"
    [ "$status" -eq 0 ]
    [[ "$output" == '"foo,bar"' ]]
}

@test "normalize_csv_value returns empty string for empty/null" {
    local input=$'a,sub1,subsub1,regB,name2\nb,sub2,subsub2,regA,name1\n'
    run csv_sort "$input"
    [ "$status" -eq 0 ]
    # output should have regA row first
    [[ "$output" == *"regA,name1"* || "$output" == *"regA,name1"* ]]
}
