# Output Format

Use the following report structure for GitHub PR overview output.

```markdown
# GitHub PR Overview Update Result

## Status

## Updated Sections

- Overview: ✅ Updated
- Changes: ✅ Updated

## Sample Output

[Generated PR Body content showing structured updates]
```

## Rules

- Output shows which PR Body sections were updated.
- Preserve other template sections unmodified.
- Updates must be idempotent (running twice produces same result).
- If no sections updated, indicate "No sections required update".
