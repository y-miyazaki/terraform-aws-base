<!--
PR-facing template for refactor automation (may_edit: true).

Load ONLY at synthesis time, after refactor edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Use ### Deferred for candidates not applied in this run.
- Do NOT emit Outcome or Suggested next action.
-->

## Overview

<!--
  GOOD: Survey found two duplication blocks in sync scripts; this run deduplicated both helpers and deferred one oversized validator.
  BAD:  Refactor run finished.
-->

<one or two sentences: candidates found, how many applied, plain language for a reviewer>

## Summary

### Changes

| Target            | What was wrong            | What changed             |
| ----------------- | ------------------------- | ------------------------ |
| `path` `symbol()` | <plain-language evidence> | <minimal change summary> |

### Deferred

| Target | Why deferred            |
| ------ | ----------------------- |
| `path` | <plain-language reason> |

## Verification

| Check              | Result                            |
| ------------------ | --------------------------------- |
| <command or skill> | <pass \| fail \| skip \| blocked> |
