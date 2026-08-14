<!--
Survey-only PR template for github-issue-autofix automation (may_edit: false).

Load at synthesis time after survey output is complete.
The caller extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Summary contains ### Candidates and optional ### Watch only.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.
-->

## Overview

<!--
  GOOD: Issue #12 crash on save — nil profile in pkg/foo/bar.go; fix candidate identified; no edits applied.
  BAD:  Autofix survey completed; no edits applied.
-->

<summary: Issue number, root cause hypothesis, no edits applied>

## Summary

### Candidates

| Target | Evidence | Suggested approach | Priority              |
| ------ | -------- | ------------------ | --------------------- |
| `path` | …        | …                  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
