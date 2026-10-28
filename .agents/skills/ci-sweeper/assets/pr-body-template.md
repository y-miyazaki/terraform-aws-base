<!--
PR-facing template for ci-sweeper automation (agent_edit_allowed: true).

Load ONLY at synthesis time, after triage and file edits complete.
The caller may add ## Failure context from detect; this template covers Overview + Summary + Verification.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Link every repository path, commit SHA, and workflow/job in Summary tables as a markdown link per category-pr-body-links.md. <linked ...> marks where a link goes; do not emit it, and do not use a plain code span for a linkable item.
- Keep the table columns as written; do not rename, merge, or drop columns.
- Do not duplicate detect failure URLs in Overview — URLs belong in caller-added ## Failure context.
- In Summary tables, link file paths and workflow/job targets — see category-pr-body-links.md.
- Summary contains ### Changes and ### Deferred only.
- Do NOT emit Outcome, Suggested next action, or top-level ## Changes.
- Deferred = failures with NO fix in final working tree; reconcile with git diff before synthesis.
-->

## Overview

<!--
  GOOD: CI failed on markdownlint MD001 in docs/foo.md; fixed heading style in docs/foo.md; deferred flaky integration test job.
  BAD:  CI sweeper addressed actionable failures.
-->

<summary: which failure, what was fixed, what was deferred — name workflow/job and cause; do not duplicate failure URLs (caller may add ## Failure context)>

## Summary

### Changes

| Workflow / Job                   | What was wrong | What changed                         |
| -------------------------------- | -------------- | ------------------------------------ |
| <linked workflow> / <linked job> | <root cause>   | <linked path>: <minimal fix summary> |

### Deferred

| Workflow / Job                   | Why deferred            |
| -------------------------------- | ----------------------- |
| <linked workflow> / <linked job> | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
