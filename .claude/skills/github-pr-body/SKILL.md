---
name: github-pr-body
description: >-
  Update PR body content with deterministic baseline sections and optional full-body completion.
  Use when creating PRs or regenerating template-driven summaries.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.1"
---

## Input

- PR number and `owner/repo` (required)
- Existing PR template/body context (required)
- Authenticated `gh` environment (required)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured PR output:

- Baseline mode: update `## Overview` and `## Changes`.
- Full-body mode: apply complete body via `--body-file`.
- `## Changes` must classify files (Config/Docs/Feature/Test/Other) with line counts.
- Report selected mode and reason.

## Execution Scope

- **Always use `scripts/pr_body.sh` or `scripts/pr_fetch.sh`**. Do not run individual `gh` commands.
- `pr_body.sh` is deterministic and idempotent.

### USE FOR:

- generate deterministic baseline PR body sections
- regenerate PR body from template sections after code updates
- fill remaining sections in full-body mode from validated context

### DO NOT USE FOR:

- post review comments or resolve review threads
- create commits or modify source files
- replace issue triage workflows

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-change-classification.md](references/category-change-classification.md) (always read)
- [category-pr-body-guidelines.md](references/category-pr-body-guidelines.md) (always read)
- [category-agent-workflows.md](references/category-agent-workflows.md) (always read)
- [category-implementation-details.md](references/category-implementation-details.md) (always read)

## Workflow

1. Fetch PR metadata:

   ```bash
   scripts/pr_fetch.sh <PR_NUMBER> --repo <OWNER/REPO>
   ```

   Parse JSON output to obtain: title, body, file list, additions/deletions, headRefName, baseRefName.

2. Generate deterministic baseline (`## Overview`, `## Changes`):

   ```bash
   scripts/pr_body.sh <PR_NUMBER> --repo <OWNER/REPO> --dry-run
   ```

   Review dry-run output. If acceptable, apply:

   ```bash
   scripts/pr_body.sh <PR_NUMBER> --repo <OWNER/REPO>
   ```

3. Select mode:

   - Baseline mode: request scope is summary refresh only → skip to Step 6.
   - Full-body mode: request explicitly asks to populate all template sections → continue to Step 4.

4. Generate AI-completed content (full-body mode only):

   1. Read `.github/PULL_REQUEST_TEMPLATE.md` from the repository.
   2. For each H2 section in the template:
      - If the section comment contains an `Example:` block, follow that structure to generate visible content.
      - If the section comment contains checkbox guidance, generate or update checkbox lines in the same format.
      - If the section has no guidance, preserve the section heading and template comment without inventing content.
   3. Keep `## Overview` and `## Changes` content from Step 2 output.
   4. Write the complete PR body (all sections) to a temporary file (e.g., `/tmp/completed_pr_body.md`).

5. Apply full body (full-body mode only):

   ```bash
   scripts/pr_body.sh <PR_NUMBER> --repo <OWNER/REPO> --body-file /tmp/completed_pr_body.md
   ```

6. Verify success:
   ```bash
   gh pr view <PR_NUMBER> --repo <OWNER/REPO> --json body --jq '.body'
   ```
   Confirm `## Overview` and `## Changes` sections are present and non-empty. In full-body mode, confirm `## Testing`, `## Type of Change`, `## Checklist`, and `## Additional Notes` contain visible content.

### Error Handling

| Condition                                  | Severity    | Action                                               |
| ------------------------------------------ | ----------- | ---------------------------------------------------- |
| `gh` not authenticated                     | Fatal       | Stop; instruct `gh auth login`                       |
| PR not found (404)                         | Fatal       | Verify PR number and `owner/repo`                    |
| Access denied (403)                        | Fatal       | Verify `repo` write scope                            |
| `pr_fetch.sh` or `pr_body.sh` missing      | Fatal       | Stop; report missing script                          |
| `.github/PULL_REQUEST_TEMPLATE.md` missing | Recoverable | Baseline mode only; skip full-body template sections |
| Body exceeds GitHub size limit (422)       | Recoverable | Truncate or split content; report in output          |
| Rate limit exceeded (429)                  | Recoverable | Defer update; note retry window in report            |
| Dry-run output unacceptable                | Info        | Do not apply; report diff issues and stop            |

### Examples

- Prompt: `Generate PR body for PR #42 in owner/repo`
- Result: PR description populated with Overview, Changes, Testing, and Checklist sections from diff analysis.
