# Output Format Specification

Use the following report structure for review and validation output.

```markdown
# <Result Title>

## Checks Summary
- Total checks: <number>
- Passed: <count>
- Failed: <count>
- Deferred: <count>

## Checks (Failed/Deferred Only)
- <ItemID> <ItemName>: ❌ Fail
- <ItemID> <ItemName>: ⊘ Deferred (<explicit reason>)

## Issues
1. <ItemID>: <ItemName>
   - File: <path>#L<line>
   - Problem: <specific issue>
   - Impact: <scope and severity>
   - Recommendation: <specific fix>
```

## Rules

- Keep full evaluation data for all checks internally using fixed ItemIDs from `references/common-checklist.md`.
- In human-readable output, display only:
  - `## Checks Summary` (counts), and
  - `## Checks (Failed/Deferred Only)`.
- Do not list passed checks in `## Checks (Failed/Deferred Only)`.
- Keep ItemIDs fixed and sorted in checklist order.
- `## Issues` must always contain full details for each failed or deferred check.
- If there are no failed or deferred checks:
  - In `## Checks (Failed/Deferred Only)`, output `No failed or deferred checks`.
  - In `## Issues`, output `No issues found`.

## Status Symbols

| Symbol | Meaning  | When to Use                                             |
| ------ | -------- | ------------------------------------------------------- |
| ✅      | Pass     | Check verified correct (counted in summary only)        |
| ❌      | Fail     | Check failed, issue identified                          |
| ⊘      | Deferred | Check not yet evaluable due to explicit prerequisite gap |
