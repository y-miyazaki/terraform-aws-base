## Global Review Checks for Instructions Files

This file contains global checks applicable to all instructions files, covering general requirements and structural standards.

## General (G)

**G-01: Front Matter**

Check: Front Matter contains applyTo and description fields
Why: Missing Front Matter causes automation failures and unclear file scope
Fix: Explicitly document `applyTo` and `description`

**G-02: Language Policy**

Check: Language policy is documented
Why: Missing policy causes inconsistencies and mixed language usage
Fix: Add "Language Policy: Documentation in English, code comments in English"

**G-03: Title**

Check: Title clearly indicates purpose
Why: Unclear title makes file purpose difficult to identify, reduces searchability
Fix: Use clear, purpose-driven titles

## Structure (STRUCT)

**STRUCT-01: Four Required Chapters Exist**

Check: Standards, Guidelines, Testing and Validation, and Security Guidelines chapters exist
Why: Missing required chapters cause information gaps, incomplete guidance, standardization failure
Fix: Ensure all 4 chapters (Standards → Guidelines → Testing and Validation → Security Guidelines)

**STRUCT-02: Chapter Order Unified**

Check: Chapters follow Standards → Guidelines → Testing → Security order
Why: Inconsistent chapter order reduces searchability and cross-file comparison difficulty
Fix: Standardize to specified order (Standards first, Security last)

**STRUCT-03: Heading Levels Appropriate**

Check: Heading hierarchy properly uses H2 (chapters) → H3 (subsections)
Why: Improper heading hierarchy reduces readability and obscures structure
Fix: Apply H2/H3 hierarchy rules, minimize H4 and beyond
