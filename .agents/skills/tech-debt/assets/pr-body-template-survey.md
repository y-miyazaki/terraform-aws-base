<!--
Survey-only PR template for tech-debt automation (may_edit: false).

Load at synthesis time after survey output is complete.
loop-finalize extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Summary contains ### Candidates and optional ### Watch only.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.
- Overview must name dominant categories/files — not counts alone.
-->

## Overview

<!--
  GOOD: Debt scan over abc..def found broken links in docs/guide and pin drift in package.json; 12 TODO markers logged as Watch; no edits applied.
  BAD:  Debt scan found 18 Watch signals; no edits applied.
-->

<one or two sentences: scan scope, dominant findings by name, no edits applied>

## Summary

### Candidates

| Target      | Category   | Evidence            | Suggested approach         | Delegate | Priority              |
| ----------- | ---------- | ------------------- | -------------------------- | -------- | --------------------- |
| `path:line` | <category> | <snippet or metric> | <plain-language direction> | <skill>  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
