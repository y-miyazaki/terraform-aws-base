# docs-updater Result Format

Interactive and hook runs use this structure. Loop runs add session metrics and PR sections per [common-output-format-loop.md](common-output-format-loop.md).

```markdown
# docs-updater Result

## Overview

<trigger → problem → action; 1–2 plain-language sentences>

## Summary

### Changes

| File | What was wrong | What changed |
| ---- | -------------- | ------------ |
| `path/to/doc.md` | <stale/missing reference> | <minimal patch summary> |

### Skipped

- <count> files: <shared reason>   <!-- or table when enumerating specific paths -->

## Verification

| Check | Result |
| ----- | ------ |
| <markdown-validation or link check> | <pass \| fail \| skip> |
```

## Rules

- If nothing to update: **Overview** states skip reason; omit empty **Changes** / **Skipped** subsections.
- In **Changes**, list only files actually modified.
- **Skipped** paths MUST NOT appear in **Changes**.
- **List vs table:** group skipped files by reason in a bullet; use a table when listing 2+ distinct path/reason pairs.
- Do not emit Outcome lines or duplicate file lists outside **Changes**.
