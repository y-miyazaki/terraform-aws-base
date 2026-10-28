<!--
Survey-only PR template for changelog automation (agent_edit_allowed: false).

Load at synthesis time after survey output is complete.

Rules:
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
-->

## Overview

<!--
  GOOD: Since abc1234..def5678 (compare_url), 4 conventional commits (2 feat, 2 fix) would add Unreleased bullets under Added and Fixed; no CHANGELOG edits applied.
  BAD:  Changelog run finished.
-->

<summary: which commits/releases would be recorded and under which sections; link compare_url when available>

## Summary

### Candidates

| Target       | Type   | Evidence  | Suggested approach  | Priority              |
| ------------ | ------ | --------- | ------------------- | --------------------- |
| <linked sha> | <type> | <subject> | <Unreleased bullet> | high \| medium \| low |

### Skipped

| Commit | Why skipped |
| ------ | ----------- |
