<!--
Survey PR template for test-gap automation (agent_edit_allowed: false).

Load ONLY at synthesis time.

Rules:
- Keep top-level ## Overview and ## Summary headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.
-->

## Overview

<!--
  GOOD: Scanned churn hotspots and found 3 files without paired tests; none were edited.
  BAD:  Survey done.
-->

<scan scope → candidates and why → no edits applied>

## Summary

### Candidates

| Target        | Evidence                | Suggested tests       | Priority              |
| ------------- | ----------------------- | --------------------- | --------------------- |
| <linked path> | <churn, no paired test> | <behaviors to assert> | high \| medium \| low |
