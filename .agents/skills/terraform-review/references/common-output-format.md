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

## Expert Assessment

Overall Quality: <High | Medium | Low>

<2-4 sentences of holistic judgment that the checklist cannot capture:
architectural coherence, design intent alignment, hidden coupling,
maintainability trajectory, or patterns that are technically correct
but strategically concerning. State what is not obvious from the
individual check results.>

## Good Practices

- <Specific praise for well-done aspects: good abstractions, thorough
  error handling, clean separation of concerns, effective testing, etc.>
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

## Judgment Rules

### MUST vs SHOULD

- MUST checks: Flag as Failed whenever violated regardless of context.
- SHOULD checks: Flag as Failed only when the violation introduces concrete risk (security, correctness, maintainability degradation). If the pattern is idiomatic for the project context, mark as Passed.

### ItemID Assignment

- Assign only ItemIDs that exist in `common-checklist.md`. Do not repurpose an existing ItemID for an unrelated finding.
- If a finding does not map to any checklist ItemID, omit it from the structured report. Mention it in a free-text note after the Issues section if it is high-severity.

### Expert Assessment

- Always include `## Expert Assessment` after `## Issues`.
- State the Overall Quality level based on the ratio and severity of failures: High (0 critical, ≤2 minor), Medium (some failures but no systemic pattern), Low (systemic issues or critical failures).
- Write 2-4 sentences of holistic judgment covering concerns that individual checks cannot surface: architectural coherence, hidden coupling, maintainability trajectory, or patterns that pass all rules but are strategically problematic.
- Do not repeat findings already listed in `## Issues`. Focus on cross-cutting observations.

### Good Practices

- Always include `## Good Practices` after `## Expert Assessment`.
- List 1-3 specific, concrete things the code does well.
- If no notable good practices are observed, write `No notable good practices identified` rather than omitting the section.

## Status Symbols

| Symbol | Meaning  | When to Use                                              |
| ------ | -------- | -------------------------------------------------------- |
| ✅     | Pass     | Check verified correct (counted in summary only)         |
| ❌     | Fail     | Check failed, issue identified                           |
| ⊘      | Deferred | Check not yet evaluable due to explicit prerequisite gap |
