# Output Format Specification

Use the following report structure for review and validation output.

```markdown
# <Result Title>

## Checks Summary

- Status: <completed | failed | skipped>
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

1. <short judgment title>
   - Scope: <path#L<line>, area, or cross-cutting>
   - Observation: <specific judgment the checklist does not capture>
   - Impact: <scope and severity>
   - Recommendation: <actionable next step>

## Good Practices

1. <short title>
   - Scope: <path#L<line>, area, or cross-cutting>
   - Why it helps: <concrete benefit>
```

## Rules

- Keep full evaluation data for all checks internally using fixed ItemIDs from `references/common-checklist.md`.
- Passed checks appear only as counts in `## Checks Summary`; do not list them in `## Checks (Failed/Deferred Only)`.
- `Status` is `completed` when the review ran, `failed` when it could not run (for example, no target file exists), and `skipped` when there is nothing in scope to review. For `failed` and `skipped`, set the counts to `0`, write one `## Issues` entry without an ItemID that states the cause (it replaces `No issues found`), and omit `## Expert Assessment` and `## Good Practices` — no checks ran, so there is nothing to assess.
- Keep ItemIDs fixed and sorted in checklist order.
- `## Issues` must always contain full details for each failed or deferred check.
- If `Status` is `completed` and there are no failed or deferred checks:
  - In `## Checks (Failed/Deferred Only)`, output `No failed or deferred checks`.
  - In `## Issues`, output `No issues found`.

## Judgment Rules

### MUST vs SHOULD

- MUST checks: Flag as Failed whenever violated regardless of context.
- SHOULD checks: Flag as Failed only when the violation introduces concrete risk (security, correctness, maintainability degradation). If the pattern is idiomatic for the project context, mark as Passed.

### ItemID Assignment

- Assign only ItemIDs that exist in `common-checklist.md`. Do not repurpose an existing ItemID for an unrelated finding.
- Checklist-mapped findings go in `## Issues` with ItemIDs.
- Findings that do not map to any checklist ItemID go in `## Expert Assessment` as numbered judgment items (no ItemID). Do not bury them in free-text prose after Issues. The one exception is the cause entry for a `failed` or `skipped` Status (see Rules).

### Expert Assessment

- Include `## Expert Assessment` after `## Issues` whenever `Status` is `completed`.
- State the Overall Quality level based on the ratio and severity of failures: High (0 MUST failures, ≤2 SHOULD failures), Medium (other failures with no systemic pattern), Low (a systemic pattern, or a MUST failure with security or correctness impact).
- Emit **numbered list items** (same field shape as Issues, without ItemID): title, Scope, Observation, Impact, Recommendation.
- Cover cross-cutting judgment the checklist cannot surface: architectural coherence, hidden coupling, maintainability trajectory, or patterns that pass rules but are strategically problematic.
- Limit to 1–5 items. If none, write `No cross-cutting concerns` under Overall Quality (do not invent filler).
- Do not repeat findings already listed in `## Issues`.

### Good Practices

- Include `## Good Practices` after `## Expert Assessment` whenever `Status` is `completed`.
- Emit **numbered list items** with title, Scope, and Why it helps (1–3 items).
- If no notable good practices are observed, write `No notable good practices identified` rather than omitting the section.

## Status Symbols

| Symbol | Meaning  | When to Use                                              |
| ------ | -------- | -------------------------------------------------------- |
| ✅     | Pass     | Check verified correct (counted in summary only)         |
| ❌     | Fail     | Check failed, issue identified                           |
| ⊘      | Deferred | Check not yet evaluable due to explicit prerequisite gap |
