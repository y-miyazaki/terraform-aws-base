# Output Format Specification

Use the following report structure after creating or updating a documentation file.

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

| Action | File | Document Type |
|--------|------|---------------|
| Created | `docs/<filename>.md` | <type> |
| Updated | `README.md` | — |

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

## Status Symbols

| Symbol | Meaning | When to Use |
|--------|---------|-------------|
| ✅ | Pass | Check verified correct (counted in summary only) |
| ❌ | Fail | Check failed, issue identified |
