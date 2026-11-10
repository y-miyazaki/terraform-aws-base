---
name: shell-script-validation
description: >-
  Validate shell scripts with bash -n and shellcheck for syntax safety and maintainability checks.
  Does not enforce Bats suite pairing (TEST-00) — companion stem `bats` covers pairing rules.
  Use when committing script changes, running CI validation, or debugging shellcheck findings in PRs.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.2.1"
---

## Input

- Shell script path or directory (recommended): pass explicit target paths. Without a target, the script searches from a root it computes relative to its own install location (three levels above `scripts/`); in an installed skill copy that is the agent root directory (for example `.claude/`), not the repository root. Relative target and `--tests` paths resolve against that same root, so pass absolute paths
- Validation script (required): `scripts/validate.sh`
- Default flags: `-v -f --check-function-docs`
- `-f` (default on): rewrites script formatting with `shfmt` in place and, with `--check-function-docs`, reorders function doc sections with `scripts/fix_function_doc_order.sh` when it is present — review the diff before continuing
- `--check-function-docs` (default on in this skill; off in the script unless passed): omit only when targets intentionally skip Google function header sections and function order checks
- `--tests PATH` (optional, repeatable): limit the Bats suites the script runs to PATH (directory or `.bats` file); pass an absolute path
- `--skip-tests` (optional): skip Bats execution; use when the repository has no Bats suites or `bats` is not installed

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Structured results for bash -n and shellcheck (syntax and lint), plus Bats suite results unless `--skip-tests` is passed. With `--check-function-docs`, also reports [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments) function header sections and top-level function order (show_usage, parse_arguments, a-z, main; detection only).

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script runs checks in fixed order.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md)).
- The script continues after a failing check (no fail-fast) and reports every script.
- **Bats:** Unless `--skip-tests` is passed, the script also discovers and runs Bats suites (every `.bats` file under its computed root — see Input — or only those under `--tests PATH`) and requires `bats` or `bats-core`. By default only failing tests and the summary line are printed; use `-v` for the full pass/fail listing.
- **File changes:** `-f` rewrites files in place (`shfmt` formatting, plus function doc section order with `--check-function-docs`). Do not modify files otherwise.

### USE FOR:

- run shell script syntax and lint validation before merge
- reproduce CI failures for shell scripts
- validate a specific script path during iterative fixes
- normalize function doc section order when this skill ships `scripts/fix_function_doc_order.sh`

### DO NOT USE FOR:

- perform architecture/design review of shell scripts
- modify business logic in scripts as a primary task
- validate non-shell files
- enforce Bats suite pairing or suite layout (companion stem `bats` covers pairing rules)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)
- [category-standards.md](references/category-standards.md) (read on failure)

## Workflow

1. Run `bash scripts/validate.sh -v -f --check-function-docs <absolute target path>` (file or directory under review). Add `--tests <absolute path>` to scope Bats to the suites paired with the target, or `--skip-tests` when the repository has no Bats suites.
2. Review auto-fix diffs from `-f` (formatting and function doc section order) before continuing.
3. If checks fail, fix reported issues and rerun the same command.
4. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Error Handling

| Condition                                                                             | Severity    | Action                                                                               |
| ------------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------ |
| `scripts/validate.sh` missing                                                         | Fatal       | Stop; report missing script                                                          |
| No shell scripts under target path                                                    | Info        | Report no reviewable scripts; stop                                                   |
| Required binary missing (`shellcheck`, `shfmt`, or `bats`/`bats-core` when Bats runs) | Fatal       | Stop; report the missing binary; set `Status: ❌ FAIL`                               |
| Single tool fails, others succeed                                                     | Recoverable | Report every tool; mark the failed tool ❌ Fail with exit status                     |
| All tools fail                                                                        | Fatal       | Set `Status: ❌ FAIL` with per-tool stderr summaries in `## Error Details`           |
| Function docs intentionally skipped                                                   | Info        | Omit `--check-function-docs`; document opt-out in Summary                            |
| `common-checklist.md` unavailable                                                     | Fatal       | Stop; report missing dependency                                                      |
| `common-output-format.md` unavailable                                                 | Recoverable | Note missing file; emit `## Summary`, `## Tool Results`, and `## Error Details` only |

### Examples

- Prompt: `Validate shell scripts (syntax, shellcheck, optional function docs)`
- Command: `bash scripts/validate.sh -v -f --check-function-docs`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md). Additional invocations: [common-individual-commands.md](references/common-individual-commands.md) (read on debugging).
