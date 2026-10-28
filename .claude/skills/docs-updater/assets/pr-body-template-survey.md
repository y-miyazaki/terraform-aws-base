<!--
Survey-only PR template for docs-updater automation (agent_edit_allowed: false).

Load at synthesis time after survey output is complete.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Docs drift scan found stale workflow references in docs/guide/overview.md and docs/index.md; no edits applied.
  BAD:  Documentation update automation completed in survey mode.
-->

<summary: dominant drift by file/type, no edits applied>

## Summary

### Candidates

| Target        | Evidence                  | Suggested approach       | Priority              |
| ------------- | ------------------------- | ------------------------ | --------------------- |
| <linked path> | <stale/missing reference> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
