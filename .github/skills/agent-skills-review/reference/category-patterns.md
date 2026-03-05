## Pattern Checks

## P-01: Design Pattern Compliance

Check: Does SKILL.md implement the 4-step review flow (Context → Automated checks → Systematic review → Report) with automated/manual separation and category organization?
Why: Pattern consistency enables users to apply skills uniformly. Recognized patterns accelerate adoption and reduce learning curve.
Examples:
- ✅ "Step 1: Understand PR context. Step 2: Run linters. Step 3: Review design [categories A, B, C]. Step 4: Output structured report"
- ❌ No step structure, flat checks, no category organization

---

## P-02: Output Format Compliance

Check: Are outputs structured (## Checks [ItemID: ✅/❌ per line], ## Issues [numbered list with ID/File#Line/Problem/Impact/Recommendation])? For review skills, is output-format.md present with examples?
Why: Structured output enables parsing, automation, and consistent evaluation. Review skills require output-format.md for explicit format documentation.
Examples:
- ✅ "## Checks\n- Q-01: ✅\n- Q-02: ❌\n## Issues\n1. Q-02: Scope\n   - File: path#L45\n   - Problem: ...\n   - Impact: ...\n   - Recommendation: ..." + output-format.md exists
- ❌ "Issue found: X seems wrong. Fix it." (free text) or review skill missing output-format.md
