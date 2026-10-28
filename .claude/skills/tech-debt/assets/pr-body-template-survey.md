<!--
Survey-only PR template for tech-debt automation (agent_edit_allowed: false).

Load at synthesis time after survey output is complete.
The caller extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Summary contains ### Candidates and optional ### Watch only.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.
- Overview must name dominant categories/files — not counts alone.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Debt scan over abc..def found broken links in docs/guide and pin drift in package.json; 12 TODO markers logged as Watch; no edits applied.
  BAD:  Debt scan found 18 Watch signals; no edits applied.
-->

<summary: scan scope, dominant findings by name, no edits applied>

## Summary

### Candidates

| Target               | Category   | Evidence            | Suggested approach         | Delegate | Priority              |
| -------------------- | ---------- | ------------------- | -------------------------- | -------- | --------------------- |
| <linked path>:<line> | <category> | <snippet or metric> | <plain-language direction> | <skill>  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
