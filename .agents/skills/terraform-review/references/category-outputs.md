## outputs.tf (O)

**O-01 (SHOULD): Every output has a description**

Check: Does every output have a description?
Why: Insufficient output descriptions and unclear purpose make usage unclear, cause integration difficulties, and create documentation gaps
Fix: Add `description` to all outputs, specify purpose and format

**O-02 (SHOULD): Outputs do not expose secrets (or mark sensitive)**

Check: Are sensitive values marked or not exposed?
Why: Plaintext sensitive information output (passwords, tokens) causes log leakage, security breaches, and compliance violations
Fix: Set `sensitive = true`, avoid outputting secrets; ARN/ID acceptable
