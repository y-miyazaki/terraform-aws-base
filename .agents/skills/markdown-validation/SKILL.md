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

- Path (optional): one `.md` file or a directory to scan recursively; defaults to the current directory (globs are not accepted)
- Validation script: `<skill-dir>/scripts/validate.sh`, run with the repository root as the working directory
- markdownlint-cli2 config (optional): discovered by markdownlint-cli2 from the working directory
- markdown-link-check config (optional): `.markdown-link-check.json` in the working directory

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Structured validation results from two tools: markdownlint-cli2 → markdown-link-check.

## Execution Scope

- **Always use `scripts/validate.sh`** for the pass/fail result. Run individual tool commands only to get details for a tool the script reported as failed (Workflow step 2).
- Script runs markdownlint-cli2, then markdown-link-check; both run even when the first fails. Link checking stops at the first file with a broken link.
- **Do not modify Markdown files.**
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
- [common-individual-commands.md](references/common-individual-commands.md) (read on debugging)

## Workflow

1. From the repository root, run `bash <skill-dir>/scripts/validate.sh [path]` (omit `path` to scan the whole working directory).
2. For each failed tool, get details per [common-individual-commands.md](references/common-individual-commands.md): re-run `markdownlint-cli2 <files>` (the script hides its output), and re-run `markdown-link-check` on every target file (the script stops at the first broken file, so later files are unchecked). Map rule IDs and broken links to checklist ItemIDs and prefix each finding in `## Error Details` with its ItemID, so the report names which checklist item failed.
3. Report failed/skipped tools per [references/common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                                    | Severity    | Action                                                                                         |
| -------------------------------------------- | ----------- | ---------------------------------------------------------------------------------------------- |
| `scripts/validate.sh` missing                | Fatal       | Stop; report missing script                                                                    |
| No `.md` files under target path             | Info        | Report both tools as `⊘ Skipped` (no `.md` files) in `## Tool Results`; Status ✅ PASS; stop   |
| markdownlint-cli2 or link-check tool missing | Recoverable | Report that tool as skipped in `## Tool Results`                                               |
| External link timeout or transient network   | Recoverable | Report the link-check failure; note in `## Error Details` that it is network-only              |
| Single tool fails, other succeeds            | Recoverable | Report both tools in `## Tool Results`; include the failed tool's output in `## Error Details` |
| All tools fail                               | Fatal       | `Status: ❌ FAIL` with per-tool output in `## Error Details`                                   |
| `common-checklist.md` unavailable            | Fatal       | Stop; report missing dependency                                                                |
| `common-output-format.md` unavailable        | Recoverable | Note missing file; emit `## Summary`, `## Tool Results`, and `## Error Details` only           |

### Examples

- Prompt: `Validate the Markdown files under docs/`
- Command (from the repository root): `bash <skill-dir>/scripts/validate.sh docs/`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); mark network-only link failures as such in `## Error Details`.
