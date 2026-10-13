# Test Gap Result Format

Deferred subsection name for this skill: `### Deferred` (not `### Skipped`).

## Survey result (`may_edit: false`)

```markdown
# Test Gap Result

## Overview

<scan scope → candidate targets and why → no edits applied>

## Summary

### Candidates

| Target         | Evidence                | Suggested tests       | Priority              |
| -------------- | ----------------------- | --------------------- | --------------------- |
| `path/to/file` | <churn, no paired test> | <behaviors to assert> | high \| medium \| low |
```

Survey rules: MUST NOT include `### Changes`, `### Deferred`, or `## Verification`. Zero candidates: Overview explains the no-op and omits `### Candidates`.

## Apply result (`may_edit: true`, `write_target: fix`)

```markdown
# Test Gap Result

## Overview

<trigger → target and reason (state the new reason if the path is in the ledger) → tests added>

## Summary

### Changes

| Target              | Gap                          | Tests added               |
| ------------------- | ---------------------------- | ------------------------- |
| `test/path/to/file` | <behavior that was untested> | <test names or behaviors> |

### Deferred

| Target         | Reason                         |
| -------------- | ------------------------------ |
| `path/to/file` | <needs production change, etc> |

## Verification

- Command CI runs: `<command>`
- Expected result: <pass; which new tests>
- Not run in this environment.
```

Apply rules: omit empty `###` headings. Never write that tests passed.
