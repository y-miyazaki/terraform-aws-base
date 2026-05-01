## Markdown Validation - Troubleshooting Guide

### markdownlint Failures

**Issue**: Heading level skipped (for example H1 to H3)

**Fix**:
1. Reorder headings sequentially (H1 -> H2 -> H3)
2. Run `bash markdown-validation/scripts/validate.sh ./path/to/file.md`

**Issue**: Line length or list style violations

**Fix**:
1. Run auto-fix first: `markdownlint --fix **/*.md`
2. Manually adjust lines that cannot be auto-fixed

### markdown-link-check Failures

**Issue**: Broken relative link

**Fix**:
1. Confirm target file exists and path is correct from the current file
2. Update link path or move file references

**Issue**: Broken anchor link

**Fix**:
1. Confirm target heading text exactly matches generated anchor
2. Re-check heading rename impact in linked files

**Issue**: External URL timeout or transient failure

**Fix**:
1. Retry validation
2. If endpoint is flaky but valid, define ignore pattern in `.markdown-link-check.json`

### Validation Script Issues

**Issue**: `command not found` for markdownlint or markdown-link-check

**Fix**:
1. Ensure tools are installed in the development environment
2. Re-run through script: `bash markdown-validation/scripts/validate.sh`

### Revalidation

After applying fixes, run:

```bash
bash markdown-validation/scripts/validate.sh
```
