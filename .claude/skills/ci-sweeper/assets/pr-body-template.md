<!--
PR-facing template for ci-sweeper automation (may_edit: true).

Load ONLY at synthesis time, after triage and file edits complete.
loop-finalize adds ## Failure context from detect; this template covers Overview + Summary + Verification.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Do not duplicate detect failure URLs in Overview — URLs belong in platform ## Failure context.
- Summary contains ### Changes and ### Deferred only.
- Do NOT emit Outcome, Suggested next action, or top-level ## Changes.
- Deferred = failures with NO fix in final working tree; reconcile with git diff before synthesis.
-->

## Overview

<!--
  GOOD: CI failed on markdownlint MD001 in docs/foo.md; fixed heading style in docs/foo.md; deferred flaky integration test job.
  BAD:  CI sweeper addressed actionable failures.
-->

<one or two sentences: which failure, what was fixed, what was deferred — name workflow/job and cause>

## Summary

### Changes

| Workflow / Job     | What was wrong | What changed          |
| ------------------ | -------------- | --------------------- |
| <workflow> / <job> | <root cause>   | <minimal fix summary> |

### Deferred

| Workflow / Job     | Why deferred            |
| ------------------ | ----------------------- |
| <workflow> / <job> | <plain-language reason> |

## Verification

| Check         | Result                            |
| ------------- | --------------------------------- |
| <command run> | <pass \| fail \| skip \| blocked> |
