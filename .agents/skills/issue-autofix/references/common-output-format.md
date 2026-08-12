# Issue Autofix Report Format

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
