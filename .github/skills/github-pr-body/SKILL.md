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

- ## Overview section: Auto-generated summary of PR purpose
- ## Changes section: File change list by classification (Config, Docs, Feature, Test, Other)
- Each file entry: Filename + line changes (+X / -Y lines)
- Summary subsection: Total file count and line changes
- Other sections (Related Issues, Testing, Deployment Notes, Breaking Changes): Preserved from original

Overview generation policy (deterministic):

- Generate metadata-only baseline (`Title`, `Branch`, `Stats`) when using script alone
- **For manual/AI refinement**: Focus on change summary, exclude metadata
  - ❌ Exclude: Branch names, file counts, line counts (visible in GitHub UI)
  - ✅ Include: What was changed, why it's necessary, what improves
- Keep script output deterministic and template-tolerant
- Do not generate narrative reasoning (`why`, `risk`) in script logic
- Add domain or release-risk context only during manual refinement

See "Output Format" section for example output.

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Use `scripts/pr_body.sh <PR_NUMBER>` to update PR Body sections
- Script fetches PR details, generates Overview/Changes sections, and updates PR Body
- **Alternative**: Use `scripts/pr_fetch.sh <PR_NUMBER>` for read-only PR information retrieval
- **GitKraken MCP**: Available on explicit request for alternative GitHub API access

**What this skill does**:

- Auto-generate ## Overview section in PR Body
- Auto-generate ## Changes section in PR Body
- Generate file classifications and statistics
- Preserve existing other sections

What this skill does NOT do (Out of Scope):

- Modify other PR Body sections (Related Issues, Testing, Deployment Notes, Breaking Changes)
- Perform PR merge operations
- Approve PR reviews
- Modify file contents
- Automatically use GitKraken MCP (only on explicit request)
- Execute individual `gh` commands (except for debugging)
- Add language-specific or domain-specific narratives directly in script logic

Domain-specific enrichment policy:

- Keep `pr_body.sh` generic and deterministic
- Use external review skills/agents for domain-specific analysis
- Apply those insights through manual refinement of PR Body after running `pr_body.sh`

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

## Failure Behavior

Error handling:

- Invalid PR number: Output error message and exit, do not modify PR Body
- Authentication error: Output message prompting GitHub CLI authentication and exit
- Missing PR Body: Output error message and exit
- Script execution error: Output error details, rollback partial changes
- --dry-run mode: Preview changes only, do not update PR Body

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
Step 2: pr_body.sh (OPTIONAL)
     ↓ Auto-generates ## Overview and ## Changes
     ↓ Preserves all other sections
     ↓
Step 3: Manual Refinement (OPTIONAL)
     ↓ AI Agent or human refines content
```

### Quick Commands

```bash
# Step 1: Analyze PR (Required, outputs JSON)
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR_NUMBER> --repo owner/repo

# Step 2: Apply changes (updates PR Body)
.github/skills/github-pr-body/scripts/pr_body.sh <PR_NUMBER> --repo owner/repo

# Step 2 (Alternative): With AI-generated Overview content
.github/skills/github-pr-body/scripts/pr_body.sh <PR_NUMBER> --repo owner/repo --overview-file /tmp/overview.md
```

### Idempotent Execution

| Section              | Behavior        | Details                                                                      |
| -------------------- | --------------- | ---------------------------------------------------------------------------- |
| `## Overview`        | Always replaced | Auto-generated from PR metadata on each run                                  |
| `## Changes`         | Always replaced | Auto-generated from file analysis on each run                                |
| All other sections   | Preserved       | Never modified (Related Issues, Testing, Deployment Notes, Breaking Changes) |
| **Multi-run safety** | ✅ Safe         | Same output on every execution, no markers needed                            |

### AI Agent Follow-up

After Step 1 or Step 2, AI Agent can:

- Review auto-generated content for accuracy
- Add context-specific details to Overview
- Enhance Changes section with domain-specific notes
- Update Testing or other sections with validation results

**Key principle**: Steps 1-2 are deterministic and safe to re-run. Manual refinement in Step 3 is preserved across re-runs for non-auto-generated sections.

## Tool Priority

**Use scripts in this order:**

1. **`pr_fetch.sh`** - Start here for any PR analysis
   - ✅ Unified PR data retrieval in single call
   - ✅ All metadata, file classifications, template sections included
   - 🎯 **Recommended for AI Agents** before analysis or body updates

2. **`pr_body.sh`** - Use after `pr_fetch.sh` to update Body
   - ✅ Auto-generates `## Overview` and `## Changes`
   - ✅ Calls `pr_fetch.sh` internally
   - ✅ Preserves all other template sections
   - ✅ Accepts `--overview-file` for AI-generated Overview content (optional)
   - ⏱️ More resource-intensive (rewrites entire Body)

3. **Individual `gh` commands** - Avoid (use only for debugging)
   - ❌ Multiple separate calls needed
   - ❌ Risk of inconsistent or stale data
   - ❌ Manual error handling required

4. **GitKraken MCP** - Optional only if explicitly requested
   - ⚠️ Requires separate authentication
   - ⚠️ Not guaranteed available

**⚠️ Critical Rule**: Always use `pr_fetch.sh` or `pr_body.sh`. Never use individual `gh` commands unless debugging.

## Output Format

**Updated PR Body Structure:**

```markdown
## Overview

**Title**: [PR title]

**Branch**: [head] -> [base]

**Stats**: [N files changed (+A / -D lines)]

## Changes

[Auto-generated file list by classification]

### Config

- **file1.yaml**: +10 / -5 lines
- **file2.tf**: +20 / -3 lines

### Docs

- **README.md**: +15 / -2 lines

**Summary**: 3 files changed (+45 / -10 lines)

## Related Issues

[Preserved from previous run]

## Testing

[Preserved from previous run]

## Type of Change

[Preserved from previous run]

## Checklist

[Preserved from previous run]

## Additional Notes

[Preserved from previous run]
```

**Key Points:**

- Starts directly with `## Overview` (no top-level `# Overview` header)
- Contains auto-generated `## Overview` section (from PR metadata)
- Contains auto-generated `## Changes` section (from file analysis)
- All other sections preserved below `## Changes`

## Usage Scenarios

### Initial PR Creation

```bash
# After opening PR with template filled
.github/skills/github-pr-body/scripts/pr_body.sh 123 --repo owner/repo

# Result: ## Overview and ## Changes populated automatically
```

### Workflow Examples

For complete workflow scenarios, see **[Agent Workflows](reference/category-agent-workflows.md)** (Japanese scenarios included).

## Summary

**Purpose**: Auto-populate PR Body `## Overview` and `## Changes` sections based on PR metadata and file analysis.

**Quick Command**: `.github/skills/github-pr-body/scripts/pr_body.sh <PR#> --repo owner/repo`

**Result**: PR Body sections auto-generated and ready for manual refinement if needed.
