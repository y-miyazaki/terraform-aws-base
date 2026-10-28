<!--
PR-facing template for refactor automation (agent_edit_allowed: true).

Load ONLY at synthesis time, after refactor edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Use ### Deferred for candidates not applied in this run.
- Do NOT emit Outcome or Suggested next action.
-->

## Overview

<!--
  GOOD: Survey found two duplication blocks in sync scripts; this run deduplicated both helpers and deferred one oversized validator.
  BAD:  Refactor run finished.
-->

<summary: candidates found, what was applied vs deferred — plain language for a reviewer>

## Summary

### Changes

| Target                   | What was wrong            | What changed             |
| ------------------------ | ------------------------- | ------------------------ |
| <linked path> `symbol()` | <plain-language evidence> | <minimal change summary> |

### Deferred

| Target        | Why deferred            |
| ------------- | ----------------------- |
| <linked path> | <plain-language reason> |

## Verification

| Check              | Result                            |
| ------------------ | --------------------------------- |
| <command or skill> | <pass \| fail \| skip \| blocked> |
