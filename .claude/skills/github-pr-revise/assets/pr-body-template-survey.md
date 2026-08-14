<!--
Survey-only PR template for github-pr-revise automation (may_edit: false).

Load at synthesis time after survey output is complete.
The caller extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Summary contains ### Candidates and optional ### Watch only.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.
-->

## Overview

<!--
  GOOD: PR #5 — @loop asked to rename handleUser and add a unit test; candidate fix scoped to pkg/foo/bar.go; no edits applied.
  BAD:  PR revise survey completed; no edits applied.
-->

<summary: PR number, feedback summarized, no edits applied>

## Summary

### Candidates

| Target | Evidence | Suggested approach | Priority              |
| ------ | -------- | ------------------ | --------------------- |
| `path` | …        | …                  | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
