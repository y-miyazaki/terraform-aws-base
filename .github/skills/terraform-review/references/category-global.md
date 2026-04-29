## 1. Global / Base (G)

**G-01: Variables/Outputs/Module Usage**

Check: Do external modules reference latest documentation?
Why: Incorrect variable/output usage and undocumented module interfaces cause unexpected configurations, errors, and missed breaking changes
Fix: Use context7/fetch_webpage to verify latest module documentation, use correct interfaces

**G-02: Secret Hardcoding Prohibition**

Check: Are there no plaintext secrets in .tf files?
Why: Hardcoded credentials, passwords, and tokens cause information leakage, Git history contamination, and security breaches
Fix: Use variables, AWS Secrets Manager, or SSM Parameter Store

**G-03: External Module Versioning**

Check: Do all external modules have explicit version constraints?
Why: Unspecified or outdated module versions cause unexpected breaking changes, security risks, and lack of reproducibility
Fix: Check GitHub releases, pin to semantic versions

**G-04: Provider Version Constraints**

Check: Are provider versions explicitly constrained?
Why: Unpinned provider versions and overly broad version ranges cause breaking changes, failures, and lack of reproducibility
Fix: Use `required_providers` block with appropriate version constraints (>= lower, < upper)

**G-05: for_each/count with Post-Apply Values**

Check: Are for_each/count keys known at plan time?
Why: Using resource attributes determined after apply in for_each/count keys causes plan-time errors ("value depends on resource attributes...") and parallel apply issues
Fix: Use pre-determined values (var, local, data source known attributes)

**G-06: Prefer for_each over count**

Check: Is for_each used instead of count except for enable/disable flags?
Why: List order-dependent count usage creates index shift risks, causing unexpected resource recreation and destructive changes on reordering
Fix: Use for_each with unique keys; count acceptable only for toggle (0/1)

**G-07: Module Argument Validity**

Check: Are all required module arguments provided correctly?
Why: Missing required arguments, type mismatches, and misused defaults cause module malfunction, runtime errors, and unintended behavior
Fix: Verify module README/variables.tf, set correct types and values

**G-08: Module Output Usage**

Check: Do outputs match actual usage patterns?
Why: Unused outputs defined and needed outputs missing cause integration issues, code bloat, and reduced readability
Fix: Output only necessary values, remove unreferenced outputs

**G-09: tfsec → trivy Migration**

Check: Are there no tfsec references; is trivy in use?
Why: Using deprecated tfsec causes missed security vulnerabilities and reduced CI/CD quality
Fix: Migrate to Trivy, integrate into CI/CD pipeline
