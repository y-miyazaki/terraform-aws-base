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

## P-02: Output Format Compliance

Check: Are outputs structured (## Checks [ItemID: ✅/❌ per line], ## Issues [numbered list with ID/File#Line/Problem/Impact/Recommendation])? For review skills, is output-format.md present with examples?
Why: Structured output enables parsing, automation, and consistent evaluation. Review skills require output-format.md for explicit format documentation.
Examples:
- ✅ "## Checks\n- Q-01: ✅\n- Q-02: ❌\n## Issues\n1. Q-02: Scope\n   - File: path#L45\n   - Problem: ...\n   - Impact: ...\n   - Recommendation: ..." + output-format.md exists
- ❌ "Issue found: X seems wrong. Fix it." (free text) or review skill missing output-format.md
