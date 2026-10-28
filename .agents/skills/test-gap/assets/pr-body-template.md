<!--
Apply PR template for test-gap automation (agent_edit_allowed: true).

Load ONLY at synthesis time, after tests are written.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Use ### Deferred (not Skipped) for items not done in this run.
- Do NOT emit ### Candidates, Outcome, or Suggested next action.
- Never state that tests passed. You cannot run them here.
-->

## Overview

<!--
  GOOD: scripts/foo.sh had no paired Bats suite and was edited 7 times in 90 days. Added a suite covering argument parsing and the error exit path.
  BAD:  Added tests.
-->

<trigger → target and reason → tests added; name the file and behaviors>

## Summary

### Changes

| Target        | Gap                          | Tests added               |
| ------------- | ---------------------------- | ------------------------- |
| <linked path> | <behavior that was untested> | <test names or behaviors> |

### Deferred

| Target        | Reason                         |
| ------------- | ------------------------------ |
| <linked path> | <needs production change, etc> |

## Verification

| Check               | Result                                           |
| ------------------- | ------------------------------------------------ |
| `<command CI runs>` | <skip — not run here; CI expects pass for tests> |
