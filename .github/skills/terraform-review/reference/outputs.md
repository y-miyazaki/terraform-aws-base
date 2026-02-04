### 4. outputs.tf (O)

**O-01: All Outputs Require description**

- Problem: Insufficient output descriptions, unclear purpose
- Impact: Usage unclear, integration difficulties, documentation gaps
- Recommendation: Add `description` to all outputs, specify purpose and format
- Check: Every output has a description

**O-02: No Sensitive Information in Outputs**

- Problem: Plaintext sensitive information output, passwords, tokens
- Impact: Log leakage, security breach, compliance violations
- Recommendation: Set `sensitive = true`, avoid outputting secrets; ARN/ID acceptable
- Check: Sensitive values marked or not exposed

**O-03: Remove Unreferenced Outputs**

- Problem: Unnecessary output definitions, unused outputs
- Impact: Code bloat, reduced readability, maintenance burden
- Recommendation: Remove unused outputs, add when needed
- Check: All outputs are consumed somewhere
