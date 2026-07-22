# Documentation Triage Report Format

Use this structure for every loop run, including no-action exits.

## Session report (verifier / logs)

```markdown
# Documentation Triage Report

## Session Metrics

| Field             | Value |
| ----------------- | ----- |
| Level             | <L1\|L2\|L3> |
| Commit range      | <commit_range> |
| Findings assessed | <count> |
| Files modified    | <count> |
| Outcome           | <one-line verifier result> |
```

## PR body contract (human-facing)

At synthesis time, load `assets/pr-body-template.md` and emit **exactly**:

1. `## Overview`
2. `## Summary` (`### Changes`, `### Deferred`)
3. `## Verification`

`loop-finalize` adds `## Run Metadata` and omits mechanical `## Changes` when Summary contains `### Changes`.

See repository `docs/explanation/loop-engineering/loop-pr-body-skill-contract.md`.

## Fixes / Deferred consistency

**Deferred** means no fix remains in the working tree for that path.

| Rule | Requirement |
| ---- | ----------- |
| Mutual exclusion | A path MUST NOT appear in both **Changes** and **Deferred** |
| Git alignment | Every path in `git diff` MUST have a **Changes** row |
| Deferred = no edit | Revert edits to deferred paths before synthesis |

Before PR synthesis, run `git diff --name-only` and reconcile **Changes** and **Deferred**.

**Bad example ([PR #454](https://github.com/y-miyazaki/config/pull/454)):** Deferred lists `architecture.md` but git diff / platform Changes still includes it.

## Rules

- Emit session **Session Metrics** for verifier/logs only.
- At `L1`, fill PR **Changes** as intended edits but do not modify files.
- At `L2`/`L3`, edit only within prompt `## Constraints` allowlist (see `category-scope.md`).
