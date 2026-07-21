## Testing and Validation Chapter Review Checks

This file contains review checks specific to the Testing and Validation chapter of instructions files.

## Testing and Validation Chapter (TEST)

**TEST-01 (MUST): No Always-Run Lint Mandates**

Check: Does the chapter omit "after every change, run validate.sh / linter X" and omit "hooks/pre-commit handle X so do not run Y"?
Why: Always-on lint recipes waste context and fight Agent hooks; skip-explanations are also unused always-on cost
Fix: Remove always-run recipes and hook-skip explanations; keep at most an on-demand skill pointer and notes for non-automated checks

**TEST-02 (SHOULD): On-Demand Skill Pointer**

Check: If present, is the skill pointer one short line (skill name / SKILL.md) without command recipe blocks?
Why: Long command catalogs belong in validation skills, not always-on instructions
Fix: Replace recipe blocks with a single skill pointer line

**TEST-03 (SHOULD): Domain-Only Operational Notes**

Check: Are any remaining operational notes limited to checks automation does not cover (for example tests, coverage, suite pairing, judgment review)?
Why: Duplicating hook-covered lint guidance in instructions creates drift and token waste
Fix: Keep only domain notes that hooks/pre-commit do not enforce
