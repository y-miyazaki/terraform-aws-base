# docs-updater Result Format

Interactive and hook runs use this structure. On the automation path, also follow [common-output-format-automation.md](common-output-format-automation.md).

## Survey result (no file edits)

```markdown
# docs-updater Result

## Overview

<trigger → dominant doc drift by file/category → no edits applied>

## Summary

### Candidates

| Target           | Evidence                  | Suggested approach       | Priority              |
| ---------------- | ------------------------- | ------------------------ | --------------------- |
| `path/to/doc.md` | <stale/missing reference> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
```

### Survey rules

- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- Zero candidates — Overview explains no-op; omit empty `### Candidates`

## Apply result (documentation files edited)

```markdown
# docs-updater Result

## Overview

<which doc files were fixed vs deferred — name paths or drift types>

## Summary

### Changes

| File             | What was wrong            | What changed            |
| ---------------- | ------------------------- | ----------------------- |
| `path/to/doc.md` | <stale/missing reference> | <minimal patch summary> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |

## Verification

| Check                         | Result                 |
| ----------------------------- | ---------------------- |
| <markdown lint or link check> | <pass \| fail \| skip> |
```

### Apply rules

- **MUST NOT** include `### Candidates` in final output
- In **Changes**, list only files actually modified
- **Deferred** paths MUST NOT appear in **Changes**
- Reconcile `### Changes` with `git diff --name-only` before synthesis

## Overview (skill-specific)

**Good (survey):** `Staged rename of src/auth module affects docs/guide.md and site nav; two drift candidates identified; no edits applied.`

**Good (apply):** `Updated docs/guide.md path references and nav entry for auth module rename.`

**Bad:** `Documentation sync completed.`
