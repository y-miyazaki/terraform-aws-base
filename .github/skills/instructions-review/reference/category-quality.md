## Quality, Consistency, and Completeness Review Checks

This file contains review checks for content quality, cross-file consistency, and completeness of instructions files.

## Content Quality (QUAL)

**QUAL-01: Conciseness**

Check: Content is concise without redundant expressions
Why: Redundancy reduces token efficiency and readability
Fix: Use shorter sentences, remove unnecessary explanations

**QUAL-02: Practical Examples**

Check: Practical code examples are included
Why: Missing examples reduce usability and hinder understanding
Fix: Add practical code examples

**QUAL-03: No Redundancy**

Check: No duplicate content
Why: Duplication reduces maintainability and risks inconsistencies
Fix: Remove duplicates and use references instead

**QUAL-04: Token Efficiency**

Check: Large code examples are avoided for high token efficiency
Why: Large examples waste tokens and increase costs
Fix: Remove large examples, use minimal necessary examples

## Consistency (CONS)

**CONS-01: Chapter Order**

Check: Chapter order is consistent across all instructions files
Why: Inconsistent chapters make cross-file comparison difficult and increase learning cost
Fix: Standardize chapter order (Standards → Guidelines → Testing → Security)

**CONS-02: Section Names**

Check: Section names are consistent with other instructions files
Why: Inconsistent names make them harder to find and hinder standardization
Fix: Unify section names and verify against reference files

**CONS-03: Detail Level**

Check: Documentation detail level matches other instructions files
Why: Differing levels hinder standardization and create imbalances
Fix: Align detail levels and follow reference file standards

**CONS-04: Format**

Check: Table and list formats are consistent with other instructions files
Why: Format variations cause reading errors and reduce readability
Fix: Standardize table and list formats

## Completeness (COMP)

**COMP-01: All Required Sections**

Check: All required sections exist
Why: Missing sections lead to incomplete reviews and information gaps
Fix: Ensure all required sections are present

**COMP-02: No Missing Commands**

Check: Executable validation commands are comprehensive
Why: Missing commands prevent validation and compromise quality assurance
Fix: Include all executable validation commands

**COMP-03: Tool Coverage**

Check: All tools in aqua.yaml are documented
Why: Missing tools cause validation gaps and underutilization
Fix: Cross-reference with aqua.yaml and include all tools

**COMP-04: Real Commands**

Check: Examples are concrete and comprehensive
Why: Missing examples make validation difficult and lack practicality
Fix: Provide concrete and comprehensive examples
