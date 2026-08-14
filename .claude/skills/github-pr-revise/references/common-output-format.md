# PR Revise Report Format

## Survey result (`may_edit: false`)

No file edits. **Do not emit `### Changes`, `### Deferred`, or `## Verification`.**

```markdown
# PR Revise Result

## Overview

<PR #N → feedback summarized → no edits applied>

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
- At synthesis on the automation path, load `assets/pr-body-template-survey.md`

## Apply result (`may_edit: true`)

```markdown
# PR Revise Result

## Overview

<PR #N → feedback addressed → what changed>

## Summary

### Changes

| Area | Feedback addressed | What changed |
| ---- | ------------------ | ------------ |
| …    | …                  | …            |

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

- At synthesis on the automation path, load `assets/pr-body-template.md`
