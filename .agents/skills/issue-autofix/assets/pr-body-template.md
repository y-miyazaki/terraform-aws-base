<!--
PR-facing template for issue-autofix automation (may_edit: true).
Load ONLY at synthesis time after the fix is implemented.
Must include Fixes #<N> for the source Issue.
-->

## Overview

<!--
  GOOD: Issue #12 crash on save — null guard in pkg/foo/bar.go; linked with Fixes #12.
  BAD:  Autofix addressed the issue.
-->

<summary: which Issue, what root cause, what changed — include Fixes #N intent>

## Summary

### Changes

| Area        | What was wrong | What changed                                      |
| ----------- | -------------- | ------------------------------------------------- |
| `<package>` | <root cause>   | ``path/to/file.go``: <minimal fix summary>        |

### Deferred

| Area | Why deferred            |
| ---- | ----------------------- |
| —    | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
