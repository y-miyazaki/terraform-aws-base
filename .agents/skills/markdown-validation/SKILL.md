---
name: markdown-validation
description: >-
  Validate Markdown syntax, formatting, and links using markdownlint and markdown-link-check.
  Use when committing docs changes, checking broken links, or validating Markdown in pull requests.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Markdown file(s) with `.md` extension (required)
- Optional: markdownlint config, markdown-link-check config, file pattern (`**/*.md`)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured validation results from two tools: markdownlint → markdown-link-check.
Return `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes markdownlint and markdown-link-check in order.
- **Do not modify Markdown files** (except with --fix flag)
- External link checking depends on network connectivity

### USE FOR:

- validate markdown syntax and links before commit
- investigate markdown CI failures
- run scoped markdown checks for specific docs paths

### DO NOT USE FOR:

- review prose quality or content strategy
- validate non-markdown files
- replace YAML/JSON/Terraform validation workflows

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when markdownlint or link checks fail unexpectedly
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging tools directly

## Workflow

```bash
# Full validation of all Markdown files
bash scripts/validate.sh

# Validate specific file
bash scripts/validate.sh ./README.md

# Validate specific directory
bash scripts/validate.sh ./docs/
```

### Examples

- Prompt: `Validate Markdown files and report only failed checks.`
- Command: `bash scripts/validate.sh ./docs/`
- Output: per-tool results with deferred status for network-only link failures.

## Best Practices

- Run validation before every documentation commit
- Resolve syntax violations and broken links before merge
- If `scripts/validate.sh` is missing or not executable, return `status: failed` with script path.
- If network failures affect external links, keep syntax results and mark network-dependent link checks as deferred.
- If file pattern resolves to zero markdown files, return `status: passed` with `0 files checked`.
