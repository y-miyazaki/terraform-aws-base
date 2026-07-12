#!/usr/bin/env bats

# Tests for .github/actions/loop-execute/lib/paths.sh

setup() {
    source ".github/actions/loop-execute/lib/paths.sh"
}

@test "collect_allowlist_violations returns nothing when allowlist unset" {
    unset ALLOWLIST
    run collect_allowlist_violations $'docs/a.md\nsrc/b.go'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "collect_allowlist_violations flags paths outside allowlist" {
    ALLOWLIST="docs/*,README.md"
    output=$(collect_allowlist_violations $'docs/a.md\nsrc/b.go')
    [[ ${output} == *"src/b.go"* ]]
    [[ ${output} != *"docs/a.md"* ]]
}

@test "collect_allowlist_violations matches docs root markdown via ** glob" {
    ALLOWLIST="docs/**/*.md,README.md,mkdocs.yml"
    output=$(collect_allowlist_violations $'docs/index.md\nsrc/b.go')
    [[ ${output} != *"docs/index.md"* ]]
    [[ ${output} == *"src/b.go"* ]]
}

@test "collect_allowlist_violations matches nested docs markdown via ** glob" {
    ALLOWLIST="docs/**/*.md"
    output=$(collect_allowlist_violations $'docs/explanation/architecture.md\nREADME.md')
    [[ ${output} != *"docs/explanation/architecture.md"* ]]
    [[ ${output} == *"README.md"* ]]
}

@test "path_matches_glob supports trailing ** directory patterns" {
    run path_matches_glob ".github/workflows/ci.yaml" ".github/**"
    [ "$status" -eq 0 ]
    run path_matches_glob "README.md" ".github/**"
    [ "$status" -eq 1 ]
}

@test "collect_denylist_violations flags denylisted paths" {
    DENYLIST="**/.env,**/secrets*"
    output=$(collect_denylist_violations $'docs/a.md\nnested/.env\nconfig/secrets.json')
    [[ ${output} == *"nested/.env"* ]]
    [[ ${output} == *"config/secrets.json"* ]]
    [[ ${output} != *"docs/a.md"* ]]
}

@test "collect_denylist_violations matches ** at start of pattern" {
    DENYLIST="**/.env"
    output=$(collect_denylist_violations $'nested/.env\n.env')
    [[ ${output} == *"nested/.env"* ]]
    [[ ${output} == *".env"* ]]
}

@test "collect_denylist_violations returns nothing when denylist unset" {
    unset DENYLIST
    run collect_denylist_violations $'docs/a.md\n.env'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "infer_files_from_text uses fallback when no paths found" {
    unset INFER_FILES_PATTERN
    result=$(infer_files_from_text "no paths here" "docs/fallback.md")
    [ "${result}" = "docs/fallback.md" ]
}

@test "infer_files_from_text extracts repo-relative paths" {
    unset INFER_FILES_PATTERN
    result=$(infer_files_from_text "Fix docs/guide.md and src/app/main.go please" "")
    [[ ${result} == *"docs/guide.md"* ]]
    [[ ${result} == *"src/app/main.go"* ]]
}

@test "infer_files_from_text honors INFER_FILES_PATTERN" {
    INFER_FILES_PATTERN='[a-z]+\.md'
    result=$(infer_files_from_text "update readme.md and src/main.go" "fallback.md")
    [ "${result}" = "readme.md" ]
}
