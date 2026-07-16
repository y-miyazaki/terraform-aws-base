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

**G-03 (MUST): applyTo Target Precision**

Check: Do `applyTo` globs match only intended instruction/rule paths after distribution (for example `.claude/rules/*.md`, not `.claude/**/*.md`)?
Why: Over-broad globs inject instruction-authoring rules into unrelated files (skills, docs) and hide missing companion coverage
Fix: Scope `applyTo` to package sources plus distributed rule paths (Cursor `.mdc`, Claude/Kiro rules), not entire agent trees

**G-04 (MUST): Portable Cross-References**

Check: Do agent-facing cross-links use stem-based wording (`companion X rules (stem \`x\`)`) instead of bareuctions.md`flnms
Why: APM renames instruction files per target (`bats.instructions.md` → `bats.mdc` / `bats.md`); bare source names do not exist at agent runtime
Fix: Prefer stem-based companion references; document the distribution mapping in Naming Conventions when relevant

**G-05 (MUST): Companion applyTo Coverage**

Check: When a companion instruction must guide production-file edits (for example tests paired with source), does `applyTo` include those production globs?
Why: Rules with only test/source-extension globs never inject when agents edit production files, so pairing obligations are skipped
Fix: Add production globs to the companion `applyTo` (for example `**/*.sh,**/*.bats`) and keep suite conventions in that companion file

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

**STRUCT-08 (SHOULD): Critical MUST in Scope**

Check: When Guidelines are large, are critical MUST obligations (for example test pairing) reinforced with a short Scope bullet?
Why: Buried MUST rules are easy for agents to skip when only the top of the file is attended to
Fix: Add a concise Scope MUST that points to the full Guidelines rule ID
