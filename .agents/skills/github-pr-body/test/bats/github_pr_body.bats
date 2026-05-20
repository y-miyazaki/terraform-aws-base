#!/usr/bin/env bats

# Tests for .github/skills/github-pr-body/scripts/pr_body.sh

setup() {
    source ".github/skills/github-pr-body/scripts/pr_body.sh"

    export PR_NUMBER="123"
    export REPOSITORY="octocat/Hello-World"
    export DRY_RUN="true"
    export COMPLETE_BODY_FILE=""
    export BODY_FILE
    BODY_FILE="$(mktemp)"
    COMPLETE_BODY_PATH="$(mktemp)"

    CURRENT_BODY=$(
        cat << 'EOF'
## Related Issues

<!--
Link related GitHub issues using #issue_number
-->
EOF
    )

    cat > "$COMPLETE_BODY_PATH" << 'EOF'
## Overview

Completed AI overview.

## Testing

- Ran terraform validate for application modules.

## Type of Change

- [x] 🐛 Bug Fix: Issue resolution

## Checklist

- [x] Documentation updated if applicable

## Additional Notes

- No additional migration steps required.
EOF
}

teardown() {
    rm -f "$BODY_FILE"
    rm -f "$COMPLETE_BODY_PATH"
}

gh() {
    if [[ "$1 $2" == "pr view" ]]; then
        printf '%s\n' "$CURRENT_BODY"
        return 0
    fi

    echo "unexpected gh invocation: $*" >&2
    return 1
}

@test "section_has_visible_content ignores comment-only sections" {
    local section
    section=$(
        cat << 'EOF'
## Testing

<!-- single line comment -->

<!--
multi line comment
-->
EOF
    )

    run section_has_visible_content "$section"
    [ "$status" -ne 0 ]
}

@test "generate_body_sections creates deterministic overview baseline" {
    generate_body_sections

    run cat "$BODY_FILE"

    [ "$status" -eq 0 ]
    [[ "$output" == *"## Overview"* ]]
    [[ "$output" == *"**Title**:"* ]]
    [[ "$output" == *"_This section was auto-generated._"* ]]
}

@test "apply_complete_pr_body previews the full AI-completed body" {
    COMPLETE_BODY_FILE="$COMPLETE_BODY_PATH"

    run apply_complete_pr_body

    [ "$status" -eq 0 ]
    [[ "$output" == *"Completed AI overview."* ]]
    [[ "$output" == *"Ran terraform validate for application modules."* ]]
    [[ "$output" == *"Documentation updated if applicable"* ]]
}
