<!--
Apply PR template for test-gap automation (may_edit: true).

Load ONLY at synthesis time, after tests are written.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
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

| Target              | Gap                          | Tests added               |
| ------------------- | ---------------------------- | ------------------------- |
| `test/path/to/file` | <behavior that was untested> | <test names or behaviors> |

### Deferred

| Target         | Reason                         |
| -------------- | ------------------------------ |
| `path/to/file` | <needs production change, etc> |

## Verification

- Command CI runs: `<command>`
- Expected result: <pass; which new tests>
- Not run in this environment.
