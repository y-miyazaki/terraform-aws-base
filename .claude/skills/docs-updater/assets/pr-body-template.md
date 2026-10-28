<!--
PR-facing template for docs-updater automation (agent_edit_allowed: true).

Load ONLY at synthesis time, after triage and file edits complete.
The caller extracts ## Overview, ## Summary, and ## Verification for the PR body.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Summary contains ### Changes and ### Deferred only (plus optional domain subsections).
- Do NOT emit Outcome, Suggested next action, or top-level ## Changes.
- Deferred = paths with NO fix in final working tree; reconcile with git diff before synthesis.
- Table when 2+ rows or multiple columns; bullet list when one simple item.
- Omit empty ### subsections.
-->

## Overview

<!--
  Trigger → Problem → Action in plain language.

  GOOD: Docs drift scan found Skills inventory missing refactor skill rows; this run updated specification.md and left three docs without matching tables unchanged.
  BAD:  Documentation update automation completed in apply mode.
-->

<summary: trigger, problem, action — plain language for a reviewer>

## Summary

### Changes

| File          | What was wrong  | What changed             |
| ------------- | --------------- | ------------------------ |
| <linked path> | <from findings> | <minimal change summary> |

### Deferred

| File          | Why deferred            |
| ------------- | ----------------------- |
| <linked path> | <plain-language reason> |

## Verification

| Check              | Result                            |
| ------------------ | --------------------------------- |
| <command or skill> | <pass \| fail \| skip \| blocked> |
