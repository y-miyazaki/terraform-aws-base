## Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use `./scripts/validate.sh`.

### markdownlint

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

### markdown-link-check

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

## Manual Validation Workflow

### Before Committing

1. **Run markdownlint**:

   ```bash
   markdownlint **/*.md
   ```

2. **Fix issues** (auto-fix where possible):

   ```bash
   markdownlint --fix **/*.md
   ```

3. **Check links**:

   ```bash
   markdown-link-check **/*.md
   ```

4. **Manual review**:
   - Verify all links are correct
   - Check for proper formatting
   - Ensure consistency across documents

5. **Commit** - Commit fixed Markdown files

## Common Issues and Fixes

### Line too long

**Issue**: Lines exceed maximum length

**Fix**:

```bash
markdownlint --fix **/*.md
```

### Missing blank line before heading

**Issue**: No blank line between content and heading

**Example**:

```markdown
Some content
## Heading  # ✗ Missing blank line

Some content

## Heading  # ✓ Correct
```

**Fix**: Add blank lines before headings

### Invalid heading hierarchy

**Issue**: Skipped heading levels (e.g., H1 to H3)

**Example**:

```markdown
# Heading 1
### Heading 3  # ✗ Skipped H2

# Heading 1
## Heading 2
### Heading 3  # ✓ Correct
```

**Fix**: Use sequential heading levels

### Broken internal links

**Issue**: Link to non-existent file or anchor

**Fix**: Verify file paths and anchor names are correct

```bash
# Check specific links
markdown-link-check -c .markdown-link-check.json README.md
```

### Broken external links

**Issue**: External website or URL no longer exists

**Fix Options**:

1. Update to new URL
2. Remove outdated link
3. Document reason for removal
4. Use `.markdown-link-check.json` to skip unreliable links

## Configuration Files

### .markdownlint.json

```json
{
  "MD003": "consistent",
  "MD004": "consistent",
  "MD024": false,
  "MD033": false,
  "line-length": false
}
```

### .markdown-link-check.json

```json
{
  "ignorePatterns": [
    {
      "pattern": "^https://internal.company.com"
    }
  ],
  "timeout": "20s"
}
```

## Quick Reference

### Essential Commands

```bash
# Validate all Markdown
markdownlint **/*.md

# Auto-fix issues
markdownlint --fix **/*.md

# Check links
markdown-link-check **/*.md
```

### Validation Checklist

Before committing:

- [ ] markdownlint passes with no errors
- [ ] All links are valid (markdown-link-check passes)
- [ ] Manual review completed
- [ ] No sensitive information included
- [ ] Formatting is consistent
