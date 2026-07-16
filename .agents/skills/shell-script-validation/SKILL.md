---
name: shell-script-validation
description: >-
  Validate shell scripts with bash -n and shellcheck for syntax safety and maintainability checks.
  Does not enforce Bats suite pairing (TEST-00) — run `bats` and shell-script-review for that.
  Use when committing script changes, running CI validation, or debugging shellcheck findings in PRs.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.1.0"
---

## Input

- Shell script path or directory (required)
- Validation script: `scripts/validate.sh` (required)
- Optional flags: `-v`, `-f`

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured results for bash -n and shellcheck (syntax and lint only).

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script runs checks in fixed order.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md)).
- **Do not review code design decisions** (use shell-script-review for that)

### USE FOR:

- run shell script syntax and lint validation before merge
- reproduce CI failures for shell scripts
- validate a specific script path during iterative fixes

### DO NOT USE FOR:

- perform architecture/design review of shell scripts
- modify business logic in scripts as a primary task
- validate non-shell files
- enforce Bats suite pairing or suite layout (use `bats` and shell-script-review)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when checks fail unexpectedly.
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging bash -n or shellcheck.
- [category-standards.md](references/category-standards.md) - Read when standards/template violations are reported.

## Workflow

1. Run `bash scripts/validate.sh`.
2. If a failure appears, rerun with target path first (for example `./scripts/deploy.sh`).
3. If failure details are insufficient, rerun with `-v`.
4. If formatting fixes are suggested, rerun with `-f` and review diffs.
5. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Examples

```bash
bash scripts/validate.sh
bash scripts/validate.sh ./scripts/deploy.sh -v
bash scripts/validate.sh -f
```
