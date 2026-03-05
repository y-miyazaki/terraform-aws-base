## Quality Checks

## Q-01: Output is Truly Structured

Check: Is the output format definition implementable and parseable (JSON schema / Markdown structure explicitly defined with example)?
Why: Unstructured output prevents tool automation, integration, and parsing. AI/humans cannot reliably extract results without explicit format definition.
Examples:
- ✅ "Markdown structure: ## Checks [- ItemID: ✅/❌] + ## Issues [1. ItemID: Problem, Impact, Recommendation]"
- ❌ "Output will be a comprehensive report" (no structure defined)

---

## Q-02: Scope Boundaries

Check: Is Execution Scope split into "What this skill does" (action list) + "Out of Scope" (explicit non-actions with tool delegation)?
Why: Scope clarity prevents skill misuse, reduces ambiguity about responsibility boundaries, and clarifies tool/skill separation.
Examples:
- ✅ "Does: Review design. Does NOT: Run syntax checks (yamllint's responsibility)"
- ❌ Only "Does" section or implicit scope ("Not responsible for X")

---

## Q-03: Execution Determinism

Check: Is execution path single/canonical OR are conditional branches explicitly defined (IF condition → path A, ELSE → path B)?
Why: Deterministic execution prevents surprises, enables reproducibility, and allows automation. Ambiguous conditions cause inconsistent behavior across different uses.
Examples:
- ✅ "Step 1: Parse. Step 2: Validate. Step 3: Report" OR "IF error severity=CRITICAL, halt. ELSE continue"
- ❌ "Behavior varies depending on context" (no conditions specified)

---

## Q-04: Input/Output Specificity

Check: Are Input/Output formats explicitly defined with schema/structure + concrete examples (no vague "appropriately", "as needed", "etc." expressions)?
Why: Vague format specifications make integration impossible, create ambiguity, and prevent tool automation. AI/humans cannot implement against vague specs.
Examples:
- ✅ "Input: JSON {name, status}. Output: Markdown sections ## Checks, ## Issues"
- ❌ "Input as needed", "Output: comprehensive report", "etc."

---

## Q-05: Constraints Clarity

Check: Are prerequisites (tools, versions, environment) and limitations (scope, thresholds) explicit with numeric values where applicable?
Why: Explicit constraints prevent misuse in incompatible environments, set clear expectations, and enable automation to validate preconditions.
Examples:
- ✅ "Prerequisites: Git initialized, Python 3.8+. Limitations: AWS-only, max file 100MB"
- ❌ "Standard dependencies", "Handle appropriately", "Normal environment"

---

## Q-06: No Implicit Inference

Check: Are all instructions imperative and explicit with concrete conditions (no vague "appropriately", "depending on context", "reasonable")?
Why: Implicit inference forces humans/AI to guess intent, causing inconsistency and errors. Explicit instructions are reproducible and testable.
Examples:
- ✅ "If config missing, fail with error M001", "Returns exit code 1 on validation failure"
- ❌ "Handle appropriately", "Use reasonable defaults", "Depending on context"
