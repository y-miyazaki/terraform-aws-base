# Output Format Specification & Examples

## Output Structure Specification

All Agent Skills Review outputs follow this markdown structure:

```markdown
# Review Result: [SKILL_NAME]

## Checks
- S-01 Structural Completeness: [✅ or ❌]
- S-02 YAML Frontmatter Fields: [✅ or ❌]
- Q-01 Output is Truly Structured: [✅ or ❌]
- Q-02 Scope Boundaries: [✅ or ❌]
- Q-03 Execution Determinism: [✅ or ❌]
- Q-04 Input/Output Specificity: [✅ or ❌]
- Q-05 Constraints Clarity: [✅ or ❌]
- Q-06 No Implicit Inference: [✅ or ❌]
- Q-07 Progressive Disclosure: [✅ or ❌]
- Q-08 Resource Separation: [✅ or ❌]
- P-01 Design Pattern Compliance: [✅ or ❌]
- P-02 Output Format Compliance: [✅ or ❌]

## Issues
[success case or detailed issues]
```

---

## Example 1: All Pass (Success Case)

```markdown
# Review Result: my-review-skill

## Checks
- S-01 Structural Completeness: ✅
- S-02 YAML Frontmatter Fields: ✅
- Q-01 Output is Truly Structured: ✅
- Q-02 Scope Boundaries: ✅
- Q-03 Execution Determinism: ✅
- Q-04 Input/Output Specificity: ✅
- Q-05 Constraints Clarity: ✅
- Q-06 No Implicit Inference: ✅
- Q-07 Progressive Disclosure: ✅
- Q-08 Resource Separation: ✅
- P-01 Design Pattern Compliance: ✅
- P-02 Output Format Compliance: ✅

## Issues
None ✅
```



## Example 3: Automated Checks Fail

```markdown
# Review Result: new-skill

## Checks
- S-01 Structural Completeness: ❌
- S-02 YAML Frontmatter Fields: ✅
- Q-01 Output is Truly Structured: ⊘ (Deferred: awaiting S-01 fix)
- Q-02 Scope Boundaries: ⊘ (Deferred: awaiting S-01 fix)
- Q-03 Execution Determinism: ⊘ (Deferred: awaiting S-01 fix)
- Q-04 Input/Output Specificity: ⊘ (Deferred: awaiting S-01 fix)
- Q-05 Constraints Clarity: ⊘ (Deferred: awaiting S-01 fix)
- Q-06 No Implicit Inference: ⊘ (Deferred: awaiting S-01 fix)
- Q-07 Progressive Disclosure: ✅
- Q-08 Resource Separation: ✅
- P-01 Design Pattern Compliance: ⊘ (Deferred: awaiting S-01 fix)
- P-02 Output Format Compliance: ⊘ (Deferred: awaiting S-01 fix)

## Issues

**CRITICAL**: Structural issues must be resolved before manual review can proceed.

1. S-01: Structural Completeness
   - File: .github/skills/new-skill/SKILL.md
   - Problem: Missing required sections. Found: Purpose, Input Specification
     Missing: Output Specification, Execution Scope, Constraints, Failure Behavior
   - Impact: SKILL.md structure is incomplete. Skill cannot be evaluated for quality or design pattern compliance without all required sections.
   - Recommendation: Add missing sections to SKILL.md:
     ```markdown
     ## Output Specification
     [Define what skill outputs and format]

     ## Execution Scope
     [Specify what skill does and does not do]

     ## Constraints
     [List prerequisites and limitations]

     ## Failure Behavior
     [Define how errors are handled]
     ```
     Once added, resubmit for review.

Manual review is deferred until structural completeness is achieved.
```

---

## Output Generation Guidelines

### When to Report Each Status

| Symbol | Meaning  | When to Use                                             |
| ------ | -------- | ------------------------------------------------------- |
| ✅      | Pass     | Check verified correct                                  |
| ❌      | Fail     | Check failed, issue identified                          |
| ⊘      | Deferred | Check cannot yet be evaluated (waiting on prerequisite) |

### Issues Section Content Requirements

Each issue entry MUST include:

1. **ItemID: ItemName**
   ```
   1. Q-01: Output is Truly Structured
   ```

2. **File: path#L###**
   ```
   - File: .github/skills/my-skill/SKILL.md#L45
   ```

3. **Problem: [Specific description]**
   - ✅ Concrete, specific issue
   - ❌ Generic ("Improve this", "Not clear")

4. **Impact: [Why this matters]**
   - ✅ "Tool integration becomes difficult"
   - ❌ "Not ideal"

5. **Recommendation: [Concrete fix]**
   - ✅ Specific action + example code/structure
   - ❌ "Fix this part", "Improve clarity"

---

## Example 2: Failure Case (Structural Issues)

```markdown
# Review Result: new-skill

## Checks
- S-01 Structural Completeness: ❌
- S-02 YAML Frontmatter Fields: ✅
- Q-01~Q-06: ⊘ (Deferred: awaiting S-01 fix)
- P-01~P-02: ⊘ (Deferred: awaiting S-01 fix)
- Q-07~Q-08: ✅

## Issues

**CRITICAL - Manual review blocked**

1. S-01: Structural Completeness
   - File: .github/skills/new-skill/SKILL.md
   - Problem: Missing sections: Output Specification, Constraints, Failure Behavior
   - Impact: Cannot conduct quality review without complete structure
   - Recommendation: Add missing sections, then resubmit
```

### Do NOT Output

- ❌ Free-text narrative reviews
- ❌ Partial Checks list (include all 12)
- ❌ Generic recommendations
- ❌ Issues without concrete line numbers
- ❌ "Under review" or "Pending" status
