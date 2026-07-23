# CI Sweeper Triage Report Format

## Survey result (`may_edit: false`)

No file edits. **Do not emit `### Changes`, `### Deferred`, or `## Verification`.**

```markdown
# CI Sweeper Result

## Overview

<which workflow/job failed → root cause by name → no edits applied>

## Summary

### Candidates

| Target                 | Evidence           | Suggested approach       | Priority              |
| ---------------------- | ------------------ | ------------------------ | --------------------- |
| `<workflow>` / `<job>` | <from log_excerpt> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target                 | Evidence | Why not now             |
| ---------------------- | -------- | ----------------------- |
| `<workflow>` / `<job>` | <reason> | flake \| infra \| human |
```

### Survey rules

- **MUST NOT** include `### Changes`, `### Deferred`, or `## Verification`
- Zero candidates — Overview explains no-op; omit empty `### Candidates`

## Apply result (`may_edit: true`)

```markdown
# CI Sweeper Result

## Overview

<which failures were fixed vs deferred — name workflow/job and cause>

## Summary

### Changes

| Target                 | What was wrong | What changed          |
| ---------------------- | -------------- | --------------------- |
| `<workflow>` / `<job>` | <root cause>   | <minimal fix summary> |

### Deferred

| Target                 | Why deferred            |
| ---------------------- | ----------------------- |
| `<workflow>` / `<job>` | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
```

### Apply rules

- **MUST NOT** include `### Candidates` or `### Watch` in final output
- Reconcile `### Changes` and `### Deferred` with `git diff --name-only` before synthesis

## Session metrics (automation)

On the automation path, append `## Session Metrics` per [category-automation-envelope.md](category-automation-envelope.md).

## Overview (skill-specific)

| Element   | ci-sweeper content                                                       |
| --------- | ------------------------------------------------------------------------ |
| Trigger   | Which workflow/job failed (name, not URL)                                |
| Substance | Root cause in plain language — name the lint rule, file, or failure type |
| Action    | What was fixed or deferred                                               |

**Good (survey):** `CI failed on markdownlint MD001 in docs/foo.md; one regression candidate identified; no edits applied.`

**Good (apply):** `CI failed on markdownlint MD001 in docs/foo.md; fixed heading style in one file.`

**Bad:** `CI sweeper addressed actionable failures.`

## Rules

- Pick one shape per run — survey or apply.
- When `may_edit` is `false`, survey shape only — list candidates but do not edit files.
- When `may_edit` is `true`, apply shape; edit source files only for `regression` failures within allowlist.
- Do not claim validation passed when commands failed or were not run.
