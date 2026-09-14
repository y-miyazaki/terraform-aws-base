# Anti-Patterns (AP)

**AP-01 (MUST): Plaintext secrets in Terraform code or tfvars**

Check: Are passwords, API keys, or tokens present in `.tf`, `.tfvars`, or `.hcl` files (G-01, SEC-04, T-01)?
Why: Secrets in version control leak via history, clones, and CI logs
Fix: Use variables with external secret stores (Secrets Manager, SSM Parameter Store) — never commit literals

**AP-02 (SHOULD): count for keyed resources instead of for_each**

Check: Is `count` used for named or keyed instances where list order can change (G-05)?
Why: Index shifts recreate resources and cause destructive plan diffs on reorder
Fix: Use `for_each` with stable keys; reserve `count` for simple enable/disable toggles

**AP-03 (SHOULD): Credentials embedded in backend configuration**

Check: Are access keys or tokens hardcoded in `backend` blocks (STATE-02)?
Why: Backend config is often committed; embedded credentials spread with the repository
Fix: Use environment variables, OIDC, or provider-specific credential chains

**AP-04 (MUST): Unsafe defaults for network exposure**

Check: Do resources default to open security groups, public S3 buckets, or default VPC (COMP-01)?
Why: Unsafe defaults expand attack surface and violate least-privilege policy
Fix: Explicit VPC/subnet references, restrictive SG rules, and `block_public_access` on S3

**AP-05 (SHOULD): Hand-written IAM policy JSON strings**

Check: Are IAM policies built as raw JSON strings instead of `jsonencode` or `aws_iam_policy_document` (COMP-02)?
Why: String JSON is error-prone and harder to validate at plan time
Fix: Use `jsonencode()` or the `aws_iam_policy_document` data source
