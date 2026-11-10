# Quality, Consistency, and Completeness Review Checks

This file contains review checks for content quality, cross-file consistency, and completeness of instructions files.

## Content Quality (QUAL)

**QUAL-01 (SHOULD): Practical Examples**

Check: Where a rule's correct form is not clear from its wording (for example a required syntax, file layout, or naming pattern), is a short practical example included? Files whose Guidelines are ItemID title bullets only do not need examples.
Why: Missing examples for non-obvious forms reduce usability; examples for self-evident rules waste always-on tokens (QUAL-03)
Fix: Add a minimal example only for rules whose correct form is not self-evident

**QUAL-02 (SHOULD): No Redundancy**

Check: No duplicate content
Why: Duplication reduces maintainability and risks inconsistencies
Fix: Remove duplicates and use references instead

**QUAL-03 (SHOULD): Token Efficiency**

Check: Large code examples are avoided for high token efficiency
Why: Large examples waste tokens and increase costs
Fix: Remove large examples, use minimal necessary examples

## Consistency (CONS)

**CONS-01 (SHOULD): Section Names**

Check: Section names are consistent with other instructions files
Why: Inconsistent names make them harder to find and hinder standardization
Fix: Unify section names and verify against reference files

**CONS-02 (SHOULD): Format**

Check: Table and list formats are consistent with other instructions files
Why: Format variations cause reading errors and reduce readability
Fix: Standardize table and list formats

**CONS-03 (SHOULD): Internal Consistency**

Check: Do Standards templates, Guidelines checks, and code examples within the same file agree with each other without contradiction?
Why: Contradictions between sections (e.g., a template missing a field that a Check requires) cause agents to produce inconsistent output
Fix: Cross-reference Standards definitions against Guidelines checks and resolve discrepancies

## Completeness (COMP)

**COMP-01 (SHOULD): Validation Ownership Clear**

Check: Does Testing and Validation avoid always-run lint recipes, and use at most a short on-demand skill pointer?
Why: Always-on command catalogs duplicate validation skills and Agent hooks
Fix: Keep Testing and Validation to a skill pointer and non-automated operational notes only

**COMP-02 (SHOULD): Real Pointers**

Check: When on-demand validation or review is referenced, is the companion skill stem concrete rather than vague "run validation"?
Why: Vague pointers leave agents without a discoverable skill entry point
Fix: Name the concrete skill stem (for example `<domain>-validation`) when pointing to on-demand checks
