---
name: go-validation
description: >-
  Validate Go formatting, linting, tests, and vulnerabilities for maintainable and secure code delivery.
  Use when committing Go changes, running CI validation, or debugging failing checks in repositories.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Go path or directory (required)
- Validation script: `scripts/validate.sh` (required, run from the go-validation skill directory)
- Optional flags: `--fix`, `--verbose`

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured validation results in fixed tool order.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md)).
- **Do not review code design decisions** (use go-review).
- **Do not modify source files** except `--fix` formatting.
- **Do not create or delete files**.

### USE FOR:

- run deterministic Go validation before commit or merge
- reproduce CI failures for Go format/lint/test/vulnerability checks
- verify coverage threshold and blocking validation status

### DO NOT USE FOR:

- perform architecture or design reviews (use `go-review`)
- generate new source code as a primary task
- validate non-Go projects

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when checks fail unexpectedly.
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging one tool directly.
- [category-security.md](references/category-security.md) - Read when govulncheck reports vulnerabilities.
- [category-testing.md](references/category-testing.md) - Read when tests fail or coverage drops.

## Workflow

1. Run `bash scripts/validate.sh`.
2. For fast iteration, run `bash scripts/validate.sh <path>` where `<path>` is a Go package or directory.
3. Use `--verbose` to collect tool-level diagnostics.
4. Use `--fix` only for formatting issues, then review diffs.
5. Retry at most 2 times after fixes; if checks still fail, return blocking failures and stop.

### Examples

- Prompt: `Validate Go checks and report summary, tool results, and error details.`
- Command: `bash scripts/validate.sh ./test/go/ --verbose`
- Output: `## Checks Summary` with per-tool pass/fail and coverage value.

## Error Handling and Troubleshooting

- If `scripts/validate.sh` is missing or non-executable, return `status: failed` with script path.
- If coverage remains below 80% after retries, return blocking failure with measured coverage value.
- If a single tool fails repeatedly, report that tool as failed and include last command output summary.

## Best Practices

- Use `--fix` after reviewing diffs.
- Run full validation before merge.
