# Creation Report Format

Use the following report structure after creating or updating documentation files.

```markdown
# docs-creation Result

## Summary
- Files created: <count>
- Files updated: <count>
- Checks passed: <count>
- Checks failed: <count>

## Checks (Failed Only)
- <ItemID> <ItemName>: ❌ Fail

## Created / Updated Files

| Action  | File                 | Document Type |
| ------- | -------------------- | ------------- |
| Created | `docs/<filename>.md` | <type>        |
| Updated | `README.md`          | —             |

## Issues
1. <ItemID>: <ItemName>
   - File: <path>
   - Problem: <specific issue>
   - Recommendation: <specific fix>
```

## Rules

- If all checks pass, output `No failed checks` in `## Checks (Failed Only)`.
- If no issues, output `No issues found` in `## Issues`.
- Always list every file created or updated in `## Created / Updated Files`, including `README.md` if modified.
- Do not list passed checks individually — only counts in `## Summary`.

## Early Termination

When execution stops early (for example, case-insensitive duplicate filename conflicts), keep the same report structure and set failed checks and issues clearly.

Example for duplicate conflict:

```markdown
# docs-creation Result

## Summary
- Files created: 0
- Files updated: 0
- Checks passed: <count>
- Checks failed: 1

## Checks (Failed Only)
- NC-01 Target File Resolution and Duplicate Handling: ❌ Fail

## Created / Updated Files

No files created or updated

## Issues
1. NC-01: Target File Resolution and Duplicate Handling
   - File: docs/
   - Problem: Case-insensitive duplicate paths found: `<pathA>`, `<pathB>`
   - Recommendation: Keep one canonical lowercase underscore filename and remove or rename conflicting paths before rerunning.
```

## Status Symbols

| Symbol | Meaning | When to Use                                      |
| ------ | ------- | ------------------------------------------------ |
| ✅      | Pass    | Check verified correct (counted in summary only) |
| ❌      | Fail    | Check failed, issue identified                   |
