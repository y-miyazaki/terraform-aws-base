## Pattern Checks

## P-01: Design Pattern Compliance

Check: Does SKILL.md follow the appropriate workflow pattern for its skill type?
Why: Pattern consistency enables users to apply skills uniformly. Recognized patterns accelerate adoption and reduce learning curve. Different skill types have different optimal patterns.

**Review skills** (e.g., go-review, terraform-review):
- Checklist-driven workflow: Understand Context → Systematic Review (using reference categories) → Report
- Explicit boundary with related validation skill ("Do not run X-validation")
- Reference Files Guide with category-specific trigger conditions

**Validation skills** (e.g., go-validation, terraform-validation):
- Script-driven workflow: Always use validate.sh → Fix issues → Re-run
- Explicit boundary with related review skill ("Do not review design decisions, use X-review")
- Script usage examples with common flags

**Automation skills** (e.g., github-pr-body):
- Execution flow: Step 1 → Step 2 → ... with clear tool priority
- Idempotent execution (safe to re-run)
- Deterministic vs. AI completion separation

Examples:
- ✅ Review skill: "Step 1: Understand Context. Step 2: Systematic Review using checklist. Step 3: Report Issues"
- ✅ Validation skill: "Always use scripts/validate.sh. Do not run individual commands."
- ❌ Review skill with no checklist reference or category organization
- ❌ Validation skill that describes manual tool execution instead of script usage

---

## P-02: Output Contract Compliance

Check: Does the skill define a structured, skill-appropriate output contract across Output Specification and common-output-format.md without contradiction or role overlap?
Why: Structured output enables parsing, automation, and consistent evaluation. The exact structure may differ by skill type, but the contract must remain explicit and consistent.
Examples:
- ✅ Review skill: "## Checks Summary" + "## Issues" with a matching common-output-format.md
- ✅ Validation skill: tool/result summary in Output Specification and detailed report schema in common-output-format.md
- ✅ Automation skill: PR Body or JSON schema described in Output Specification, with matching template details in common-output-format.md
- ❌ Output Specification says PR Body, but common-output-format.md defines Checks/Issues report
- ❌ common-output-format.md exists but only repeats vague prose without concrete structure
