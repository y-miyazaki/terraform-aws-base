---
name: markdown-validation
description: >-
  Validate Markdown syntax, formatting, and links using markdownlint-cli2 and markdown-link-check.
  Use when committing docs changes, checking broken links, or validating Markdown in pull requests.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.1"
---

## Input

- Markdown path or glob (required): `.md` files to validate
- Validation script (required): `scripts/validate.sh` (run from this skill directory)
- markdownlint-cli2 config (optional)
- markdown-link-check config (optional)
- File pattern (optional): defaults to target path glob
## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Structured validation results from two tools: markdownlint-cli2 → markdown-link-check.

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

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)

## Workflow

1. Run `bash scripts/validate.sh` (or `bash scripts/validate.sh <path>` for scoped validation).
2. Parse script output and map results to checklist ItemIDs.
3. Report failed/deferred items per [references/common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                                    | Severity    | Action                                                                                                |
| -------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `scripts/validate.sh` missing                | Fatal       | Stop; report missing script                                                                           |
| No `.md` files under target path             | Info        | Report no reviewable markdown; stop                                                                   |
| markdownlint-cli2 or link-check tool missing | Recoverable | Defer checks for that tool; note in deferred table                                                    |
| External link timeout or transient network   | Recoverable | Defer link-check item; note network-only failure                                                      |
| Single tool fails, other succeeds            | Recoverable | Report passing tool; defer failed tool with exit status                                               |
| All tools fail                               | Fatal       | Return `status: failed` with per-tool stderr summaries                                                |
| `common-checklist.md` unavailable            | Fatal       | Stop; report missing dependency                                                                       |
| `common-output-format.md` unavailable        | Recoverable | Note missing file; emit `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` only |

### Examples

- Prompt: `Validate Markdown files and report only failed checks`
- Command: `bash scripts/validate.sh ./docs/`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); defer network-only link failures.
