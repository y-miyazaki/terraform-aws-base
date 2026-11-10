# Markdown Validation - Troubleshooting Guide

## markdownlint-cli2 Failures

**Issue**: Heading level skipped (for example H1 to H3)

**Fix**:

1. Reorder headings sequentially (H1 -> H2 -> H3)
2. From the repository root, run `bash <skill-dir>/scripts/validate.sh path/to/file.md`

**Issue**: Line length or list style violations

**Fix**:

1. Report the rule IDs and lines; do not modify files during validation
2. When the user asks for fixes, run `markdownlint-cli2 --fix <files>` and adjust remaining lines by hand

## markdown-link-check Failures

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

## Validation Shell Script Issues

**Issue**: `command not found` for markdownlint-cli2 or markdown-link-check

**Fix**:

1. Ensure tools are installed in the development environment
2. Re-run the script from the repository root: `bash <skill-dir>/scripts/validate.sh`

## Revalidation

After applying fixes, run from the repository root (the script reads `.markdown-link-check.json` from the working directory):

```bash
bash <skill-dir>/scripts/validate.sh
```
