<!--
Survey-only PR template for ci-sweeper automation (may_edit: false).

Load at synthesis time after survey output is complete.
loop-finalize extracts ## Overview and ## Summary only (no ## Verification).
-->

## Overview

<!--
  GOOD: CI failed on markdownlint MD001 in docs/foo.md; one regression candidate identified; no edits applied.
  BAD:  CI sweeper completed survey only.
-->

<one or two sentences: which failure, root cause by name, no edits applied>

## Summary

### Candidates

| Target                 | Evidence           | Suggested approach       | Priority              |
| ---------------------- | ------------------ | ------------------------ | --------------------- |
| `<workflow>` / `<job>` | <from log_excerpt> | <plain-language fix dir> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
