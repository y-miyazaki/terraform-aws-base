<!--
Survey-only PR template for ci-sweeper automation (agent_edit_allowed: false).

Load at synthesis time after survey output is complete.
The caller extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: CI failed on markdownlint MD001 in docs/foo.md; one regression candidate identified; no edits applied.
  BAD:  CI sweeper completed survey only.
-->

<summary: which failure, root cause by name, no edits applied>

## Summary

### Candidates

| Target                           | Evidence           | Suggested approach       | Priority              |
| -------------------------------- | ------------------ | ------------------------ | --------------------- |
| <linked workflow> / <linked job> | <from log_excerpt> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
