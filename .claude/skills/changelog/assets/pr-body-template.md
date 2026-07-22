<!--
Canonical PR-facing template for loop-changelog.

Load ONLY at synthesis time, after CHANGELOG.md edits complete.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Use ### Skipped (not Deferred) for commits not added to CHANGELOG.
- Do NOT emit Outcome or Suggested next action.
-->

## Overview

<!--
  GOOD: Processed 4 conventional commits since last changelog SHA; added 3 Unreleased bullets under Changed.
  BAD:  Changelog loop run finished.
-->

<one or two sentences: which commits were processed and what CHANGELOG section was updated>

## Summary

### Changes

| Commit      | Type   | Entry |
| ----------- | ------ | ----- |
| <short sha> | <type> | <Unreleased bullet added or updated> |

### Skipped

| Commit | Why skipped |
| ------ | ----------- |
| <sha>  | <already listed / non-conventional> |

## Verification

| Check | Result |
| ----- | ------ |
| `CHANGELOG.md` structure | <pass \| fail> |
