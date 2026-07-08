## Compliance & Policy (COMP)

**COMP-03 (MUST): No Default VPC/Open SG/Public S3**

Check: Is there no use of default VPC, are security groups restrictive, and are S3 buckets private by default?
Why: Unsafe default settings expand attack surface and risk information leakage
Fix: Use explicit VPC/subnet references, restrict ingress/egress rules, set block_public_access on S3

**COMP-04 (MUST): IAM Policy with jsonencode or aws_iam_policy_document**

Check: Do IAM policies use jsonencode() or aws_iam_policy_document data source?
Why: Hand-written JSON strings cause syntax errors, reduce readability, and prevent static validation
Fix: Use `jsonencode` for simple policies or `aws_iam_policy_document` data source for complex ones
