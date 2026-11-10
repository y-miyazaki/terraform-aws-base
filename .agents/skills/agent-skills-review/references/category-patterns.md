# Pattern Checks (P)

**P-01 (SHOULD): Workflow matches the skill family pattern (not ad-hoc steps)**

Check: Does SKILL.md define a deterministic execution pattern with explicit flow, boundaries, and references?
Why: Pattern consistency improves reliability and reduces ambiguous execution across agents.
Examples:

- ✅ Numbered workflow with explicit order and IF/THEN branching when needed
- ✅ Execution Scope clearly separates in-scope and out-of-scope actions
- ✅ Reference Files Guide maps common and category files to usage triggers
- ❌ Workflow steps are implicit or unordered
- ❌ Boundaries are missing or contradictory

---

**P-02 (SHOULD): Output matches common-output-format contract**

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

**P-03 (SHOULD): Gather required context before emitting the final report**

Check: For skills that generate or modify content (docs, code, configs), does the Workflow include an explicit step to read relevant source material before writing?
Why: Skills that write without reading produce generic, low-value output. Explicit context-gathering steps with per-type guidance ensure output is grounded in project-specific facts.
Examples:

- ✅ "Step 4: Gather context — read X for type A, read Y for type B" with concrete file types listed
- ✅ Sufficiency threshold defined (e.g., "proceed when at least N sections can be populated with facts")
- ❌ Workflow jumps from input resolution directly to template application with no reading step
- ❌ "Read relevant files" without specifying which files for which input types

---

**P-04 (SHOULD): Shared contract rules match sibling skills**

Check: When sibling skills share a contract (same package, or the same shared reference/asset set such as an edit gate, no-op rule, output format, or template), are the shared rules worded identically, and are byte-identical shared files still identical?
Why: Siblings that drift on a shared rule behave differently for the same request, and a fix applied to one copy silently misses the others.
Examples:

- ✅ Every sibling uses the same edit-gate table rows in the same order
- ✅ Shared `common-output-format.md` copies are byte-identical; skill-specific additions live in SKILL.md
- ❌ One sibling treats a bare "apply" as an edit request while another excludes it
- ❌ Sibling no-op instructions differ ("report skip and exit" vs "emit survey no-op")
- ❌ Output-format column names differ from the sibling templates they mirror
- ⊘ Deferred when no sibling skills are available to compare
