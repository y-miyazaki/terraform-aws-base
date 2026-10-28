<!--
PR-facing template for github-pr-revise automation (agent_edit_allowed: true).
Load ONLY at synthesis time after applying review feedback.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Applied @loop feedback on PR #5 — fixed nil check in pkg/foo/bar.go.
  BAD:  Revised the PR.
-->

<summary: which PR, what feedback, what changed>

## Summary

### Changes

| Area        | Feedback addressed | What changed                         |
| ----------- | ------------------ | ------------------------------------ |
| `<package>` | <review point>     | <linked path>: <minimal fix summary> |

### Deferred

| Area | Why deferred            |
| ---- | ----------------------- |
| —    | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
