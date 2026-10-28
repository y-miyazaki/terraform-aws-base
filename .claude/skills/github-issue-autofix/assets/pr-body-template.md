<!--
PR-facing template for github-issue-autofix automation (agent_edit_allowed: true).
Load ONLY at synthesis time after the fix is implemented.
Must include Fixes #<N> for the source Issue.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Issue #12 crash on save — null guard in pkg/foo/bar.go; linked with Fixes #12.
  BAD:  Autofix addressed the issue.
-->

<summary: which Issue, what root cause, what changed — include Fixes #N intent>

## Summary

### Changes

| Area        | What was wrong | What changed                         |
| ----------- | -------------- | ------------------------------------ |
| `<package>` | <root cause>   | <linked path>: <minimal fix summary> |

### Deferred

| Area | Why deferred            |
| ---- | ----------------------- |
| —    | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
