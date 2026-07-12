---
name: markdown-validation
description: >-
  Validate Markdown syntax, formatting, and links using markdownlint-cli2 and markdown-link-check.
  Use when committing docs changes, checking broken links, or validating Markdown in pull requests.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Markdown file(s) with `.md` extension (required)
- Optional: markdownlint-cli2 config, markdown-link-check config, file pattern (`**/*.md`)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured validation results from two tools: markdownlint-cli2 → markdown-link-check.
Return `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes markdownlint-cli2 and markdown-link-check in order.
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
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when markdownlint-cli2 or link checks fail unexpectedly
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging tools directly

## Workflow

1. Run `bash scripts/validate.sh` (or `bash scripts/validate.sh <path>` for scoped validation).
2. Parse script output and map results to checklist ItemIDs.
3. Report failed/deferred items per [references/common-output-format.md](references/common-output-format.md).

### Examples

- Prompt: `Validate Markdown files and report only failed checks.`
- Command: `bash scripts/validate.sh ./docs/`
- Output: per-tool results with deferred status for network-only link failures.
