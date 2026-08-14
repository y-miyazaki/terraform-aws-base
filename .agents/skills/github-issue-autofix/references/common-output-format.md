# Issue Autofix Report Format

## Survey result (`may_edit: false`)

No file edits. **Do not emit `### Changes`, `### Deferred`, or `## Verification`.**

```markdown
# Issue Autofix Result

## Overview

<Issue #N → root cause hypothesis → no edits applied>

## Summary

### Candidates

| Target | Evidence | Suggested approach | Priority              |
| ------ | -------- | ------------------ | --------------------- |
| `path` | …        | …                  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
```

### Survey rules

- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- Zero candidates — Overview explains no-op; omit empty `### Candidates`
- Do not call `repository_dispatch` from the Agent
- At synthesis on the automation path, load `assets/pr-body-template-survey.md`

## Apply result (`may_edit: true`)

```markdown
# Issue Autofix Result

## Overview

<Issue #N → root cause → what changed; mention Fixes #N>

## Summary

### Changes

| Area | What was wrong | What changed |
| ---- | -------------- | ------------ |
| …    | …              | …            |

### Deferred

| Area | Why deferred |
| ---- | ------------ |
| …    | …            |

## Verification

| Check | Result |
| ----- | ------ |
| …     | …      |
```

### Apply rules

- PR body / report **MUST** include `Fixes #<N>` (or equivalent closing keyword) for the source Issue
- Do not call `repository_dispatch` from the Agent
- At synthesis on the automation path, load `assets/pr-body-template.md`
