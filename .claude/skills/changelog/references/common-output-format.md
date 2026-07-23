# Changelog Report Format

Deferred subsection name for this skill: `### Skipped` (not `### Deferred`).

## Survey result (no file edits)

```markdown
# Changelog Result

## Overview

<commit range → which conventional commits/releases would be recorded → no edits applied>

## Summary

### Candidates

| Target        | Type   | Evidence  | Suggested approach  | Priority              |
| ------------- | ------ | --------- | ------------------- | --------------------- |
| `<short sha>` | <type> | <subject> | <Unreleased bullet> | high \| medium \| low |

### Skipped

| Commit | Why skipped |
| ------ | ----------- |
```

### Survey rules

- **MUST NOT** include `### Changes` or `## Verification`
- Zero candidates — Overview explains no-op; omit empty `### Candidates`

## Apply result (`changelog_file` edited)

```markdown
# Changelog Result

## Overview

<which commits/releases were added to CHANGELOG — name types and sections>

## Summary

### Changes

| Commit      | Type   | Entry                                |
| ----------- | ------ | ------------------------------------ |
| <short sha> | <type> | <Unreleased bullet added or updated> |

### Skipped

| Commit | Why skipped |
| ------ | ----------- |

## Verification

| Check                    | Result         |
| ------------------------ | -------------- |
| `CHANGELOG.md` structure | <pass \| fail> |
```

### Apply rules

- **MUST NOT** include `### Candidates` in final output
- Reconcile `### Changes` with `git diff --name-only` before synthesis

## Session metrics (automation)

On the automation path, append `## Session Metrics` per [category-automation-envelope.md](category-automation-envelope.md).

## Overview (skill-specific)

**Good (survey):** `Processed 4 conventional commits since abc..def; would add 3 Unreleased bullets under Changed; no file edits applied.`

**Good (apply):** `Added 3 Unreleased bullets under Changed and promoted v1.8.16 from detect releases[].`

**Bad:** `Changelog run finished.`
