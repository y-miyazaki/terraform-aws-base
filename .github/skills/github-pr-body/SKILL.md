---
name: github-pr-body
description: >-
  Updates PR Body sections (## Overview, ## Changes) with auto-generated content analyzing PR
  purpose, scope, and file changes. Generates structured, idempotent updates that preserve other
  template sections. Use when creating a PR, populating PR body sections, or regenerating change summaries.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- GitHub PR number (required)
- Repository in `owner/repo` format (required)
- Existing PR Body with `PULL_REQUEST_TEMPLATE.md` structure (required)
- Authenticated GitHub CLI (`gh`) environment (required)

## Output Specification

Structured Markdown PR Body:

- `## Overview`: Auto-generated baseline from PR metadata, or caller-provided AI content via `--overview-file`
- `## Changes`: File change list by classification (Config, Docs, Feature, Test, Other) with line counts
- All other sections: Existing visible content preserved; empty sections restored from template for AI completion
- Overview excludes metadata visible in GitHub UI (branch names, file counts); includes what changed and why

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/pr_body.sh` or `scripts/pr_fetch.sh`**. Do not run individual `gh` commands.
- `pr_body.sh` is deterministic and idempotent — safe to re-run
- Semantic interpretation (AI completion of chapters) belongs to Step 3, not to shell scripts
- **Do not use GitKraken MCP** unless explicitly requested

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - PR update workflow checklist
- [common-output-format.md](references/common-output-format.md) - Output format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when scripts fail or produce unexpected output

**Category Details** (read when needed):

- [category-command-reference.md](references/category-command-reference.md) - Read when checking command parameters, options, or error codes
- [category-change-classification.md](references/category-change-classification.md) - Read when file type classification is incorrect
- [category-agent-workflows.md](references/category-agent-workflows.md) - Read when setting up end-to-end PR workflows
- [category-pr-body-guidelines.md](references/category-pr-body-guidelines.md) - Read when writing PR body content manually
- [category-implementation-details.md](references/category-implementation-details.md) - Read when debugging script internals
- [category-template-mapping.md](references/category-template-mapping.md) - Read when template sections are not mapped correctly

## Workflow

**Always use the provided scripts. Do not run individual `gh` commands.**

```
Step 1: pr_fetch.sh → Analyzes PR metadata, outputs JSON
Step 2: pr_body.sh  → Rebuilds PR Body with deterministic baseline
Step 3: AI Completion (recommended) → Fill chapters using template guidance
Step 4: Manual Review (optional) → Human reviews and adjusts
```

### Quick Commands

```bash
# Step 1: Analyze PR (outputs JSON)
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR_NUMBER> --repo owner/repo

# Step 2: Generate deterministic baseline (updates PR Body)
.github/skills/github-pr-body/scripts/pr_body.sh <PR_NUMBER> --repo owner/repo

# Step 3: Re-apply with AI-generated Overview content
.github/skills/github-pr-body/scripts/pr_body.sh <PR_NUMBER> --repo owner/repo --overview-file /tmp/overview.md
```

### Idempotent Execution

| Section | Behavior | Details |
|---|---|---|
| `## Overview` | Always replaced | Deterministic baseline or `--overview-file` content |
| `## Changes` | Always replaced | Auto-generated from file analysis on each run |
| All other sections | Preserve or restore | Preserve visible content; restore template for empty sections |

### AI Completion Step

After Step 2, AI completion must:

- Read each section comment in `PULL_REQUEST_TEMPLATE.md`
- Follow `Example:` or checkbox guidance when present
- Generate content matching the section-specific format
- Keep sections empty only when template guidance is absent

**Key principle**: Steps 1-2 are deterministic. Semantic interpretation belongs to Step 3.

## Output Format

```markdown
## Overview

[AI-completed or baseline overview]

## Changes

### Config

- **file1.yaml**: +10 / -5 lines
- **file2.tf**: +20 / -3 lines

### Docs

- **README.md**: +15 / -2 lines

**Summary**: 3 files changed (+45 / -10 lines)
```

## Best Practices

- Always start with `pr_fetch.sh`, then `pr_body.sh`
- Never use individual `gh` commands unless debugging
- Steps 1-2 are safe to re-run (idempotent)
- For workflow examples, see [references/category-agent-workflows.md](references/category-agent-workflows.md)
