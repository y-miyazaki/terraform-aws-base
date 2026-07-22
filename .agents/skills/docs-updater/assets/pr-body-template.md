<!--
Canonical PR-facing template for loop-docs-triage.

Load ONLY at synthesis time, after triage and file edits complete.
loop-finalize extracts ## Overview, ## Summary, and ## Verification for the PR body.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Summary contains ### Changes and ### Deferred only (plus optional domain subsections).
- Do NOT emit Outcome, Suggested next action, or top-level ## Changes.
- Deferred = paths with NO fix in final working tree; reconcile with git diff before synthesis.
- Table when 2+ rows or multiple columns; bullet list when one simple item.
- Omit empty ### subsections.
-->

## Overview

<!--
  Trigger → Problem → Action in 1-2 sentences.

  GOOD: Docs drift scan found Skills inventory missing loop-refactor rows; this run updated specification.md and left three docs without matching tables unchanged.
  BAD:  Documentation triage loop completed at L2.
-->

<one or two sentences: trigger, problem, action — plain language for a reviewer>

## Summary

### Changes

| File   | What was wrong | What changed |
| ------ | -------------- | ------------ |
| <path> | <from findings> | <minimal change summary> |

### Deferred

| File   | Why deferred |
| ------ | ------------ |
| <path> | <plain-language reason> |

## Verification

| Check | Result |
| ----- | ------ |
| <command or skill> | <pass \| fail \| skip \| blocked> |
