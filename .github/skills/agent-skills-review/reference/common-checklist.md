# Complete Review Checklist & Validation Commands

## Automated Validation Commands

Run these BEFORE manual review to verify pre-conditions:

### 1. Run All Automated Checks
```bash
# Run the validate.sh script (includes YAML syntax, structure, field, word count, directories)
bash .github/skills/agent-skills-review/scripts/validate.sh SKILL.md

# Expected output: JSON with all validation checks
# If any FAIL (status != PASS), stop and request fixes before proceeding to manual review
```

---

## Manual Review Checklist

### Automated Checks Status
- [ ] YAML Syntax → validated by validate.sh
- [ ] Structural Completeness (9 sections) → validated by validate.sh
- [ ] YAML Frontmatter Fields → validated by validate.sh
- [ ] Progressive Disclosure → validated by validate.sh
- [ ] Resource Separation → validated by validate.sh
- [ ] Reference Mandatory Files → validated by validate.sh

**Note:** All automated checks are executed by `validate.sh` script. If any check has status "FAIL", fix the issue and re-run before proceeding to manual review.

### Structure Checks (Reference: reference/category-structure.md)

#### S-01: Section Order
- [ ] All 9 required sections present in correct order:
  1. Purpose
  2. When to Use This Skill
  3. Input Specification
  4. Output Specification
  5. Execution Scope
  6. Constraints
  7. Failure Behavior
  8. Reference Files Guide
  9. Workflow
- **PASS** if order matches exactly, **FAIL** if any section missing or out of order

#### S-03: Reference Files Header Level Consistency
- [ ] `common-checklist.md`: Starts with H1 (`#`)
- [ ] `common-output-format.md`: Starts with H1 (`#`)
- [ ] `common-troubleshooting.md`: Starts with H2 (`##`) if present
- [ ] `common-individual-commands.md`: Starts with H2 (`##`) if present
- [ ] All `category-*.md` files: Start with H2 (`##`)
- **PASS** if all present files follow header level standards, **FAIL** if any file violates standard

### Quality Checks (Reference: reference/category-quality.md)

#### Q-01: Output is Truly Structured
- [ ] Output Specification defines structured format (JSON/Markdown/Table)
- [ ] Concrete example provided (not just description)
- [ ] Format is machine-parseable (not free text)
- **PASS** if all 3 ✅

#### Q-02: Scope Boundaries
- [ ] "What this skill does" section exists with explicit action list
- [ ] "Out of Scope" section explicitly lists what skill does NOT do
- [ ] Tool delegation clearly mentioned (yamllint, external tools, etc.)
- **PASS** if all 3 ✅

#### Q-03: Execution Determinism
- [ ] Review Flow has clear Step 1/2/3/4 or similar explicit sequence
- [ ] If multiple paths, decision criteria are explicit (IF/THEN conditions)
- [ ] No "depending on context" without specifying those contexts
- **PASS** if all 3 ✅

#### Q-04: Input/Output Specificity
- [ ] Input format examples are concrete (not "JSON file" but structured example)
- [ ] Output format examples are specific (field names, value types)
- [ ] No forbidden expressions: "etc.", "and so on", "as needed", "appropriately"
- **PASS** if all 3 ✅

#### Q-05: Constraints Clarity
- [ ] Prerequisites are numeric/specific ("Git 2.30+", "Python 3.8+") not generic
- [ ] Limitations are concrete ("Cannot > 100MB", "AWS-only") not vague
- [ ] Timeout/retry logic has numeric values (30s, 3 attempts)
- **PASS** if all 3 ✅

#### Q-06: No Implicit Inference
- [ ] All instructions use imperative form (Do X, Return Y, not "You should")
- [ ] Conditional logic explicit: "If X, then Y, else Z" (not "Handle appropriately")
- [ ] No forbidden expressions: "appropriately", "depending on", "case by case"
- **PASS** if all 3 ✅

### Pattern Checks (Reference: reference/patterns.md)

#### P-01: Design Pattern Compliance
- [ ] 4-step Review Flow clearly documented (Context → Automated → Manual → Report)
- [ ] Automated checks separated from manual checks explicitly
- [ ] 8+ check categories or organized check groups defined
- [ ] references/ directory populated with category-specific files
- [ ] SKILL.md includes "Philosophy" or similar section explaining approach
- **PASS** if 5+ terms exist (4 is pass, 5 is comprehensive)

#### P-02: Output Format Compliance
- [ ] Output Specification explicitly defines: ## Checks section format
- [ ] Output Specification explicitly defines: ## Issues section structure
- [ ] Example output shows both Checks and Issues sections
- [ ] Issues section includes: CheckID, ItemName, File#Line, Problem, Impact, Recommendation
- [ ] Recommendations are concrete (code/config examples), not generic
- **PASS** if all 5 ✅

---

## Summary Scoring

| Category      | Checks                                       | Pass Threshold | Your Score |
| ------------- | -------------------------------------------- | -------------- | ---------- |
| **Automated** | 5 (YAML, Structure, Fields, WordCount, Dirs) | 5/5            | ___ / 5    |
| **Quality**   | 6 (Q-01~Q-06)                                | 5+/6           | ___ / 6    |
| **Pattern**   | 2 (P-01, P-02)                               | 2/2            | ___ / 2    |
| **TOTAL**     | 13                                           | 12/13          | ___ / 13   |

### Overall Status
- **✅ PASS**: 11+ / 12 pass (1 ENHANCEMENT allowed)
- **⚠️ REVIEW**: 9-10 / 12 pass (IMPORTANT issues)
- **❌ REJECT**: < 9 / 12 pass (CRITICAL issues)

---

## Reference Files Quick Link

For detailed evaluation criteria, refer to:

| Check ID               | Reference File             |
| ---------------------- | -------------------------- |
| S-01, S-02, Q-07, Q-08 | reference/structure.md     |
| Q-01 ~ Q-06            | reference/quality.md       |
| P-01, P-02             | reference/patterns.md      |
| Output examples        | reference/output-format.md |
| Philosophy             | reference/philosophy.md    |

---

## Common Failure Patterns & Fixes

| Pattern                  | Detection              | Fix                                                   |
| ------------------------ | ---------------------- | ----------------------------------------------------- |
| Invalid YAML syntax      | validate.sh YAML check | Fix indentation and YAML structure in frontmatter     |
| Missing sections         | validate.sh S-01 check | Add all 6 required ## sections                        |
| Vague output definition  | Q-01 (manual check)    | Add explicit JSON schema or markdown structure        |
| No explicit Out of Scope | Q-02 (manual check)    | Add "## Out of Scope" list with "does NOT" statements |
| Free-text instructions   | Q-06 (manual check)    | Replace "Handle X appropriately" with "If X, do Y"    |
| Missing review flow      | P-01 (manual check)    | Add "## Review Flow" with Step 1/2/3/4                |
| Non-structured output    | P-02 (manual check)    | Add example output with ## Checks + ## Issues format  |

---

## Validation Command Reference

```bash
# Full validation pipeline

# Execute all automated checks in one step
bash .github/skills/agent-skills-review/scripts/validate.sh SKILL.md

# Verify output JSON shows all checks as PASS or SKIP (not FAIL)
# Example success output:
# {
#   "validation_results": [
#     {"check": "YAML Syntax", "status": "PASS", "detail": ""},
#     {"check": "Structural Completeness", "status": "PASS", "detail": ""},
#     ...
#   ],
#   "overall_status": "PASS"
# }

# If any check status is FAIL, example failure extraction:
# cat /tmp/validation.json | jq '.validation_results[] | select(.status=="FAIL")'

# Then proceed to manual review checklist
```
