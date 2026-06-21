## Quality, Consistency, and Completeness Review Checks

This file contains review checks for content quality, cross-file consistency, and completeness of instructions files.

## Content Quality (QUAL)

**QUAL-01 (SHOULD): Practical Examples**

Check: Practical code examples are included
Why: Missing examples reduce usability and hinder understanding
Fix: Add practical code examples

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

## Completeness (COMP)

**COMP-01 (SHOULD): No Missing Commands**

Check: Executable validation commands are comprehensive
Why: Missing commands prevent validation and compromise quality assurance
Fix: Include all executable validation commands

**COMP-02 (SHOULD): Real Commands**

Check: Examples are concrete and comprehensive
Why: Missing examples make validation difficult and lack practicality
Fix: Provide concrete and comprehensive examples
