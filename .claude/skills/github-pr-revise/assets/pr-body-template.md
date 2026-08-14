<!--
PR-facing template for github-pr-revise automation (may_edit: true).
Load ONLY at synthesis time after applying review feedback.
-->

## Overview

<!--
  GOOD: Applied @loop feedback on PR #5 — fixed nil check in pkg/foo/bar.go.
  BAD:  Revised the PR.
-->

<summary: which PR, what feedback, what changed>

## Summary

### Changes

| Area        | Feedback addressed | What changed                             |
| ----------- | ------------------ | ---------------------------------------- |
| `<package>` | <review point>     | `path/to/file.go`: <minimal fix summary> |

### Deferred

| Area | Why deferred            |
| ---- | ----------------------- |
| —    | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
