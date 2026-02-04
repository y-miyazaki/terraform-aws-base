### 14. Compliance & Policy (COMP)

**COMP-01: Organization/Security Hub Governance Alignment**

- Problem: Organization policy violations, governance inconsistencies
- Impact: Compliance violations, audit failures, security risks
- Recommendation: Comply with organizational governance rules, verify policies
- Check: Configuration aligns with organizational policies

**COMP-02: trivy Results in Pipeline**

- Problem: Insufficient security check automation, manual scanning
- Impact: Vulnerability introduction, quality degradation
- Recommendation: Integrate Trivy scan in pipeline, set gates
- Check: trivy scan is part of CI/CD

**COMP-03: No Default VPC/Open SG/Public S3**

- Problem: Unsafe default settings, excessive exposure
- Impact: Expanded attack surface, information leakage
- Recommendation: Explicit secure settings, minimal exposure principle, prefer private
- Check: No use of default VPC, security groups are restrictive, S3 buckets private

**COMP-04: IAM Policy with jsonencode or aws_iam_policy_document**

- Problem: String concatenation policy generation, hand-written JSON
- Impact: Syntax errors, reduced readability, maintenance difficulties
- Recommendation: Use `jsonencode` or data source `aws_iam_policy_document`
- Check: IAM policies use structured approaches
