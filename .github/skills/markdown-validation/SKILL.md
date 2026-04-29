---
name: markdown-validation
description: >-
  Validates Markdown files for syntax correctness, formatting standards, and broken links using
  markdownlint and markdown-link-check. Use when committing documentation changes, checking for
  broken links, or validating Markdown formatting in pull requests.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Markdown file(s) with `.md` extension (required)
- markdownlint configuration (`.markdownlint.json` or `.markdownlint.yaml`) (optional)
- markdown-link-check configuration (`.markdown-link-check.json`) (optional)
- File pattern for selective validation (default: `**/*.md`) (optional)

SKILL.md structural requirements are handled by `agent-skills-review`, not by this skill.

## Output Specification

Structured validation results from two tools: markdownlint → markdown-link-check.

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes markdownlint and markdown-link-check in recommended order
- **Do not modify Markdown files** (except with --fix flag)
- External link checking depends on network connectivity

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification

## Workflow

**Always use the validation script. Do not run individual commands.**

```bash
# Full validation of all Markdown files
bash markdown-validation/scripts/validate.sh

# Validate specific file
bash markdown-validation/scripts/validate.sh ./README.md

# Validate specific directory
bash markdown-validation/scripts/validate.sh ./docs/
```

### What the Script Does

1. **markdownlint** - Markdown syntax and style validation
2. **markdown-link-check** - Broken link detection

Detailed command options for troubleshooting are in [references/common-individual-commands.md](references/common-individual-commands.md).

## Output Format

```
✓ markdownlint: No issues found
✓ markdown-link-check: All links valid
All validations passed
```

## Best Practices

- Run validation before every documentation commit
- All syntax violations and broken links must be resolved before merge
- Heading hierarchy must be correct (H1→H2→H3 order)
- Code blocks should have language specification
