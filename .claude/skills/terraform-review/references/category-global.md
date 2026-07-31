# Global / Base (G)

**G-01 (MUST): No secrets hardcoded in Terraform code**

Check: Are there no plaintext secrets in .tf files?
Why: Hardcoded credentials, passwords, and tokens cause information leakage, Git history contamination, and security breaches
Fix: Use variables, AWS Secrets Manager, or SSM Parameter Store

**G-02 (SHOULD): Version-constrain external modules**

Check: Do all external modules have explicit version constraints?
Why: Unspecified or outdated module versions cause unexpected breaking changes, security risks, and lack of reproducibility
Fix: Check GitHub releases, pin to semantic versions

**G-03 (SHOULD): Constrain providers with lower and upper version bounds**

Check: Are provider versions explicitly constrained?
Why: Unpinned provider versions and overly broad version ranges cause breaking changes, failures, and lack of reproducibility
Fix: Use `required_providers` block with appropriate version constraints (>= lower, < upper)

**G-04 (MUST): Do not drive for_each/count with post-apply unknown values**

Check: Are for_each/count keys known at plan time?
Why: Using resource attributes determined after apply in for_each/count keys causes plan-time errors ("value depends on resource attributes...") and parallel apply issues
Fix: Use pre-determined values (var, local, data source known attributes)

**G-05 (MUST): Prefer for_each over count for keyed instances**

Check: Is for_each used instead of count except for enable/disable flags?
Why: List order-dependent count usage creates index shift risks, causing unexpected resource recreation and destructive changes on reordering
Fix: Use for_each with unique keys; count acceptable only for toggle (0/1)
