---
name: markdown-validation
description: Markdown validation using markdownlint and markdown-link-check. Use for syntax checking, link validation, and formatting verification. Always use the 2-step validation workflow. Individual commands are for debugging only.
license: MIT
---

## Purpose

Validates Markdown documentation for syntax correctness, link validity, and formatting standards using markdownlint and markdown-link-check.

This skill provides guidance for validating Markdown documentation to ensure quality, correctness, and adherence to standards.

## When to Use This Skill

Recommended usage:

- Before committing documentation changes
- During pull request validation in CI/CD
- After editing any Markdown file
- When adding new documentation
- For periodic documentation quality checks
- When debugging Markdown rendering issues

## Input Specification

This skill expects:

- Markdown file(s) (required) - Files with `.md` extension
- markdownlint configuration (optional) - `.markdownlint.json` or `.markdownlint.yaml` for custom rules
- markdown-link-check configuration (optional) - `.markdown-link-check.json` for custom link checking
- File pattern (optional) - Glob pattern for selective validation (default: `**/*.md`)

Format:

- Markdown files: Valid Markdown syntax
- Configuration files: JSON or YAML format
- File pattern: Glob pattern string (e.g., `README.md`, `docs/**/*.md`)

## Output Specification

Structured validation results from two tools:

- markdownlint output: Syntax and style violations with file paths, line numbers, and rule IDs
- markdown-link-check output: Broken links with URLs and status codes

Success output format:

```
✓ markdownlint: No issues found
✓ markdown-link-check: All links valid
All validations passed
```

Error output format:

```
✗ markdownlint: [file]:[line] [rule-id] [description]
✗ markdown-link-check: [file]: [URL] → [status code] [error]
Exit code: 1
```

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Always use `scripts/validate.sh` for comprehensive validation
- Script executes markdownlint and markdown-link-check in recommended order with proper configuration
- **Manual invocation**: Individual tool commands available for debugging (see reference/troubleshooting.md)
- **Automated CI/CD**: Integrate validate.sh into CI pipeline for automated checks

**What this skill does**:

- Validate Markdown syntax and style using markdownlint
- Check heading hierarchy (H1→H2→H3 order)
- Verify list and table formatting
- Validate code block language specification
- Check for trailing spaces and line length
- Detect broken internal and external links using markdown-link-check
- Verify anchor references
- Check for missing linked files

What this skill does NOT do (Out of Scope):

- Modify Markdown files automatically (except with --fix flag)
- Validate content accuracy or technical correctness
- Check spelling or grammar
- Render Markdown to HTML
- Validate non-Markdown files
- Check for sensitive information (manual review required)
- Approve or merge pull requests

## Constraints

Prerequisites:

- markdownlint installed and available in PATH
- markdown-link-check installed and available in PATH
- Markdown files must exist in specified paths
- Network access required for external link checking

Limitations:

- External link checking depends on network connectivity and target site availability
- Some sites may block automated link checkers
- Large repositories with many files may have slow validation
- Cannot validate links behind authentication
- Line length rules may conflict with long URLs

## Failure Behavior

Error handling:

- Tool not found: Output error message indicating which tool is missing, exit with code 1
- Syntax error: markdownlint outputs rule ID, file, line, and description, exit with code 1
- Broken link: markdown-link-check outputs URL and status code, exit with code 1
- Invalid file pattern: Output error about no matching files, exit with code 1
- Network error: markdown-link-check outputs connection error, continue with other links
- Multiple errors: Report all errors from both tools before exiting

Error reporting format:

- Each tool outputs errors to standard output
- Exit code: 0=success, 1=validation failed
- Error messages include file paths, line numbers, and specific issues
- Rule IDs provided for markdownlint errors (e.g., MD001, MD041)

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Markdown validation checklist
- **common-output-format.md** - Validation result report format specification

## Validation Script Usage

**Always use the validation script. Do not run individual commands.**

### Usage

```bash
# Full validation of all Markdown files
bash markdown-validation/scripts/validate.sh

# Validate specific file
bash markdown-validation/scripts/validate.sh ./README.md

# Validate specific directory
bash markdown-validation/scripts/validate.sh ./docs/
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **markdownlint** - Markdown syntax and style validation
2. **markdown-link-check** - Broken link detection

## Validation Requirements

Before committing Markdown changes:

- [ ] All syntax violations resolved (markdownlint passes)
- [ ] No broken internal links
- [ ] No broken external links (or documented exceptions)
- [ ] Heading hierarchy correct (H1→H2→H3 order)
- [ ] Code blocks have language specification
- [ ] No trailing spaces or excessive line length issues

## Workflow

1. **Make changes** - Edit Markdown files
2. **Run validation**: `bash markdown-validation/scripts/validate.sh`
3. **Auto-fix issues**: `bash markdown-validation/scripts/validate.sh --fix`
4. **Fix remaining issues** - Address link errors or structural problems
5. **Commit** - Only when validation passes

Detailed command options for troubleshooting are in [reference/common-individual-commands.md](reference/common-individual-commands.md).
