## Structural Checks (S)

**S-01 (MUST): Structural Completeness**

Check: Does SKILL.md have all 6 required sections at ## heading level?
Why: Complete structure ensures all required information exists for quality evaluation. Missing sections make skill incomplete and non-reviewable.

Required sections:
1. Input
2. Output Specification
3. Execution Scope
4. Reference Files Guide
5. Workflow
6. Best Practices

Sections removed by design (redundant with frontmatter description or self-evident to Claude):
- Purpose (duplicates description field)
- When to Use This Skill (duplicates description "Use when..." trigger)
- Constraints (self-evident prerequisites)
- Failure Behavior (standard tool behavior)

Examples:
- ✅ All 6 required sections present
- ❌ Missing "Workflow" → only 5/6 sections → FAIL

---

**S-02 (MUST): YAML Frontmatter Fields**

Check: Does SKILL.md YAML frontmatter have all required fields (name, description, license) and recommended metadata (author, version)?
Why: Machine-readable frontmatter enables skill discovery, cataloging, and CI/CD integration. Missing fields cause parsing errors and skill registration failures. Metadata enables version tracking and ownership.
Examples:
- ✅ `name: go-review`, `description: "Reviews..."`, `license: Apache-2.0`, `metadata: {author: y-miyazaki, version: "1.0.0"}`
- ❌ Missing `license` field → parsing fails
- ⚠️ Missing `metadata.version` → version tracking unavailable

---

**BP-01 (SHOULD): Description Quality**

Check: Does the description field follow best practices for skill discovery (third person, "Use when..." trigger, no implementation instructions)?
Why: The description is the primary signal for skill activation. Poor descriptions cause incorrect skill selection or missed activation. Claude's official best practice: "Always write in third person" and "include specific keywords that help agents identify relevant tasks."
Examples:
- ✅ "Reviews Go source code for correctness and security. Use when reviewing Go pull requests or assessing security." (third person + trigger)
- ❌ "Use for manual review of Go code" (imperative, not third person)
- ❌ "Always use validate.sh script. For troubleshooting, see references/." (implementation instructions in description)
- ❌ "Helps with Go code" (too vague, no trigger keywords)

---

**BP-02 (SHOULD): Reference Trigger Conditions**

Check: Does Reference Files Guide specify when to load each reference file (not just what it contains)?
Why: Without trigger conditions, the agent may load all reference files upfront (wasting context) or miss relevant files. Explicit triggers enable on-demand loading per progressive disclosure.
Examples:
- ✅ `[category-security.md](references/category-security.md) - Read when reviewing input validation, crypto usage, or SQL injection`
- ✅ `[common-checklist.md](references/common-checklist.md)` with `(always read)` annotation
- ❌ `**category-security.md** - Security patterns detailed guide` (no trigger, bold instead of link)

---

**Q-07 (SHOULD): Progressive Disclosure (Soft Guard)**

Check: Is SKILL.md concise and compatible with token budget, using word count as a supplemental signal?
Why: Hard gate is `waza check` token budget. Word count is a soft guard for readability and early warning, not a release blocker by itself.
Examples:
- ✅ `waza check` token budget passes and word count remains manageable
- ⚠️ Word count is high, but fix priority is still token/behavior quality rather than raw length alone

---

**Q-08 (SHOULD): Resource Separation**

Check: Does skill directory contain `references/` and the mandatory common reference files? `scripts/` is optional but required when executable logic is provided.
Why: Reference files define reusable evaluation contracts. Scripts should hold deterministic executable logic when present, but not every skill requires scripts.
Examples:
- ✅ references/ exists and includes common-checklist.md + common-output-format.md
- ✅ scripts/ exists when deterministic commands are provided
- ❌ Missing references/ or missing common-checklist.md/common-output-format.md

---

**S-03 (MUST): Reference Files Header Level Consistency**

Check: Do references/ files follow consistent header level standards?
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
