<!--
PR-facing template for changelog automation (may_edit: true).

Load ONLY at synthesis time, after CHANGELOG.md edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Use ### Skipped (not Deferred) for commits not added to CHANGELOG.
- Do NOT emit Outcome or Suggested next action.
-->

## Overview

<!--
  GOOD: Processed 4 conventional commits since [abc1234..def5678](https://github.com/org/repo/compare/abc1234..def5678); added 3 Unreleased bullets under Changed and promoted v1.8.16.
  BAD:  Changelog run finished.
-->

<summary: which commits/releases were recorded and under which CHANGELOG sections; link compare_url when available>

## Summary

### Changes

| Commit      | Type   | Entry                                |
| ----------- | ------ | ------------------------------------ |
| <short sha> | <type> | <Unreleased bullet added or updated> |

### Skipped

| Commit | Why skipped                         |
| ------ | ----------------------------------- |
| <sha>  | <already listed / non-conventional> |

## Verification

| Check                    | Result         |
| ------------------------ | -------------- |
| `CHANGELOG.md` structure | <pass \| fail> |
