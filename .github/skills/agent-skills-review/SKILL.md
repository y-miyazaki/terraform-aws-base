---
name: agent-skills-review
description: >
  SKILL.md files review for structural requirements, quality standards, and design patterns.
  Use for manual review of .github/skills/*/SKILL.md files checking content quality, specification completeness, and implementation feasibility.
  Prerequisites: yamllint pass + scripts/validate.sh execution.
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
- **Prerequisites**: YAML frontmatter must pass yamllint and scripts/validate.sh must execute successfully
  - Run `yamllint` on frontmatter first
  - Run `scripts/validate.sh` to verify structural requirements
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
   - Checks section: All items displayed as ✅/❌
   - Issues section: Failed items only with full details

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

Implementation: scripts/validate.sh executes automated checks first (YAML syntax, 9 required sections, frontmatter fields, word count <5,000, directory structure, mandatory reference files), then manual review focuses on judgment-based evaluation, achieving context optimization and verification credibility.

**Key principles**:

- **Meta-Pattern**: This skill itself demonstrates the philosophy it recommends (deterministic → automation, judgment-based → manual). Serves as a model for other skill design.
- **Reference-driven**: Detailed check criteria defined in reference/\*.md files. Load reference files only when reviewing specific categories.
- **Two-Phase Approach**: Structure validation (automated via scripts) followed by quality review (manual evaluation using reference files).

See reference/common-output-format.md for detailed format specification and examples.

## Constraints

**Prerequisites**:

1. SKILL.md must have YAML front matter (name, description, license)
2. YAML frontmatter passes yamllint validation
3. Script validation passes (bash -n, shellcheck)
4. Understanding of agent-skills.instructions.md Structural Requirements required
5. Access to reference files (structure.md, quality.md, patterns.md) available

**Limitations**:

- Scope: `.github/skills/*/SKILL.md` files only (other formats out of scope)
- Judgment-based checks (Q-01–Q-06, P-01–P-02) require systematic review (cannot be fully automated)
- Recommendations must be concrete/specific (no vague expressions like "should be improved")

## Failure Behavior

**Error Handling**:

- Automated check failures → Stop, report issue, request re-validation before proceeding
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

## Checks

- S-01 Structural Completeness: ✅ or ❌
- S-02 YAML Frontmatter Fields: ✅ or ❌
- Q-01 Output is Truly Structured: ✅ or ❌
- Q-02 Scope Boundaries: ✅ or ❌
- Q-03 Execution Determinism: ✅ or ❌
- Q-04 Input/Output Specificity: ✅ or ❌
- Q-05 Constraints Clarity: ✅ or ❌
- Q-06 No Implicit Inference: ✅ or ❌
- Q-07 Progressive Disclosure: ✅ or ❌
- Q-08 Resource Separation: ✅ or ❌
- P-01 Design Pattern Compliance: ✅ or ❌
- P-02 Output Format Compliance: ✅ or ❌

## Issues

[Failed items only with details, "None ✅" if all pass]

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

### Step 2: Structure Validation

- Execute validation script: `bash scripts/validate.sh <SKILL.md>`
- Verify output shows structural checks passed
- Fix any structural issues (missing sections, YAML fields, directories) before proceeding

### Step 3: Systematic Manual Review

- Verify Q-01–Q-06 (quality checks) systematically using reference/quality.md
- Verify P-01–P-02 (pattern checks) systematically using reference/patterns.md
- Mark each as ✅ or ❌; for failures, provide concrete reason + recommendation

### Step 4: Report Generation

- Checks section: All 12 items displayed as ✅/❌
- Issues section: Failed items only with full details ("None ✅" if all pass)
- Output: Structured markdown format per Output Specification
