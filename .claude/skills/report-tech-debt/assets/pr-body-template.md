<!--
Canonical PR-facing template for loop-report-tech-debt.

Load ONLY at synthesis time, after report classification completes.
This skill reports debt; it does not apply code fixes.

Rules:
- Keep top-level ## Overview, ## Summary, and ## Verification headings exactly as written.
- Use ### Report (not Changes) for the persisted report file.
- Use ### Watch for deferred follow-up items (not code deferred).
- Do NOT emit Outcome or Suggested next action.
-->

## Overview

<!--
  GOOD: Debt scan over abc..def found no Critical/High items; recorded 21 Watch signals in docs/report/report-tech-debt/2026-07-21.md.
  BAD:  Technical debt loop completed.
-->

<one or two sentences: scan scope, finding severity, and where the full report lives>

## Summary

### Report

| File | What was found | What was recorded |
| ---- | -------------- | ----------------- |
| `docs/report/report-tech-debt/YYYY-MM-DD.md` | <dominant categories / counts> | <report structure summary> |

### Watch

| Path   | Why deferred |
| ------ | ------------ |
| <path> | <follow-up reason> |

## Verification

| Check | Result |
| ----- | ------ |
| Detect sensors | <pass \| fail \| skip> |
