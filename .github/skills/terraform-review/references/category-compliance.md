## 14. Compliance & Policy (COMP)

**COMP-01: Organization/Security Hub Governance Alignment**

Check: Does configuration align with organizational policies?
Why: Organization policy violations and governance inconsistencies cause compliance violations, audit failures, and security risks
Fix: Comply with organizational governance rules, verify policies

**COMP-02: trivy Results in Pipeline**

Check: Is trivy scan part of CI/CD?
Why: Insufficient security check automation and manual scanning cause vulnerability introduction and quality degradation
Fix: Integrate Trivy scan in pipeline, set gates

**COMP-03: No Default VPC/Open SG/Public S3**

Check: Is there no use of default VPC, are security groups restrictive, are S3 buckets private?
Why: Unsafe default settings and excessive exposure cause expanded attack surface and information leakage
Fix: Use explicit secure settings, apply minimal exposure principle, prefer private

**COMP-04: IAM Policy with jsonencode or aws_iam_policy_document**

Check: Do IAM policies use structured approaches?
Why: String concatenation policy generation and hand-written JSON cause syntax errors, reduced readability, and maintenance difficulties
Fix: Use `jsonencode` or data source `aws_iam_policy_document`
