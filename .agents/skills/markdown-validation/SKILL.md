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

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)

## Workflow

1. Run `bash scripts/validate.sh` (or `bash scripts/validate.sh <path>` for scoped validation).
2. Parse script output and map results to checklist ItemIDs.
3. Report failed/deferred items per [references/common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                                    | Severity    | Action                                                  |
| -------------------------------------------- | ----------- | ------------------------------------------------------- |
| `scripts/validate.sh` missing                | Fatal       | Stop; report missing script                             |
| No `.md` files under target path             | Info        | Report no reviewable markdown; stop                     |
| markdownlint-cli2 or link-check tool missing | Recoverable | Defer checks for that tool; note in deferred table      |
| External link timeout or transient network   | Recoverable | Defer link-check item; note network-only failure        |
| Single tool fails, other succeeds            | Recoverable | Report passing tool; defer failed tool with exit status |
| All tools fail                               | Fatal       | Return `status: failed` with per-tool stderr summaries  |
| `common-checklist.md` unavailable            | Fatal       | Stop; report missing dependency                         |
| `common-output-format.md` unavailable        | Recoverable | Use inline output contract                              |

### Examples

- Prompt: `Validate Markdown files and report only failed checks.`
- Command: `bash scripts/validate.sh ./docs/`
- Output: per-tool results with deferred status for network-only link failures.
