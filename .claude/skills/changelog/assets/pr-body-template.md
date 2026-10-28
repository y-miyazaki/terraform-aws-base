<!--
PR-facing template for changelog automation (agent_edit_allowed: true).

Load ONLY at synthesis time, after CHANGELOG.md edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Use ### Skipped (not Deferred) for commits not added to CHANGELOG.
- Do NOT emit Outcome or Suggested next action.
-->

## Overview

<!--
  GOOD: Processed 4 conventional commits since abc1234..def5678 (compare_url); added 3 Unreleased bullets under Changed and promoted v1.8.16.
  BAD:  Changelog run finished.
-->

<summary: which commits/releases were recorded and under which CHANGELOG sections; link compare_url when available>

## Summary

### Changes

| Commit       | Type   | Entry                                |
| ------------ | ------ | ------------------------------------ |
| <linked sha> | <type> | <Unreleased bullet added or updated> |

### Skipped

| Commit       | Why skipped                         |
| ------------ | ----------------------------------- |
| <linked sha> | <already listed / non-conventional> |

## Verification

| Check                    | Result         |
| ------------------------ | -------------- |
| `CHANGELOG.md` structure | <pass \| fail> |
