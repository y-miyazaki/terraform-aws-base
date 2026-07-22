# Changelog Loop Report Format

Use this structure for every run, including no-action exits.

## Session report (verifier / logs)

```markdown
# Changelog Loop Report

## Commits Processed

- **SHA:** <sha>
- **Type:** <type>
- **Subject:** <subject>

## Skipped Commits

- <already listed in CHANGELOG or non-conventional, or "None">

## Session Metrics

| Field            | Value                      |
| ---------------- | -------------------------- |
| Level            | <L1\|L2\|L3>               |
| Commit range     | <commit_range>             |
| Commits assessed | <count>                    |
| File modified    | <changelog_file or "None"> |
| Outcome          | <one-line result>          |
```

## PR body contract (human-facing)

At synthesis time, load `assets/pr-body-template.md` and emit `## Overview`, `## Summary`, and `## Verification`.

See repository `docs/explanation/loop-engineering/loop-pr-body-skill-contract.md`.

### Overview (skill-specific)

Emit one paragraph under `## Overview` that answers:

| Element | changelog content                                                           |
| ------- | --------------------------------------------------------------------------- |
| Trigger | Commits/releases since last processed SHA                                   |
| Problem | What was missing from `CHANGELOG.md` (Unreleased bullets, version sections) |
| Action  | Entries added, releases promoted, or "no changes needed"                    |

**Good:** `Processed 4 conventional commits since last changelog SHA; added 3 Unreleased bullets under Changed.`

**Bad:** `Changelog loop run finished.` / listing every commit SHA in Overview

## Rules

- Always emit all session `##` sections; use `None` or `0` when empty.
- `## Session Metrics` MUST use a Field \| Value table (not bullet list).
- Always emit PR `## Overview` and `## Summary` after session report.
- At `L1`, list intended entries under Commits Processed but do not edit files.
- At `L2`/`L3`, update only `CHANGELOG.md` under `## [Unreleased]`.

