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

### ⚠️ Required Validation Steps

**Always use these commands for validation.** Individual command options below are for debugging specific failures.

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

## Validation Checklist

### Syntax Validation

- [ ] No Markdown syntax errors
- [ ] Heading hierarchy is correct (H1→H2→H3)
- [ ] Lists are properly formatted
- [ ] Tables are properly formatted
- [ ] Code blocks have language specification
- [ ] No trailing spaces

### Content Validation

- [ ] All links are valid
- [ ] Images display correctly
- [ ] Tables are readable
- [ ] Code blocks render correctly
- [ ] No typos or grammatical errors

### Structure Validation

- [ ] Document follows standard structure
- [ ] Sections are logically organized
- [ ] Table of contents is accurate (if present)
- [ ] Cross-references are correct

## Common Validation Failures

### markdownlint failures

**Common issues**:

- MD001: Heading levels increment by one
- MD003: Heading style inconsistency
- MD009: Trailing spaces
- MD010: Hard tabs
- MD012: Multiple consecutive blank lines
- MD022: Headings should be surrounded by blank lines
- MD040: Code blocks should have language specification

**Fix examples**:

```markdown
<!-- ❌ Bad - MD001: Skipping heading level -->

# Title

### Subsection

<!-- ✅ Good -->

# Title

## Section

### Subsection

<!-- ❌ Bad - MD040: No language specified -->
```

code here

````

<!-- ✅ Good -->
```bash
code here
````

````

### markdown-link-check failures

**Common issues**:
- Broken internal links
- Broken external links
- Invalid relative paths
- Missing anchor targets

**Fix**: Update or remove broken links

## Validation Workflow

### Before Committing

1. **Edit Markdown** - Make documentation changes

2. **Run markdownlint**:
   ```bash
   markdownlint **/*.md
````

3. **Fix syntax issues** - Address linting errors

4. **Check links**:

   ```bash
   markdown-link-check **/*.md
   ```

5. **Fix broken links** - Update or remove invalid links

6. **Visual review** - Preview rendered Markdown

7. **Commit** - Only commit valid documentation

## Manual Review Checklist

Use this checklist for manual review:

- [ ] Document structure is consistent
- [ ] No typos or grammatical errors
- [ ] Code blocks display correctly
- [ ] Links are valid
- [ ] Images display correctly
- [ ] Tables are properly formatted
- [ ] Headings are descriptive
- [ ] Content is accurate and up-to-date

## Best Practices

### Validation Frequency

- Run `markdownlint` after every edit
- Run `markdown-link-check` before committing
- Visual preview during writing
- Peer review for important documentation

## Security Guidelines

### Sensitive Information

**Never include**:

- API keys or passwords
- Real production data
- Personal information
- Internal confidential information

**Use instead**:

- Placeholder values
- Sample/dummy data
- Generic examples
- Environment variable references

### Public Repository Checklist

Before publishing documentation:

- [ ] No sensitive information
- [ ] No hardcoded credentials
- [ ] No internal URLs or hostnames
- [ ] `.gitignore` configured for sensitive docs
- [ ] Environment variables used for secrets

## Quick Reference

### Essential Commands

```bash
# Lint Markdown
markdownlint **/*.md

# Auto-fix issues
markdownlint --fix **/*.md

# Check links
markdown-link-check **/*.md
```

### Validation Checklist

Before committing:

- [ ] markdownlint passes (`markdownlint **/*.md`)
- [ ] markdown-link-check passes (`markdown-link-check **/*.md`)
- [ ] No sensitive information
- [ ] Manual review completed

## Summary

Markdown validation ensures high-quality documentation:

1. **Validate syntax** - Use `markdownlint`
2. **Check links** - Use `markdown-link-check`
3. **Follow standards** - Maintain consistent style
4. **Review manually** - Check content quality
5. **Protect sensitive data** - Remove confidential information
6. **Validate before committing** - Never commit invalid documentation
