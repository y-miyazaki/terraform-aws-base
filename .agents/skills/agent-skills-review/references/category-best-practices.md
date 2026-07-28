## Best Practice Checks (BP)

**BP-01 (SHOULD): Description states what the skill does and when to use it**

Check: Does the description field follow best practices for skill discovery (third person, includes when-to-activate trigger content, no implementation instructions)?
Why: The description is the primary signal for skill activation. Poor descriptions cause incorrect skill selection or missed activation. Official guidance: write in third person and include specific keywords that help agents identify relevant tasks. A clear activation trigger is required; the exact phrase `Use when...` is recommended but not mandatory.
Examples:

- ✅ "Reviews Go source code for correctness and security. Use when reviewing Go pull requests or assessing security." (third person + recommended trigger phrasing)
- ✅ "Reviews Go source code for correctness and security during pull-request review and security assessment." (third person + trigger content without `Use when`)
- ❌ "Use for manual review of Go code" (imperative, not third person)
- ❌ "Always use validate.sh script. For troubleshooting, see references/." (implementation instructions in description)
- ❌ "Helps with Go code" (too vague, no activation trigger)

---

**BP-02 (SHOULD): Reference Files Guide states when each reference is read**

Check: Does every Reference Files Guide line use exactly one parenthetical load trigger from the allowlist — `(always read)`, `(read on failure)`, `(read on debugging)`, `(read on automation path)`, `(read on interactive path)`, `(read when <condition>)`? Flag any other trigger wording.
Allowlist detail: `<condition>` in `(read when <condition>)` must be a single concrete predicate.
Why: One allowlisted trigger keeps load timing unambiguous. Triggers outside the list are easy to misread.
Examples:

- ✅ `[common-checklist.md](references/common-checklist.md) (always read)`
- ✅ `[category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)`
- ✅ `[common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)`
- ✅ `[common-impact-map.md](references/common-impact-map.md) (read on interactive path)`
- ❌ Parenthetical trigger not on the allowlist
- ❌ No parenthetical trigger on a Reference Files Guide line

---

**BP-03 (SHOULD): SKILL.md avoids redundant prose already in references**

Check: Does SKILL.md avoid content that Claude already knows, minimizing redundancy with frontmatter and reference files?
Why: Every token competes for context window attention. Redundant content dilutes the agent's focus on project-specific instructions. Claude's official best practice: "Would the agent get this wrong without this instruction? If no, cut it."
Examples:

- ✅ No Purpose section (duplicates description field)
- ✅ No When to Use section (duplicates description activation trigger)
- ✅ No self-evident Constraints section
- ✅ No general Failure Behavior section (standard tool behavior)
- ✅ No Available Review Categories section (duplicates Reference Files Guide)
- ❌ Purpose section that restates the description
- ❌ Constraints listing "Go toolchain installed", "Files must exist"
- ❌ Failure Behavior listing standard exit codes and error messages

---

**BP-04 (SHOULD): Do not over-compress below sibling skill depth**

Check: If token reduction is applied, are behavior-defining instructions preserved?
Why: Over-aggressive trimming can make a skill unreadable to the agent, reducing activation quality and causing execution errors even when token limits pass.
Examples:

- ✅ Trigger blocks still explicit (description activation trigger, `USE FOR`, `DO NOT USE FOR`)
- ✅ Output contract still structured and consistent (`Output Specification` + `common-output-format.md`)
- ✅ Workflow still deterministic with numbered steps or explicit IF/THEN branches
- ✅ At least one concrete example remains
- ❌ Token-only edit removed trigger clarity or deleted examples
