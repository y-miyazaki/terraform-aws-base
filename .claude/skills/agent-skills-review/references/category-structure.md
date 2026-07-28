## Structural Checks (S)

**S-01 (MUST): SKILL.md has the five required ## sections**

Check: Does SKILL.md have all 5 required sections at ## heading level?
Why: Complete structure ensures all required information exists for quality evaluation. Missing sections make skill incomplete and non-reviewable.

Required sections:

1. Input
2. Output Specification
3. Execution Scope
4. Reference Files Guide
5. Workflow

Sections removed by design (redundant with frontmatter description or self-evident to Claude):

- Purpose (duplicates description field)
- When to Use This Skill (duplicates description activation trigger)
- Constraints (self-evident prerequisites)
- Failure Behavior (standard tool behavior) — use `### Error Handling` under Workflow instead (Q-10 SHOULD)
- Best Practices (merge into Workflow or Execution Scope)

`### Error Handling` is not a sixth H2 section. It lives under `## Workflow` when the skill has recoverable or fatal branches (Q-10 SHOULD). Automation and utility siblings should include the same table pattern.

Examples:

- ✅ All 5 required sections present
- ❌ Missing "Workflow" → only 4/5 sections → FAIL

---

**S-02 (MUST): Frontmatter has name, description, license (+ version metadata)**

Check: Does SKILL.md YAML frontmatter have all required fields (name, description, license) and recommended metadata (author, version)?
Why: Machine-readable frontmatter enables skill discovery, cataloging, and CI/CD integration. Missing fields cause parsing errors and skill registration failures. Metadata enables version tracking and ownership.
Examples:

- ✅ `name: go-review`, `description: "Reviews..."`, `license: Apache-2.0`, `metadata: {author: y-miyazaki, version: "1.0.0"}`
- ❌ Missing `license` field → parsing fails
- ⚠️ Missing `metadata.version` → version tracking unavailable

---

**S-03 (MUST): References/ headers use required H1/H2 levels**

Check: Do references/ files follow consistent header level standards?
Why: Consistent header levels ensure predictable structure, proper document hierarchy, and correct rendering when files are referenced from SKILL.md via @-mention.

Header level requirements:

**Common-prefix files**:

- `common-checklist.md`: Starts with H1 (`#`)
- `common-output-format.md`: Starts with H1 (`#`)
- `common-troubleshooting.md`: Starts with H2 (`##`)
- `common-individual-commands.md`: Starts with H2 (`##`)

**Category-prefix files**:

- All category-\*.md: Starts with H2 (`##`)
- Internal content: H3 (`###`) and below for hierarchy

Examples:

- ✅ `common-checklist.md` first line: `# Checklist Title` → PASS
- ✅ `common-troubleshooting.md` first line: `## Troubleshooting Guide` → PASS
- ✅ `category-security.md` first line: `## Security Checks` → PASS
- ❌ `common-checklist.md` first line: `## Checklist` → FAIL (should be H1)
- ❌ `category-security.md` first line: `# Security Checks` → FAIL (should be H2)

---

**S-04 (MUST): Links stay in-skill or https:// (no ../docs escapes)**

Check: Do SKILL.md and `references/` link only to files inside the same skill directory (`references/`, `assets/`, `scripts/`) or to absolute `https://` URLs?
Why: Skills are often installed or copied per skill directory. Paths to repository `docs/`, `../other-skill/`, or `repository \`docs/...\`` prose break consumers that use the skill in a different repository layout.
Examples:

- ✅ `[category-automation-envelope.md](references/category-automation-envelope.md)`
- ✅ `https://example.com/spec` for stable external specs
- ❌ `repository \`docs/explanation/...\``
- ❌ `[format](../../../../docs/...)` or any `../` escape from the skill tree
- ❌ `[shared.md](../other-skill/references/shared.md)`

---

**S-05 (MUST): Use <agent-root> for install paths; do not hardcode .github/skills**

Check: When SKILL.md or `references/` mention skill install paths outside the current skill directory, do they use the `<agent-root>` placeholder (not a hardcoded root such as `.github/skills`)? Are in-skill paths written as `scripts/...`, `references/...`, or `assets/...`?
Why: Skills install under different agent roots. Hardcoding one root (for example `.github/skills`) breaks consumers that use `.claude`, `.agents`, or other roots.
Examples:

- ✅ `<agent-root>/skills/go-review/SKILL.md`
- ✅ `scripts/validate.sh` for a path inside the same skill
- ❌ `.github/skills/go-review/SKILL.md` as the only documented install path
- ❌ `.claude/skills/...` hardcoded when the example is meant to be portable
