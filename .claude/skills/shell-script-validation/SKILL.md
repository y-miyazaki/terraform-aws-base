---
name: shell-script-validation
description: >-
  Validate shell scripts with bash -n and shellcheck for syntax safety and maintainability checks.
  Does not enforce Bats suite pairing (TEST-00) — run `bats` and shell-script-review for that.
  Use when committing script changes, running CI validation, or debugging shellcheck findings in PRs.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.2.0"
---

## Input

- Shell script path or directory (optional; defaults to workspace root)
- Validation script: `scripts/validate.sh` (required)
- Canonical flags: `-v -f --check-function-docs` (always pass all three unless opted out below)
- Opt-out: omit `--check-function-docs` only when the target scripts intentionally skip Google function header sections

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured results for bash -n and shellcheck (syntax and lint only). With `--check-function-docs`, also reports [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments) function header sections.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script runs checks in fixed order.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md)).
- **Do not review code design decisions** (use shell-script-review for that)
- **Bats output:** By default only failing tests and the summary line are printed. Use `-v` for the full pass/fail listing.

### USE FOR:

- run shell script syntax and lint validation before merge
- reproduce CI failures for shell scripts
- validate a specific script path during iterative fixes
- normalize function doc section order in `scripts/`, `scripts/lib/`, or `.github/actions/`

### Common target paths

- `scripts/` — workspace shell scripts
- `scripts/lib/` — shared library modules (source of truth; sync to skills via `bash scripts/ai/sync_skill_lib.sh`)
- `.github/actions/` — composite action helper scripts

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

1. When `scripts/lib/` changed, sync to skill copies: `bash scripts/ai/sync_skill_lib.sh` then `apm install --update`.
2. Run `bash scripts/validate.sh -v -f --check-function-docs` with an optional target path (for example `./scripts/deploy.sh`, `./scripts/lib/`, or `./.github/actions/`).
3. When function doc sections are out of order, run `bash scripts/fix_function_doc_order.sh` on the target path or directory before re-validating.
4. Review auto-fix diffs from `-f` before continuing.
5. If checks fail, fix reported issues and rerun the same command.
6. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Examples

```bash
# Canonical (workspace-wide)
bash scripts/validate.sh -v -f --check-function-docs

# Canonical (single script)
bash scripts/validate.sh -v -f --check-function-docs ./scripts/deploy.sh

# Common directories
bash scripts/validate.sh -v -f --check-function-docs ./scripts/lib/
bash scripts/validate.sh -v -f --check-function-docs ./.github/actions/

# Reorder function doc sections (Globals → Arguments → Outputs → Returns)
bash scripts/fix_function_doc_order.sh ./scripts/lib/
bash scripts/fix_function_doc_order.sh ./.github/actions/

# Opt-out: skip function doc sections when intentionally not applicable
bash scripts/validate.sh -v -f ./scripts/deploy.sh
```
