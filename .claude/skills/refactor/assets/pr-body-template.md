<!--
Apply-mode PR template for loop-refactor (L2/L3) and interactive apply mode.

Load ONLY at synthesis time, after refactor edits complete.
loop-finalize extracts ## Overview, ## Summary, and ## Verification for the PR body.

Rules:
- Summary contains ### Changes and optional ### Deferred only.
- Do NOT emit ### Candidates, ### Watch, Outcome, Suggested next action, or top-level ## Changes.
- Deferred = paths with NO fix in final working tree; reconcile with git diff before synthesis.
- Table when 2+ rows or multiple columns; bullet list when one simple item.
- Omit empty ### subsections.
-->

## Overview

<!--
  GOOD: Survey found two duplication blocks in sync scripts; this run deduplicated both helpers and deferred one oversized validator.
  BAD:  Refactor loop completed at L2.
-->

<one or two sentences: candidates found, how many applied, plain language for a reviewer>

## Summary

### Changes

| Target | What was wrong | What changed |
| ------ | -------------- | ------------ |
| `path` `symbol()` | <plain-language evidence> | <minimal change summary> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |
| `path` | <plain-language reason> |

## Verification

| Check | Result |
| ----- | ------ |
| <command or skill> | <pass \| fail \| skip \| blocked> |
