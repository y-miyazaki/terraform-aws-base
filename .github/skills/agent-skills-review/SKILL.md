---
name: agent-skills-review
description: >
  SKILL.md files review for structural requirements, quality standards, and design patterns.
  Use for manual review of .github/skills/*/SKILL.md files checking content quality, specification completeness, and implementation feasibility.
   Focus on manual checks that require human/AI judgment.
license: MIT
---

## Purpose

Reviews SKILL.md files for structural requirements, quality standards, and design patterns to ensure skill quality, specification completeness, implementation feasibility, and consistency with established review skill patterns.

## When to Use This Skill

**Recommended usage**:

- New SKILL.md creation - quality assurance
- SKILL.md modification/update - change quality validation
- Pull request review - for agent skills-related PRs
- Skill governance audit - batch quality check for multiple skills
- Agent Skills standardization initiatives

## Input Specification

This skill expects:

- **SKILL.md file** (required) - Target file to review (.github/skills/\*/SKILL.md)
- **agent-skills.instructions.md** (required) - Validation criteria reference (included in this skill's references)
- **PR description and skill overview context** (recommended) - Understanding of skill purpose and target background

Format:

- SKILL.md: Markdown with YAML front matter (name, description, license)
- Reference files: Category-specific Markdown (detailed criteria)

## Output Specification

Structured markdown review report:

```markdown
# Review Result: <SKILL_NAME>

## Execution Scope

**How to use this skill**:

- This skill provides manual review guidance requiring human/AI judgment
- Reviewer reads SKILL.md files and systematically applies review checklist items from reference/checklist.md
- **Boundary**:
  - Focus only on checks that require human/AI judgment
  - Treat deterministic validation automation as out of scope for this review skill
  - Do not run yamllint or scripts/validate.sh from this review skill
- **When to use**: Review .github/skills/\*/SKILL.md files for quality, specification completeness, and design pattern compliance

**What this skill does**:

1. **Structure Validation**: Verify SKILL.md contains required sections, YAML fields, and reference file header consistency
   - S-01: Section order and completeness
   - S-03: Reference file header level standards
   - YAML frontmatter fields
2. **Manual Quality Review** (systematic evaluation via human/AI judgment)
   - Q-01: Output is Truly Structured
   - Q-02: Scope Boundaries
   - Q-03: Execution Determinism
   - Q-04: Input/Output Specificity
   - Q-05: Constraints Clarity
   - Q-06: No Implicit Inference
   - P-01: Design Pattern Compliance
   - P-02: Output Format Compliance
3. **Report Generation**
   - Checks Summary section: Total/Passed/Failed/Deferred counts
   - Checks (Failed/Deferred Only) section: Show only ❌ and ⊘ items in checklist order
   - Issues section: Failed or deferred items only with full details
   - Full evaluation data for all checks is retained internally using fixed ItemIDs

**Out of Scope**:

- ❌ YAML/Markdown syntax errors → yamllint, markdownlint tools
- ❌ Automated file modifications
- ❌ PR merge approval
- ❌ Skill execution or functionality testing
- ❌ Reference file syntax validation

**Design Philosophy**:

This skill embodies the philosophy it recommends by implementing it in practice:

- Deterministic checks (structure, metrics, file existence) → Automated in scripts/ for objective verification
- Judgment-based checks (semantic evaluation, design decisions) → Manual review for human/AI strengths
- Result: Token efficiency + verification quality combined

Implementation: deterministic checks are delegated to validation tooling, and this review workflow focuses on judgment-based evaluation, achieving context optimization and verification credibility.

**Key principles**:

- **Meta-Pattern**: This skill itself demonstrates the philosophy it recommends (deterministic → automation, judgment-based → manual). Serves as a model for other skill design.
- **Reference-driven**: Detailed check criteria defined in reference/\*.md files. Load reference files only when reviewing specific categories.
- **Two-Phase Approach**: Structure validation (automated via scripts) followed by quality review (manual evaluation using reference files).

See reference/common-output-format.md for detailed format specification and examples.

## Constraints

**Prerequisites**:

1. SKILL.md must have YAML front matter (name, description, license)
2. Target SKILL.md and required references are available
3. Understanding of role boundaries between validation and review workflows
4. Understanding of agent-skills.instructions.md Structural Requirements required
5. Access to reference files (structure.md, quality.md, patterns.md) available

**Limitations**:

- Scope: `.github/skills/*/SKILL.md` files only (other formats out of scope)
- Judgment-based checks (Q-01–Q-06, P-01–P-02) require systematic review (cannot be fully automated)
- Recommendations must be concrete/specific (no vague expressions like "should be improved")

## Failure Behavior

**Error Handling**:

- Missing required section → **CRITICAL** severity (structural violation, cannot merge)
- Missing YAML frontmatter field → **CRITICAL** severity
- Non-structured output format → **CRITICAL** severity
- Ambiguous reasoning or expressions → **IMPORTANT** severity
- Minor design improvements → **ENHANCEMENT** level

**Reporting Content**:

- Number of failed checks, breakdown by category
- For each issue: CheckID, category, problem description, impact, concrete recommendation
- Summary of automation failure details if applicable

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - SKILL.md structure checklist (S-01 through P-02)
- **common-output-format.md** - SKILL.md review report format specification

**Category Details**:

- **category-patterns.md** - Agent Skill design patterns detailed guide
- **category-quality.md** - Quality standards (Q-01 through Q-06) detailed guide
- **category-structure.md** - Structure requirements (S-01 through S-02) detailed guide

## Checks Summary

- Total checks: <number>
- Passed: <count>
- Failed: <count>
- Deferred: <count>

## Checks (Failed/Deferred Only)

- <ItemID> <ItemName>: ❌ Fail
- <ItemID> <ItemName>: ⊘ Deferred (<explicit reason>)

## Issues

[Failed or deferred items only with details, "No issues found" if none]

1. CheckID: Item Name
   - File: path#L###
   - Problem: [Specific issue description]
   - Impact: [Why this matters, scope of impact]
   - Recommendation: [Concrete fix with code/config examples]

2. ...
```

## Workflow

### Step 1: Context Understanding

- Understand purpose, scope, background from PR/skill description
- Review agent-skills.instructions.md requirements

### Step 2: Confirm Review Boundary

- Focus on manual checks only:
  - Structure clarity and instruction quality
  - Design pattern compliance and specificity
  - Deterministic workflow documentation quality
- Do not execute validation tools in this review workflow

### Step 3: Systematic Manual Review

- Verify Q-01–Q-06 (quality checks) systematically using reference/quality.md
- Verify P-01–P-02 (pattern checks) systematically using reference/patterns.md
- Mark each as ✅ or ❌; for failures, provide concrete reason + recommendation

### Step 4: Report Generation

- Checks Summary section: Total/Passed/Failed/Deferred counts
- Checks (Failed/Deferred Only) section: only ❌ and ⊘ items
- Issues section: Failed or deferred items only with full details ("No issues found" if none)
- Output: Structured markdown format per Output Specification
