#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for .github/actions/loop-execute/lib/verifier.sh

_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"

setup() {
    bats_source_rel ".github/actions/loop-execute/lib/common.sh"
    bats_source_rel ".github/actions/loop-execute/lib/usage.sh"
    bats_source_rel ".github/actions/loop-execute/lib/verifier.sh"
}

@test "extract_last_json_fence returns the last json block" {
    tmpf=$(mktemp)
    cat > "${tmpf}" << 'EOF'
Some prose
```json
{"verdict":"REJECT","reason":"first"}
```
More prose
```json
{"verdict":"APPROVE","reason":"final"}
```
EOF
    result=$(extract_last_json_fence "${tmpf}")
    [[ ${result} == *'"verdict":"APPROVE"'* ]]
    [[ ${result} != *'"reason":"first"'* ]]
    rm -f "${tmpf}"
}

@test "parse_verifier_output parses fenced JSON APPROVE" {
    tmpf=$(mktemp)
    cat > "${tmpf}" << 'EOF'
Looks good.
```json
{
  "verdict": "APPROVE",
  "reason": "docs only"
}
```
EOF
    parse_verifier_output "${tmpf}"
    [ "${parsed}" = "true" ]
    [ "${verdict}" = "APPROVE" ]
    [ "${reason}" = "docs only" ]
    rm -f "${tmpf}"
}

@test "parse_verifier_output parses fenced JSON REJECT with files array" {
    tmpf=$(mktemp)
    cat > "${tmpf}" << 'EOF'
```json
{
  "verdict": "REJECT",
  "files": ["docs/a.md", "docs/b.md"],
  "issue": "scope",
  "fix": "limit to allowlist",
  "reason": "out of scope"
}
```
EOF
    parse_verifier_output "${tmpf}"
    [ "${parsed}" = "true" ]
    [ "${verdict}" = "REJECT" ]
    [ "${files}" = "docs/a.md,docs/b.md" ]
    [ "${issue}" = "scope" ]
    [ "${fix}" = "limit to allowlist" ]
    rm -f "${tmpf}"
}

@test "parse_verifier_output falls back to legacy VERDICT lines" {
    tmpf=$(mktemp)
    cat > "${tmpf}" << 'EOF'
VERDICT: REJECT
REASON: Legacy format
FILES: docs/old.md
ISSUE: stale
FIX: refresh
EOF
    parse_verifier_output "${tmpf}"
    [ "${parsed}" = "true" ]
    [ "${verdict}" = "REJECT" ]
    [ "${reason}" = "Legacy format" ]
    [ "${files}" = "docs/old.md" ]
    rm -f "${tmpf}"
}

@test "parse_verifier_output defaults to REJECT when unparsable" {
    tmpf=$(mktemp)
    echo "no structured verdict here" > "${tmpf}"
    parse_verifier_output "${tmpf}"
    [ "${parsed}" = "false" ]
    [ "${verdict}" = "REJECT" ]
    rm -f "${tmpf}"
}

@test "parse_verifier_output parses cursor stream-json verifier capture" {
    parse_verifier_output "test/fixtures/loop-execute/cursor-stream-json-verifier.ndjson"
    [ "${parsed}" = "true" ]
    [ "${verdict}" = "REJECT" ]
    [ "${files}" = "docs/explanation/architecture.md" ]
    [ "${issue}" = "factual mismatch in module list" ]
    [ "${fix}" = "align architecture.md with current packages" ]
    [ "${reason}" = "docs inconsistent with repo" ]
}
