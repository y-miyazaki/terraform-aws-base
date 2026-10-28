<!--
Survey-only PR template for refactor automation (agent_edit_allowed: false).

Load at synthesis time after survey output is complete.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Surveyed in-scope shell scripts and found duplication in two deploy helpers and an oversized detect script; no edits applied.
  BAD:  Refactor run finished.
-->

<summary: scope surveyed, dominant candidates by name, no edits applied>

## Summary

### Candidates

| Target                   | Evidence                  | Suggested approach             | Priority              |
| ------------------------ | ------------------------- | ------------------------------ | --------------------- |
| <linked path> `symbol()` | <plain-language evidence> | <plain-language fix direction> | high \| medium \| low |

### Watch

| Target        | Evidence                  | Why not now             |
| ------------- | ------------------------- | ----------------------- |
| <linked path> | <plain-language evidence> | <plain-language reason> |
