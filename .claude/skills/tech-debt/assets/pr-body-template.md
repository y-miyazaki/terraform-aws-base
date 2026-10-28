<!--
Apply PR template for tech-debt automation (agent_edit_allowed: true).

Load ONLY at synthesis time, after classification and edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Use ### Deferred (not Skipped) for items not fixed in this run.
- Do NOT emit ### Candidates, ### Watch, Outcome, or Suggested next action.
- Overview must name what was recorded/fixed — include scope when many items.
-->

## Overview

<!--
  GOOD: Recorded 2 High documentation findings in reports/tech-debt/2026-07-23.md and fixed a broken link in docs/guide/overview.md; deferred one architecture hotspot to refactor.
  BAD:  Technical debt automation completed with 2 fixes.
-->

<summary: what was recorded, what was fixed, what was deferred — name files/categories>

## Summary

### Changes

| Target        | What was wrong | What changed                |
| ------------- | -------------- | --------------------------- |
| <linked path> | <finding gap>  | <report recorded>           |
| <linked path> | <debt fact>    | <closed-set fix if applied> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |

## Verification

| Check          | Result                 |
| -------------- | ---------------------- |
| Detect sensors | <pass \| fail \| skip> |
