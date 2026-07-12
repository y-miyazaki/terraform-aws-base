## Pattern Checks (P)

**P-01 (SHOULD): Design Pattern Compliance**

Check: Does SKILL.md define a deterministic execution pattern with explicit flow, boundaries, and references?
Why: Pattern consistency improves reliability and reduces ambiguous execution across agents.
Examples:

- ✅ Numbered workflow with explicit order and IF/THEN branching when needed
- ✅ Execution Scope clearly separates in-scope and out-of-scope actions
- ✅ Reference Files Guide maps common and category files to usage triggers
- ❌ Workflow steps are implicit or unordered
- ❌ Boundaries are missing or contradictory

---

**P-02 (SHOULD): Output Contract Compliance**

Check: Does the skill define a structured output contract across Output Specification and common-output-format.md without contradiction?
Why: Structured output enables parsing, automation, and consistent evaluation.
Rule: In P-02 findings and recommendations, explicitly include a link to [common-output-format.md](./common-output-format.md). Keep this link even when Reference Files Guide already links the same file; do not remove it as duplication.
Examples:

- ✅ Output Specification summarizes return shape and common-output-format.md defines concrete structure
- ✅ P-02 output includes [common-output-format.md](./common-output-format.md) explicitly, even if Reference Files Guide already references it
- ✅ Section names, field names, and required elements are explicit
- ❌ Output Specification and common-output-format.md define conflicting formats
- ❌ common-output-format.md only contains vague prose
- ❌ P-02 omits [common-output-format.md](./common-output-format.md) because it appears in Reference Files Guide

---

**P-03 (SHOULD): Context Gathering Before Output**

Check: For skills that generate or modify content (docs, code, configs), does the Workflow include an explicit step to read relevant source material before writing?
Why: Skills that write without reading produce generic, low-value output. Explicit context-gathering steps with per-type guidance ensure output is grounded in project-specific facts.
Examples:

- ✅ "Step 4: Gather context — read X for type A, read Y for type B" with concrete file types listed
- ✅ Sufficiency threshold defined (e.g., "proceed when at least N sections can be populated with facts")
- ❌ Workflow jumps from input resolution directly to template application with no reading step
- ❌ "Read relevant files" without specifying which files for which input types
