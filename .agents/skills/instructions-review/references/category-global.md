## Global Review Checks for Instructions Files

This file contains global checks applicable to all instructions files, covering general requirements and structural standards.

## General (G)

**G-01 (MUST): Front Matter**

Check: Front Matter contains applyTo and description fields
Why: Missing Front Matter causes automation failures and unclear file scope
Fix: Explicitly document `applyTo` and `description`

**G-02 (MUST): Title**

Check: Title clearly indicates purpose
Why: Unclear title makes file purpose difficult to identify, reduces searchability
Fix: Use clear, purpose-driven titles

## Structure (STRUCT)

**STRUCT-01 (MUST): Five Required Chapters Exist**

Check: Scope, Standards, Guidelines, Testing and Validation, and Security Guidelines chapters exist
Why: Missing required chapters cause information gaps, incomplete guidance, standardization failure
Fix: Ensure all 5 chapters (Scope → Standards → Guidelines → Testing and Validation → Security Guidelines)

**STRUCT-02 (MUST): Chapter Order Unified**

Check: Chapters follow Scope → Standards → Guidelines → Testing and Validation → Security Guidelines order
Why: Inconsistent chapter order reduces searchability and cross-file comparison difficulty
Fix: Standardize to specified order (Scope first, Security last)

**STRUCT-03 (MUST): Heading Levels Appropriate**

Check: Heading hierarchy properly uses H2 (chapters) → H3 (subsections)
Why: Improper heading hierarchy reduces readability and obscures structure
Fix: Apply H2/H3 hierarchy rules, minimize H4 and beyond

**STRUCT-04 (MUST): Standards Chapter Subsections**

Check: Does the Standards chapter have Naming Conventions subsection first, followed by tool-specific standards?
Why: Inconsistent subsection order reduces cross-file comparability and onboarding efficiency
Fix: Place Naming Conventions subsection first, followed by tool/domain standards subsections

**STRUCT-05 (MUST): Guidelines Chapter Subsections**

Check: Does the Guidelines chapter have domain rules first, followed by Anti-Patterns, then Code Modification Guidelines?
Why: Inconsistent subsection order makes it harder to find specific types of guidance
Fix: Order subsections as: domain-specific rules → Anti-Patterns → Code Modification Guidelines

**STRUCT-06 (MUST): H3 Heading Format**

Check: Do H3 headings use `### Name（LEVEL）` format for rule sections, and `### Name` for process/declaration sections?
Why: Inconsistent H3 formats make the instruction file type unclear at a glance
Fix: Use `### Name（MUST）` or `### Name（SHOULD）` for rule groups; use `### Name` for non-rule sections
