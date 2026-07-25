---
name: shell-script-validation
description: >-
  Validate shell scripts with bash -n and shellcheck for syntax safety and maintainability checks.
  Does not enforce Bats suite pairing (TEST-00) — run `bats` and shell-script-review for that.
  Use when committing script changes, running CI validation, or debugging shellcheck findings in PRs.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.2.1"
---

## Input

- Shell script path or directory (optional; defaults to workspace root)
- Validation script: `scripts/validate.sh` (required)
- Canonical flags: `-v -f -d` (always pass all three unless opted out below)
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
- normalize function doc section order when this skill ships `scripts/fix_function_doc_order.sh`

### DO NOT USE FOR:

- perform architecture/design review of shell scripts
- modify business logic in scripts as a primary task
- validate non-shell files
- enforce Bats suite pairing or suite layout (use `bats` and shell-script-review)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)
- [category-standards.md](references/category-standards.md) (read on failure)

## Workflow

1. Run `bash scripts/validate.sh -v -f -d` with an optional target path (file or directory under review).
2. When function doc sections are out of order and `scripts/fix_function_doc_order.sh` exists, run it on the target before re-validating.
3. Review auto-fix diffs from `-f` before continuing.
4. If checks fail, fix reported issues and rerun the same command.
5. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Error Handling

| Condition                             | Severity    | Action                                                    |
| ------------------------------------- | ----------- | --------------------------------------------------------- |
| `scripts/validate.sh` missing         | Fatal       | Stop; report missing script                               |
| No shell scripts under target path    | Info        | Report no reviewable scripts; stop                        |
| bash -n or shellcheck missing         | Recoverable | Defer checks for that tool; note in deferred table        |
| Single tool fails, other succeeds     | Recoverable | Report passing tool; defer failed tool with exit status   |
| All tools fail                        | Fatal       | Return `status: failed` with per-tool stderr summaries    |
| Function docs intentionally skipped   | Info        | Omit `--check-function-docs`; document opt-out in Summary |
| `common-checklist.md` unavailable     | Fatal       | Stop; report missing dependency                           |
| `common-output-format.md` unavailable | Recoverable | Use inline output contract                                |

### Examples

```bash
# Canonical (workspace-wide)
bash scripts/validate.sh -v -f -d

# Scoped (single script)
bash scripts/validate.sh -v -f -d ./path/to/script.sh

# Reorder function doc sections when the skill ships the helper
bash scripts/fix_function_doc_order.sh ./path/to/script.sh

# Opt-out: skip function doc sections when intentionally not applicable
bash scripts/validate.sh -v -f ./path/to/script.sh
```
