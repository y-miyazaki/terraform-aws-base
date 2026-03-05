## 4. outputs.tf (O)

**O-01: All Outputs Require description**

Check: Does every output have a description?
Why: Insufficient output descriptions and unclear purpose make usage unclear, cause integration difficulties, and create documentation gaps
Fix: Add `description` to all outputs, specify purpose and format

**O-02: No Sensitive Information in Outputs**

Check: Are sensitive values marked or not exposed?
Why: Plaintext sensitive information output (passwords, tokens) causes log leakage, security breaches, and compliance violations
Fix: Set `sensitive = true`, avoid outputting secrets; ARN/ID acceptable

**O-03: Remove Unreferenced Outputs**

Check: Are all outputs consumed somewhere?
Why: Unnecessary output definitions and unused outputs cause code bloat, reduced readability, and maintenance burden
Fix: Remove unused outputs, add when needed
