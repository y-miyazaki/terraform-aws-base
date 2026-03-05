## Structural Checks

## S-01: Structural Completeness

Check: Does SKILL.md have all 9 required sections at ## heading level in the correct order?
Why: Complete structure ensures all required information exists for quality evaluation. Missing sections or incorrect order make skill incomplete and non-reviewable.

Required sections in order:
1. Purpose
2. When to Use This Skill
3. Input Specification
4. Output Specification
5. Execution Scope
6. Constraints
7. Failure Behavior
8. Reference Files Guide
9. Workflow

Examples:
- ✅ All 9 sections present in correct order
- ❌ Missing "Workflow" → only 8/9 sections → FAIL
- ❌ "Reference Files Guide" appears before "Constraints" → incorrect order → FAIL

---

## S-02: YAML Frontmatter Fields

Check: Does SKILL.md YAML frontmatter have all 3 required fields (name, description, license)?
Why: Machine-readable frontmatter enables skill discovery, cataloging, and CI/CD integration. Missing fields cause parsing errors and skill registration failures.
Examples:
- ✅ `name: agent-skills-review`, `description: "Review..."`, `license: MIT`
- ❌ Missing `license` field → parsing fails

---

## Q-07: Progressive Disclosure (Word Count)

Check: Is SKILL.md word count < 5,000 words?
Why: Word count limit ensures token efficiency, AI response speed, and human readability. Exceeding limit forces details to reference/ for on-demand loading.
Examples:
- ✅ wc -w SKILL.md = 996 < 5,000 → PASS
- ❌ wc -w SKILL.md = 5,230 > 5,000 → FAIL (move verbose sections to reference/)

---

## Q-08: Resource Separation

Check: Does skill directory contain both scripts/ and reference/ subdirectories? For review skills, does reference/ include common-checklist.md and common-output-format.md?
Why: Resource separation ensures scripts for deterministic checks and references for judgment-based content. Review skills require common-checklist.md and common-output-format.md as mandatory files.
Examples:
- ✅ Both scripts/ and reference/ present. Review skill: includes common-checklist.md and common-output-format.md
- ❌ Missing reference/ → FAIL. Review skill missing checklist.md or output-format.md → FAIL

---

## S-03: Reference Files Header Level Consistency

Check: Do reference/ files follow consistent header level standards?
Why: Consistent header levels ensure predictable structure, proper document hierarchy, and correct rendering when files are referenced from SKILL.md via @-mention.

Header level requirements:

**Common-prefix files**:
- `common-checklist.md`: Starts with H1 (`#`)
- `common-output-format.md`: Starts with H1 (`#`)
- `common-troubleshooting.md`: Starts with H2 (`##`)
- `common-individual-commands.md`: Starts with H2 (`##`)

**Category-prefix files**:
- All category-*.md: Starts with H2 (`##`)
- Internal content: H3 (`###`) and below for hierarchy

Examples:
- ✅ `common-checklist.md` first line: `# Checklist Title` → PASS
- ✅ `common-troubleshooting.md` first line: `## Troubleshooting Guide` → PASS
- ✅ `category-security.md` first line: `## Security Checks` → PASS
- ❌ `common-checklist.md` first line: `## Checklist` → FAIL (should be H1)
- ❌ `category-security.md` first line: `# Security Checks` → FAIL (should be H2)
