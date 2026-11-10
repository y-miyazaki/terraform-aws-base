---
name: github-pr-body
description: >-
  Update PR body content with deterministic baseline sections and optional full-body completion.
  Use after a PR exists to fill or regenerate its body from the repository PR template.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.2"
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
- `## Changes` is script-generated: files grouped by Config/Docs/Feature/Test/Other with line counts.
- Report selected mode and reason.

## Execution Scope

- **Always use `scripts/pr_body.sh` or `scripts/pr_fetch.sh`** to read and write the PR body. Do not run other `gh` commands, except read-only `gh pr view` for verification (Step 6).
- `pr_body.sh` is deterministic and idempotent.
- `scripts/pr_comment.sh` (PR overview comment) is not part of this workflow; do not use it to deliver the PR body.

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
- [category-pr-body-guidelines.md](references/category-pr-body-guidelines.md) (read when full-body mode)
- [category-template-mapping.md](references/category-template-mapping.md) (read when full-body mode)
- [category-change-classification.md](references/category-change-classification.md) (read when the template has a Type of Change section in full-body mode)
- [category-command-reference.md](references/category-command-reference.md) (read on debugging)
- [category-implementation-details.md](references/category-implementation-details.md) (read on debugging)
- [category-agent-workflows.md](references/category-agent-workflows.md) (read on debugging)

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

   1. Read [category-pr-body-guidelines.md](references/category-pr-body-guidelines.md). Read [category-template-mapping.md](references/category-template-mapping.md) when template comment guidance is ambiguous.
   2. Read `.github/PULL_REQUEST_TEMPLATE.md` from the repository — the only template location `pr_body.sh` reads (root, `docs/`, and multi-template directories are not read).
   3. For each H2 section in the template:
      - If the section comment contains an `Example:` block, follow that structure to generate visible content.
      - If the section comment contains checkbox guidance, generate or update checkbox lines in the same format.
      - If the section has no guidance, preserve the section heading and template comment without inventing content.
   4. Replace the metadata-only `## Overview` from Step 2 with a narrative Overview in the format of [category-pr-body-guidelines.md](references/category-pr-body-guidelines.md) § Overview Format (2–4 sentence paragraph plus `Core Fixes:`, `Scope:`, and `Risk / Deployment Note:` bullets); keep `## Changes` from Step 2 output.
   5. Write the complete PR body (all sections) to a temporary file (e.g., `/tmp/completed_pr_body.md`).

5. Apply full body (full-body mode only):

   ```bash
   scripts/pr_body.sh <PR_NUMBER> --repo <OWNER/REPO> --body-file /tmp/completed_pr_body.md
   ```

6. Verify success:
   ```bash
   gh pr view <PR_NUMBER> --repo <OWNER/REPO> --json body --jq '.body'
   ```
   Confirm `## Overview` and `## Changes` sections are present and non-empty. In full-body mode, confirm every template H2 that carries guidance comments or examples contains visible content (e.g. `## Testing`, `## Checklist`).

### Error Handling

| Condition                                  | Severity    | Action                                                                                                                                                        |
| ------------------------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `gh` not authenticated                     | Fatal       | Stop; instruct `gh auth login`                                                                                                                                |
| PR not found (404)                         | Fatal       | Verify PR number and `owner/repo`                                                                                                                             |
| Access denied (403)                        | Fatal       | Verify `repo` write scope                                                                                                                                     |
| `pr_fetch.sh` or `pr_body.sh` missing      | Fatal       | Stop; report missing script                                                                                                                                   |
| `.github/PULL_REQUEST_TEMPLATE.md` missing | Fatal       | Stop; the baseline run (Step 2, which both modes start with) exits with "Template file not found" — report it; `--body-file` alone does not read the template |
| Body exceeds GitHub size limit (422)       | Recoverable | Truncate or split content; report in output                                                                                                                   |
| Rate limit exceeded (429)                  | Recoverable | Defer update; note retry window in report                                                                                                                     |
| Dry-run output unacceptable                | Info        | Do not apply; report diff issues and stop                                                                                                                     |

### Examples

- Prompt: `Generate PR body for PR #42`
- Result: PR body updated via `scripts/pr_body.sh`; report mode and reason per [references/common-output-format.md](references/common-output-format.md).
