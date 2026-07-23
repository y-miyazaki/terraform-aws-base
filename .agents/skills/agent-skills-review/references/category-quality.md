## Quality Checks (Q)

**Q-01 (SHOULD): Output is Truly Structured**

Check: Is the output format definition implementable and parseable (JSON schema / Markdown structure explicitly defined with example)?
Why: Unstructured output prevents tool automation, integration, and parsing. AI/humans cannot reliably extract results without explicit format definition.
Examples:

- ✅ "Markdown structure: ## Checks Summary + ## Issues" or "JSON schema: {status, errors[], warnings[]}"
- ❌ "Output will be a comprehensive report" (no structure defined)

---

**Q-02 (SHOULD): Scope Boundaries**

Check: Is Execution Scope split into "What this skill does" (action list) + "Out of Scope" (explicit non-actions with tool delegation)?
Why: Scope clarity prevents skill misuse, reduces ambiguity about responsibility boundaries, and clarifies tool/skill separation.
Examples:

- ✅ "Does: Review design. Does NOT: Run syntax checks (yamllint's responsibility)"
- ❌ Only "Does" section or implicit scope ("Not responsible for X")

---

**Q-03 (SHOULD): Execution Determinism**

Check: Is execution path single/canonical OR are conditional branches explicitly defined (IF condition → path A, ELSE → path B)?
Why: Deterministic execution prevents surprises, enables reproducibility, and allows automation. Ambiguous conditions cause inconsistent behavior across different uses.
Examples:

- ✅ "Step 1: Parse. Step 2: Validate. Step 3: Report" OR "IF error severity=CRITICAL, halt. ELSE continue"
- ❌ "Behavior varies depending on context" (no conditions specified)

---

**Q-04 (SHOULD): Input/Output Specificity**

Check: Are Input/Output formats explicitly defined with schema/structure + concrete examples (no vague "appropriately", "as needed", "etc." expressions)?
Why: Vague format specifications make integration impossible, create ambiguity, and prevent tool automation. AI/humans cannot implement against vague specs.
Examples:

- ✅ "Input: JSON {name, status}. Output: Markdown sections ## Overview and ## Changes"
- ✅ "Input: PR number. Output contract summarized in Output Specification and detailed in references/common-output-format.md"
- ❌ "Input as needed", "Output: comprehensive report", "etc."

---

**Q-05 (SHOULD): Constraints Clarity**

Check: Are project-specific, non-obvious constraints documented while self-evident constraints are omitted?
Why: Self-evident constraints (e.g., "tool must be installed") waste tokens and add noise. Project-specific constraints (e.g., "coverage threshold 80%", "AWS-only") are what the agent wouldn't know without being told.
Examples:

- ✅ "Test coverage threshold: 80%" (project-specific, non-obvious)
- ✅ No Constraints section when all prerequisites are self-evident (tool installation, file existence)
- ❌ "Go toolchain installed and available in PATH" (self-evident, Claude already knows)
- ❌ "Cannot validate code that doesn't compile" (self-evident)

---

**Q-06 (MUST): No Implicit Inference**

Check: Are all instructions imperative and explicit with concrete conditions (no vague "appropriately", "depending on context", "reasonable")?
Why: Implicit inference forces humans/AI to guess intent, causing inconsistency and errors. Explicit instructions are reproducible and testable.
Examples:

- ✅ "If config missing, fail with error M001", "Returns exit code 1 on validation failure"
- ❌ "Handle appropriately", "Use reasonable defaults", "Depending on context"

---

**Q-09 (SHOULD): Token Budget Advisory**

Check: Does the review include `waza check` token evidence? When Token Budget exceeds 500 tokens, record an advisory note in `## Issues` (not a structural FAIL) unless sibling skills in the same package were compressed in isolation.
Why: External tooling may warn above ~500 tokens; that is **advisory**. Sibling `SKILL.md` documentation-level consistency outranks isolated token compression (per package sibling-consistency policy for skills in the same package). Do not mark Q-09 Failed solely for token count when structure and reference-load contracts meet package norms.
Examples:

- ✅ `waza check` shows 612 / 500 — Q-09 noted in `## Issues` as advisory; sibling loop skills are at similar depth
- ✅ Token within budget — Q-09 Passed or omitted from failed table
- ❌ Token over budget with no `waza check` evidence
- ❌ One skill compressed below 500 while siblings remain full-depth (BP-04 / sibling drift risk — flag in Issues)

---

**BP-03 (SHOULD): Token Efficiency**

Check: Does SKILL.md avoid content that Claude already knows, minimizing redundancy with frontmatter and reference files?
Why: Every token competes for context window attention. Redundant content dilutes the agent's focus on project-specific instructions. Claude's official best practice: "Would the agent get this wrong without this instruction? If no, cut it."
Examples:

- ✅ No Purpose section (duplicates description field)
- ✅ No When to Use section (duplicates description "Use when..." trigger)
- ✅ No self-evident Constraints section
- ✅ No general Failure Behavior section (standard tool behavior)
- ✅ No Available Review Categories section (duplicates Reference Files Guide)
- ❌ Purpose section that restates the description
- ❌ Constraints listing "Go toolchain installed", "Files must exist"
- ❌ Failure Behavior listing standard exit codes and error messages

---

**BP-04 (SHOULD): Anti-Overtrimming Guardrail**

Check: If token reduction is applied, are behavior-defining instructions preserved?
Why: Over-aggressive trimming can make a skill unreadable to the agent, reducing activation quality and causing execution errors even when token limits pass.
Examples:

- ✅ Trigger blocks still explicit (`Use when...`, `USE FOR`, `DO NOT USE FOR`)
- ✅ Output contract still structured and consistent (`Output Specification` + `common-output-format.md`)
- ✅ Workflow still deterministic with numbered steps or explicit IF/THEN branches
- ✅ At least one concrete example remains
- ❌ Token-only edit removed trigger clarity or deleted examples

---

**Q-10 (SHOULD): Error Handling Completeness**

Check: Does the Workflow define what happens when things go wrong — with explicit severity (recoverable/fatal/blocking) and action for each failure mode?
Why: Skills without error handling cause agents to silently fail or hallucinate recovery paths. Explicit error tables make behavior predictable and debuggable.
Examples:

- ✅ Error handling table with columns: Condition | Severity | Action
- ✅ At least fatal (stop) and recoverable (fallback + continue) cases defined
- ❌ Only "read troubleshooting.md on failure" with no inline guidance
- ❌ No mention of what happens when inputs are invalid or dependencies are missing

---

**Q-11 (SHOULD): Input Parameter Consistency**

Check: Are parameters marked "required" truly required (no default fallback), and parameters with defaults marked as optional?
Why: Contradictions between "required" and "use X when unsure" confuse agents and create inconsistent behavior. Parameters with sensible defaults should be optional.
Examples:

- ✅ "profile: `default`, `go`, or `terraform` (defaults to `default`; affects X only)"
- ✅ "target_file: path (required for `other` and `general` types)" — conditionally required is explicit
- ❌ "profile: required" but also "use default when unsure" — contradicts required semantics

---

**Q-12 (SHOULD): Cross-Section Consistency**

Check: Are definitions across sections (Input, Output Specification, Workflow, Reference Files Guide) free of mutual contradiction?
Why: Contradictions between sections (e.g., Input declares a parameter optional but Workflow treats it as required) cause non-deterministic agent behavior
Examples:

- ✅ Input says "profile: optional (default: default)" and Workflow uses fallback logic when profile is absent
- ❌ Input says "required" but Workflow says "skip if not provided"
- ❌ Output Specification defines a field that common-output-format.md omits
