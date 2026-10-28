<!--
Survey-only PR template for github-issue-autofix automation (agent_edit_allowed: false).

Load at synthesis time after survey output is complete.
The caller extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Summary contains ### Candidates and optional ### Watch only.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Issue #12 crash on save — nil profile in pkg/foo/bar.go; fix candidate identified; no edits applied.
  BAD:  Autofix survey completed; no edits applied.
-->

<summary: Issue number, root cause hypothesis, no edits applied>

## Summary

### Candidates

| Target        | Evidence | Suggested approach | Priority              |
| ------------- | -------- | ------------------ | --------------------- |
| <linked path> | …        | …                  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
