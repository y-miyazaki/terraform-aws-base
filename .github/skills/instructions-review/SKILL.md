---
name: instructions-review
description: Instructions file review for structure, completeness, and consistency. Use for manual review of .instructions.md files checking content quality and standards compliance.
license: MIT
---

# Instructions File Review

This skill provides comprehensive guidance for reviewing `.github/instructions/*.instructions.md` files to ensure quality, consistency, and practical usability.

## When to Use This Skill

This skill is applicable for:

- Reviewing instructions file pull requests
- Checking instructions files before merging
- Ensuring consistency across all instructions files
- Validating completeness and structure
- Quality and standards compliance

## Important Notes

- **Structure First**: All files must follow the 4-chapter structure (Standards → Guidelines → Testing and Validation → Security Guidelines)
- **Consistency Focus**: This skill emphasizes consistency across all instructions files
- **Practical Validation**: All validation commands must be executable with examples
- **Manual Review Required**: Structure, completeness, and cross-file consistency require human judgment

## Review Process

### Step 1: Verify Required Structure

Confirm all 4 required chapters exist in correct order:

1. Standards
2. Guidelines
3. Testing and Validation
4. Security Guidelines

### Step 2: Systematic Review by Category

Review systematically using priority levels:

- **🔴 Critical**: STRUCT, COMP (structure, completeness)
- **🟡 Important**: STD, GUIDE, TEST, SEC (content quality)
- **🟢 Enhancement**: QUAL, CONS (quality improvements, consistency)

### Step 3: Report Issues with Recommendations

Document issues using Check+Why+Fix format with actionable recommendations.

## Review Guidelines

### 1. General (G)

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

### 2. Structure (STRUCT)

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

### 3. Standards Chapter (STD)

**STD-01: Naming Conventions**

Check: Naming conventions are documented per component
Why: Missing conventions cause code inconsistency and unclear review criteria
Fix: Add per-component naming table (functions, variables, files, etc.)

**STD-02: Tool Standards**

Check: Tool conventions are documented
Why: Missing tool standards prevent automation and cause implementation inconsistencies
Fix: Add standard conventions for relevant tools (formatters, linters, etc.)

**STD-03: Consistency**

Check: Documentation level matches other instructions files
Why: Cross-file inconsistency increases learning cost and hampers standardization
Fix: Unify documentation level, verify against reference files

### 4. Guidelines Chapter (GUIDE)

**GUIDE-01: Documentation and Comments**

Check: Comment and documentation conventions are documented
Why: Missing conventions hinder maintainability and reduce comment quality
Fix: Document comment/documentation conventions (language, format, required items)

**GUIDE-02: Code Modification Guidelines**

Check: Modification procedures and validation methods are clearly documented
Why: Unclear procedures cause errors and inconsistency, reducing review quality
Fix: Add clear modification and validation procedures

**GUIDE-03: Tool Usage**

Check: MCP Tool usage examples are documented
Why: Missing examples cause operational variations and inefficient workflows
Fix: Add MCP Tool usage examples (where applicable)

**GUIDE-04: Error Handling**

Check: Error handling policy is documented
Why: Missing guidelines lead to inadequate handling of unexpected failures
Fix: Document error handling policy

### 5. Testing and Validation Chapter (TEST)

**TEST-01: Validation Commands**

Check: Executable validation commands are documented
Why: Missing commands prevent automation and compromise quality assurance
Fix: Document executable validation commands with examples

**TEST-02: Command Count**

Check: At least 3 validation commands are documented
Why: Too few commands reduce test coverage and compromise quality assurance
Fix: Add minimum 3 validation commands

**TEST-03: Code Block**

Check: Examples are in `bash code block format
Why: Non-code-block examples are difficult to execute and cannot be copy-pasted
Fix: Use `bash format for execution examples

**TEST-04: Validation Items**

Check: Validation items list is comprehensive
Why: Incomplete list causes missed checks and incomplete validation
Fix: Enrich validation items and cross-reference with aqua.yaml

**TEST-05: Tool Coverage**

Check: All tools in aqua.yaml are covered in validation commands
Why: Missing tools cause gaps in validation and underutilization of available tools
Fix: Cross-reference with aqua.yaml and add all tools

**TEST-06: Real Commands**

Check: Examples are concrete and actually executable
Why: Missing examples make validation difficult and cause command errors
Fix: Provide concrete examples and verify they execute correctly

### 6. Security Guidelines Chapter (SEC)

**SEC-01: Security Items**

Check: Security items are documented
Why: Missing items lead to overlooked vulnerabilities and increased security risk
Fix: Add required security items

**SEC-02: Secrets Management**

Check: Secrets management policy is documented
Why: Missing guidelines risk credential leakage and authentication information exposure
Fix: Document secrets management policy (environment variables, Secrets Manager, etc.)

**SEC-03: Best Practices**

Check: Concrete security best practices are documented
Why: Missing specifics encourage incorrect implementation and obscure standards
Fix: Add concrete best practices with examples

**SEC-04: Examples**

Check: YAML/code examples are included (where applicable)
Why: Missing examples lead to implementation errors and unclear best practices
Fix: Add YAML/code examples where needed

### 7. Content Quality (QUAL)

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

### 8. Consistency (CONS)

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

### 9. Completeness (COMP)

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

## Validation Process

### Line Count Balance

Expected ranges:

- Minimum: ~70 lines
- Maximum: ~230 lines (special cases)
- Standard: 100-180 lines

```bash
wc -l /workspace/.github/instructions/*.instructions.md
```

### Chapter Structure Verification

Verify 4-chapter structure across all files:

```bash
for f in /workspace/.github/instructions/*.instructions.md; do
  echo "=== $(basename $f) ==="
  grep -E '^## ' "$f"
  echo
done
```

### Validation Command Coverage

Verify validation command count in Testing and Validation chapter (minimum 3 items)

### Security Guidelines Existence

Verify Security Guidelines chapter exists in all files:

```bash
grep -l "## Security Guidelines" /workspace/.github/instructions/*.instructions.md | wc -l
```

Expected: All files (6 files)

## Best Practices

- **Reference Files**: Review go.instructions.md (222 lines) and github-actions-workflow.instructions.md (180 lines)
- **Minimum Standards**: 70+ lines, 3+ validation commands, 4 chapters required
- **Consistency Priority**: Prioritize consistency with existing files over new additions
- **Practical Focus**: Emphasize executable and practical content

## Common Issues and Fixes

### Issue 1: Inconsistent Chapter Order

Problem: Testing and Validation is nested inside Guidelines
Fix: Extract as independent chapter, place before Security Guidelines

### Issue 2: Insufficient Validation Commands

Problem: Only 1-2 validation commands documented
Fix: Review aqua.yaml and add all relevant tools (minimum 3 items)

### Issue 3: Missing Security Guidelines Chapter

Problem: Security chapter does not exist
Fix: Add chapter covering secrets management and best practices

### Issue 4: Inconsistent Documentation Level

Problem: Less detailed than other files
Fix: Review other files and expand to equivalent detail level

## Output Format

### Checks

List all review items with Pass/Fail status:

```
- G-01 Front Matter: ✅ Pass
- STRUCT-01 Four Required Chapters: ❌ Fail
...
```

### Issues

Document only failed items with:

1. **Item ID + Item Name**
   - Problem: Problem description
   - Impact: Impact scope and severity
   - Recommendation: Specific fix suggestion

### Examples

#### ✅ All Pass

```markdown
# Instructions Review Result

## Checks

- G-01 Front Matter: ✅ Pass
- STRUCT-01 Four Required Chapters: ✅ Pass
- TEST-01 Validation Commands: ✅ Pass
  ...

## Issues

None ✅
```

#### ❌ Issues Found

```markdown
# Instructions Review Result

## Checks

- G-01 Front Matter: ✅ Pass
- STRUCT-01 Four Required Chapters: ❌ Fail
- TEST-02 Command Count: ❌ Fail
  ...

## Issues

1. STRUCT-01 Four Required Chapters
   - Problem: Security Guidelines chapter missing
   - Impact: Missing security guidelines, incomplete standardization
   - Recommendation: Add Security Guidelines chapter covering secrets management and best practices

2. TEST-02 Command Count
   - Problem: Only 2 validation commands documented
   - Impact: Reduced test coverage, insufficient quality assurance
   - Recommendation: Review aqua.yaml and expand to minimum 3 items
```
