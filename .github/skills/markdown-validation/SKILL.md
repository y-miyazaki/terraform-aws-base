---
name: markdown-validation
description: Use markdownlint and markdown-link-check for Markdown validation. This skill provides the validation workflow and troubleshooting guidance. Individual commands are for debugging only.
license: MIT
---

# Markdown Validation

This skill provides guidance for validating Markdown documentation to ensure quality, correctness, and adherence to standards.

## When to Use This Skill

This skill is applicable for:

- Validating Markdown syntax
- Checking for broken links
- Ensuring documentation formatting
- Verifying heading hierarchy
- Debugging Markdown rendering issues

## Validation Commands

**Always use these commands for validation.**

### Usage

```bash
# 1. Markdown lint
markdownlint **/*.md

# 2. Link check (recommended)
markdown-link-check **/*.md
```

### When to Use Additional Command Options

Use detailed command options **only** for:

- Debugging specific validation failures
- Auto-fixing issues
- Using custom configurations

**For normal validation, use the required commands above.**

### Debugging Reference: Command Options

#### 1. markdownlint

**Purpose**: Validate Markdown syntax and style

```bash
# Check all Markdown files
markdownlint **/*.md

# Check specific file
markdownlint README.md

# Auto-fix issues
markdownlint --fix **/*.md

# Check with custom config
markdownlint -c .markdownlint.json **/*.md
```

**What it checks**:

- Markdown syntax errors
- Heading hierarchy (H1→H2→H3 order)
- List and table formatting
- Code block language specification
- Trailing spaces
- Line length
- Consistent style

#### 2. markdown-link-check

**Purpose**: Detect broken links

```bash
# Check all Markdown files
markdown-link-check **/*.md

# Check specific file
markdown-link-check README.md

# Check with config
markdown-link-check -c .markdown-link-check.json **/*.md
```

**What it checks**:

- Broken internal links
- Broken external links
- Invalid anchor references
- Missing files

## Validation Requirements

Before committing:

- [ ] markdownlint passes
- [ ] markdown-link-check passes
- [ ] No sensitive information
- [ ] Manual review completed

## Validation Workflow

1. **Make changes** - Edit documentation
2. **Run markdownlint**: `markdownlint **/*.md`
3. **Fix syntax issues** - Address linting errors
4. **Check links**: `markdown-link-check **/*.md`
5. **Fix broken links** - Update or remove invalid links
6. **Commit** - Only when validation passes
