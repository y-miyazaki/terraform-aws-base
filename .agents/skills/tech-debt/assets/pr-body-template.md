<!--
Apply PR template for tech-debt automation (may_edit: true).

Load ONLY at synthesis time, after classification and edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Use ### Deferred (not Skipped) for items not fixed in this run.
- Do NOT emit ### Candidates, ### Watch, Outcome, or Suggested next action.
- Overview must name what was recorded/fixed — not counts alone.
-->

## Overview

<!--
  GOOD: Recorded 2 High documentation findings in docs/report/tech-debt/2026-07-23.md and fixed a broken link in docs/guide/overview.md; deferred one architecture hotspot to refactor.
  BAD:  Technical debt loop completed with 2 fixes.
-->

<one or two sentences: what was recorded, what was fixed, what was deferred — name files/categories>

## Summary

### Changes

| Target                                | What was wrong | What changed                |
| ------------------------------------- | -------------- | --------------------------- |
| `docs/report/tech-debt/YYYY-MM-DD.md` | <finding gap>  | <report recorded>           |
| `path/to/file`                        | <debt fact>    | <closed-set fix if applied> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |

## Verification

| Check          | Result                 |
| -------------- | ---------------------- |
| Detect sensors | <pass \| fail \| skip> |
