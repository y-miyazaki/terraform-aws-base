<!--
Survey-only PR template for github-pr-revise automation (agent_edit_allowed: false).

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
  GOOD: PR #5 — @loop asked to rename handleUser and add a unit test; candidate fix scoped to pkg/foo/bar.go; no edits applied.
  BAD:  PR revise survey completed; no edits applied.
-->

<summary: PR number, feedback summarized, no edits applied>

## Summary

### Candidates

| Target        | Evidence | Suggested approach | Priority              |
| ------------- | -------- | ------------------ | --------------------- |
| <linked path> | …        | …                  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
