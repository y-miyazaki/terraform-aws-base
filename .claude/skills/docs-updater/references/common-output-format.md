# docs-updater Result Format

Interactive and hook runs use this structure. On the automation path, also follow [common-output-format-automation.md](common-output-format-automation.md).

## Survey result (no file edits)

```markdown
# docs-updater Result

## Overview

<trigger → dominant doc drift by file/category → no edits applied>

## Summary

### Candidates

| Target        | Evidence                  | Suggested approach       | Priority              |
| ------------- | ------------------------- | ------------------------ | --------------------- |
| <linked path> | <stale/missing reference> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
```

### Survey rules

- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- Zero candidates — Overview explains no-op; omit empty `### Candidates`
- `Target` carries the doc path with the line number; `Evidence` names the source location the statement was compared with (UV-07)
- Statements that could not be verified go under `### Watch`; a doc that needs a new section or new-behavior explanation is listed under `### Candidates` with the approach "hand off to a documentation authoring workflow (for example docs-creator)"
- Overview states the resolved baseline when the run is change-driven

## Apply result (documentation files edited)

```markdown
# docs-updater Result

## Overview

<which doc files were fixed vs deferred — name paths or drift types>

## Summary

### Changes

| File          | What was wrong            | What changed            |
| ------------- | ------------------------- | ----------------------- |
| <linked path> | <stale/missing reference> | <minimal patch summary> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |

## Verification

| Check                         | Result                            |
| ----------------------------- | --------------------------------- |
| <markdown lint or link check> | <pass \| fail \| skip \| blocked> |
```

### Apply rules

- **MUST NOT** include `### Candidates` in final output
- In **Changes**, list only files actually modified
- **Deferred** paths MUST NOT appear in **Changes**
- Reconcile `### Changes` with `git diff --name-only` before synthesis
- `### Changes` `What was wrong` names the source location the fix was verified against (UV-07); `### Deferred` lists docs handed off to a documentation authoring workflow
- Statements that could not be verified are listed under `### Deferred` with the reason "unverifiable" (the apply shape has no Watch)
- `## Verification` includes one row for the orphan search (UV-08) and one for the claim check (UV-07), in addition to the lint or link check
- Verification `Result`: `pass` = the check ran and passed; `fail` = it ran and failed; `skip` = not run here because the caller or request says so; `blocked` = could not run (tool or input missing). State the reason in the Check cell for `skip` and `blocked`.

## Overview (skill-specific)

**Good (survey):** `Staged rename of src/auth module affects docs/guide.md and site nav; two drift candidates identified; no edits applied.`

**Good (apply):** `Updated docs/guide.md path references and nav entry for auth module rename.`

**Bad:** `Documentation sync completed.`
