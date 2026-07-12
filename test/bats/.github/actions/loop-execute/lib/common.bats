#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .github/actions/loop-execute/lib/common.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

setup() {
    bats_source_rel ".github/actions/loop-execute/lib/common.sh"
}

@test "render_template replaces placeholders" {
    result=$(render_template "Hello {{name}}, attempt {{n}}" name "world" n "2")
    [ "${result}" = "Hello world, attempt 2" ]
}

@test "normalize_no_changes_verdict defaults to APPROVE" {
    unset NO_CHANGES_VERDICT
    normalize_no_changes_verdict
    [ "${NO_CHANGES_VERDICT}" = "APPROVE" ]
}

@test "normalize_no_changes_verdict coerces reject variants to REJECT" {
    NO_CHANGES_VERDICT="reject"
    normalize_no_changes_verdict
    [ "${NO_CHANGES_VERDICT}" = "REJECT" ]
}

@test "normalize_no_changes_verdict coerces unknown values to APPROVE" {
    NO_CHANGES_VERDICT="maybe"
    normalize_no_changes_verdict
    [ "${NO_CHANGES_VERDICT}" = "APPROVE" ]
}

@test "parse_output_field extracts legacy line fields" {
    tmpf=$(mktemp)
    cat > "${tmpf}" << 'EOF'
VERDICT: REJECT
REASON: Missing tests
FILES: docs/a.md,src/b.go
EOF
    run parse_output_field "${tmpf}" "REASON"
    [ "$status" -eq 0 ]
    [ "$output" = "Missing tests" ]
    rm -f "${tmpf}"
}

@test "load_default_prompts fills empty prompt env vars" {
    unset PROMPT_VERIFIER_TASK
    unset PROMPT_VERIFIER_OUTPUT_CONTRACT
    load_default_prompts
    [[ ${PROMPT_VERIFIER_TASK} == *"loop implementer"* ]]
    [[ ${PROMPT_VERIFIER_OUTPUT_CONTRACT} == *'"verdict"'* ]]
}
