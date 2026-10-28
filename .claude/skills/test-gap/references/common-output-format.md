# Test Gap Result Format

Deferred subsection name for this skill: `### Deferred` (not `### Skipped`).

## Survey result (`agent_edit_allowed: false`)

```markdown
# Test Gap Result

## Overview

<scan scope → candidate targets and why → no edits applied>

## Summary

### Candidates

| Target        | Evidence                | Suggested tests       | Priority              |
| ------------- | ----------------------- | --------------------- | --------------------- |
| <linked path> | <churn, no paired test> | <behaviors to assert> | high \| medium \| low |
```

Survey rules: MUST NOT include `### Changes`, `### Deferred`, or `## Verification`. Zero candidates: Overview explains the no-op and omits `### Candidates`.

## Apply result (`agent_edit_allowed: true`, `agent_edit_target: fix`)

```markdown
# Test Gap Result

## Overview

<trigger → target and reason (state the new reason if the path is in the ledger) → tests added>

## Summary

### Changes

| Target        | Gap                          | Tests added               |
| ------------- | ---------------------------- | ------------------------- |
| <linked path> | <behavior that was untested> | <test names or behaviors> |

### Deferred

| Target        | Reason                         |
| ------------- | ------------------------------ |
| <linked path> | <needs production change, etc> |

## Verification

| Check               | Result                                           |
| ------------------- | ------------------------------------------------ |
| `<command CI runs>` | <skip — not run here; CI expects pass for tests> |
```

Apply rules: omit empty `###` headings. Never write that tests passed.
