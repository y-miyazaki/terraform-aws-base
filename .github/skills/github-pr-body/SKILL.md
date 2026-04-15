---
name: github-pr-body
description: Automated PR Body section updater. Always use pr_fetch.sh or pr_body.sh scripts. Updates PR Body sections (## Overview, ## Changes) with auto-generated content. Generates structured, idempotent updates that preserve other template sections.
license: MIT
---

## Purpose

Automatically updates PR Body sections with generated content analyzing PR purpose, scope, and specific changes.

Automated workflow for updating PR Body sections with comprehensive analysis of PR purpose, scope, and specific changes.

## When to Use This Skill

Recommended usage:

- One-time execution after PR creation to populate auto-generated sections in Body
- Ensure consistency of ## Overview and ## Changes sections in PR Body
- Provide AI Agent with baseline PR analysis before manual review

## Input Specification

This skill expects:

- GitHub PR number (required)
- Repository information in owner/repo format (required)
- Existing PR Body with PULL_REQUEST_TEMPLATE.md structure (required)
- Authenticated GitHub CLI environment (required)

Format:

- PR number: Integer value
- Repository: String in "owner/repo" format
- PR Body: Markdown format containing ## Overview and ## Changes sections

## Output Specification

Structured Markdown format PR Body:

- Deterministic baseline PR Body reconstructed from PULL_REQUEST_TEMPLATE.md section order
- ## Overview section: Auto-generated summary of PR purpose when `--overview-file` is omitted, or caller-provided AI content when `--overview-file` is passed
- ## Changes section: File change list by classification (Config, Docs, Feature, Test, Other)
- Each file entry: Filename + line changes (+X / -Y lines)
- Summary subsection: Total file count and line changes
- All other sections: Existing visible content preserved; empty sections restored from template structure and comments for later AI completion

Overview generation policy (deterministic):

- Generate metadata-only baseline (`Title`, `Branch`, `Stats`) when using script alone
- **For AI completion**: Read each section comment in `PULL_REQUEST_TEMPLATE.md`, follow any Example or checklist guidance, and generate section content that matches that format
- **For manual/AI refinement**: Focus on change summary, exclude metadata
  - ❌ Exclude: Branch names, file counts, line counts (visible in GitHub UI)
  - ✅ Include: What was changed, why it's necessary, what improves
- Keep script output deterministic and template-tolerant
- Do not generate narrative reasoning (`why`, `risk`) in script logic
- Add domain or release-risk context only during AI completion or manual refinement

See "Output Format" section for example output.

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Use `scripts/pr_body.sh <PR_NUMBER>` to update PR Body sections
- Script fetches PR details, generates Overview/Changes sections, and updates PR Body
- **Alternative**: Use `scripts/pr_fetch.sh <PR_NUMBER>` for read-only PR information retrieval
- **GitKraken MCP**: Available on explicit request for alternative GitHub API access

**What this skill does**:

- Fetch PR metadata and current PR Body template structure
- Rebuild PR Body deterministically from template section order
- Auto-generate deterministic baseline for ## Overview and ## Changes
- Preserve existing visible content in other sections
- Keep empty sections available for later AI completion based on template comments

What this skill does NOT do (Out of Scope):

- Generate semantic content for non-deterministic sections inside `pr_body.sh`
- Perform PR merge operations
- Approve PR reviews
- Modify file contents
- Automatically use GitKraken MCP (only on explicit request)
- Execute individual `gh` commands (except for debugging)
- Add language-specific or domain-specific narratives directly in script logic
- Infer chapter meaning without reading `PULL_REQUEST_TEMPLATE.md` comments during AI completion

Domain-specific enrichment policy:

- Keep `pr_body.sh` generic and deterministic
- Use AI completion or external review skills/agents for semantic analysis
- Apply those insights after running `pr_body.sh` and before the final PR Body save step

## Constraints

Prerequisites:

- GitHub CLI (`gh`) installed and authenticated
- Existing PR Body has `##` section structure
- Write permission to repository
- Scripts exist at `.github/skills/github-pr-body/scripts/`

Limitations:

- GitKraken MCP requires separate authentication and availability is not guaranteed
- Large file changes (>1000 files) may result in longer execution time
- PR file lists are fetched with pagination; large PRs can take longer but are not truncated
- AI completion quality depends on clear guidance comments and Examples in `PULL_REQUEST_TEMPLATE.md`

## Failure Behavior

Error handling:

- Invalid PR number: Output error message and exit, do not modify PR Body
- Authentication error: Output message prompting GitHub CLI authentication and exit
- Missing PR Body: Output error message and exit
- Script execution error: Output error details, rollback partial changes
- --dry-run mode: Preview changes only, do not update PR Body
- AI completion gap: Preserve deterministic baseline and leave unresolved sections for manual follow-up when template guidance is missing or ambiguous

Error reporting format:

- Error messages to standard error output
- Exit code: 0=success, 1=error
- Error details available in reference/troubleshooting.md

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - PR Overview update workflow checklist
- **common-output-format.md** - Output format definition
- **common-troubleshooting.md** - Common issues and solutions

**Category Details**:

- **category-command-reference.md** - Command parameters, options, error codes
- **category-change-classification.md** - File type classification rules
- **category-agent-workflows.md** - Real-world usage scenarios and workflows
- **category-pr-body-guidelines.md** - PR Body manual writing guidelines
- **category-implementation-details.md** - Technical implementation details
- **category-template-mapping.md** - Template structure mapping

## Workflow

**Always use the provided scripts. Do not run individual `gh` commands.**

### Execution Flow

```
Step 1: pr_fetch.sh (REQUIRED)
     ↓ Analyzes PR metadata, file classifications
     ↓ Outputs JSON with all PR data
     ↓
Step 2: pr_body.sh (REQUIRED for baseline generation)
     ↓ Rebuilds PR Body in template order
     ↓ Auto-generates deterministic baseline for ## Overview and ## Changes
     ↓ Preserves other visible sections and template guidance comments
     ↓
Step 3: AI Completion (RECOMMENDED)
     ↓ Read each section comment in PULL_REQUEST_TEMPLATE.md
     ↓ Use Example / checklist guidance to generate content for required chapters
     ↓ Save completed chapter content to files or direct body update input
     ↓
Step 4: Manual Review or Final Apply (OPTIONAL)
     ↓ Human reviews AI-completed body, then applies or adjusts as needed
```

### Quick Commands

```bash
# Step 1: Analyze PR (Required, outputs JSON)
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR_NUMBER> --repo owner/repo

# Step 2: Generate deterministic baseline (updates PR Body)
.github/skills/github-pr-body/scripts/pr_body.sh <PR_NUMBER> --repo owner/repo

# Step 3: Re-apply with AI-generated Overview content
.github/skills/github-pr-body/scripts/pr_body.sh <PR_NUMBER> --repo owner/repo --overview-file /tmp/overview.md
```

### Idempotent Execution

| Section              | Behavior            | Details                                                                                             |
| -------------------- | ------------------- | --------------------------------------------------------------------------------------------------- |
| `## Overview`        | Always replaced     | Deterministic baseline from PR metadata, or caller-provided AI content via `--overview-file`        |
| `## Changes`         | Always replaced     | Auto-generated from file analysis on each run                                                       |
| All other sections   | Preserve or restore | Preserve existing visible content; restore template comments/structure for AI completion when empty |
| **Multi-run safety** | ✅ Safe             | Same output on every execution, no markers needed                                                   |

### AI Completion Step

After Step 2, AI completion must:

- Read each section comment in `PULL_REQUEST_TEMPLATE.md`
- Determine whether the section requires visible content
- Follow `Example:` or checkbox guidance when present
- Generate content that matches the section-specific format
- Keep sections empty only when template guidance is absent or explicitly optional

**Key principle**: Steps 1-2 are deterministic and safe to re-run. Semantic interpretation belongs to Step 3, not to shell scripts.

## Tool Priority

**Use scripts in this order:**

1. **`pr_fetch.sh`** - Start here for any PR analysis
   - ✅ Unified PR data retrieval in single call
   - ✅ All metadata, file classifications, template sections included
   - 🎯 **Recommended for AI Agents** before analysis or body updates

2. **`pr_body.sh`** - Use after `pr_fetch.sh` to update Body
   - ✅ Rebuilds template-ordered deterministic baseline
   - ✅ Auto-generates `## Overview` and `## Changes`
   - ✅ Calls `pr_fetch.sh` internally
   - ✅ Preserves all other template sections and comments
   - ✅ Accepts `--overview-file` for AI-generated Overview content (optional)
   - ⏱️ More resource-intensive (rewrites entire Body)

3. **AI completion step** - Use after `pr_body.sh` to fill chapter content semantically
   - ✅ Reads section guidance from `PULL_REQUEST_TEMPLATE.md`
   - ✅ Generates section content that follows Example / checklist format
   - ✅ Handles chapter meaning and domain-specific wording
   - ❌ Must not be embedded into deterministic shell script logic

4. **Individual `gh` commands** - Avoid (use only for debugging)
   - ❌ Multiple separate calls needed
   - ❌ Risk of inconsistent or stale data
   - ❌ Manual error handling required

5. **GitKraken MCP** - Optional only if explicitly requested
   - ⚠️ Requires separate authentication
   - ⚠️ Not guaranteed available

**⚠️ Critical Rule**: Always use `pr_fetch.sh` or `pr_body.sh`. Never use individual `gh` commands unless debugging.

## Output Format

**Updated PR Body Structure:**

```markdown
## Overview

[Template guidance comments preserved]

[AI-completed or baseline overview]

## Related Issues

[AI-completed section based on template guidance]

## Changes

[Template guidance comments preserved]

[Auto-generated file list by classification]

### Config

- **file1.yaml**: +10 / -5 lines
- **file2.tf**: +20 / -3 lines

### Docs

- **README.md**: +15 / -2 lines

**Summary**: 3 files changed (+45 / -10 lines)

## Testing

[AI-completed section based on template guidance]

## Type of Change

[AI-completed or reviewer-checked checkboxes]

## Checklist

[AI-completed or reviewer-checked checkboxes]

## Additional Notes

[AI-completed section when relevant]
```

**Key Points:**

- Starts directly with `## Overview` (no top-level `# Overview` header)
- Contains deterministic baseline `## Overview` and `## Changes`
- Preserves template comments for later AI completion
- Expects AI completion to fill other chapters according to template guidance

## Usage Scenarios

### Initial PR Creation

```bash
# After opening PR with template filled
.github/skills/github-pr-body/scripts/pr_body.sh 123 --repo owner/repo

# Then run AI completion using the template comments as guidance
# Result: deterministic baseline followed by AI-completed chapter content
```

### Workflow Examples

For complete workflow scenarios, see **[Agent Workflows](reference/category-agent-workflows.md)** (Japanese scenarios included).

## Summary

**Purpose**: Auto-populate PR Body `## Overview` and `## Changes` sections based on PR metadata and file analysis.

**Quick Command**: `.github/skills/github-pr-body/scripts/pr_body.sh <PR#> --repo owner/repo`

**Result**: PR Body baseline generated deterministically; chapter-level semantic completion handled by AI using template guidance.
