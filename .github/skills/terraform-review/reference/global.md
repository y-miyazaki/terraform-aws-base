### 1. Global / Base (G)

**G-01: Variables/Outputs/Module Usage**

- Problem: Incorrect variable/output usage, undocumented module interfaces
- Impact: Unexpected configurations, errors, missed breaking changes
- Recommendation: Use context7/fetch_webpage to verify latest module documentation, use correct interfaces
- Check: External modules reference latest documentation

**G-02: Secret Hardcoding Prohibition**

- Problem: Hardcoded credentials, passwords, tokens in code
- Impact: Information leakage, Git history contamination, security breach
- Recommendation: Use variables, AWS Secrets Manager, or SSM Parameter Store
- Check: No plaintext secrets in .tf files

**G-03: External Module Versioning**

- Problem: Unspecified or outdated module versions, vulnerabilities
- Impact: Unexpected breaking changes, security risks, lack of reproducibility
- Recommendation: Check GitHub releases, pin to semantic versions
- Check: All external modules have explicit version constraints

**G-04: Provider Version Constraints**

- Problem: Unpinned provider versions, overly broad version ranges
- Impact: Breaking changes causing failures, lack of reproducibility
- Recommendation: Use `required_providers` block with appropriate version constraints (>= lower, < upper)
- Check: Provider versions are explicitly constrained

**G-05: for_each/count with Post-Apply Values**

- Problem: Using resource attributes determined after apply in for_each/count keys
- Impact: Plan-time errors ("value depends on resource attributes..."), parallel apply issues
- Recommendation: Use pre-determined values (var, local, data source known attributes)
- Check: for_each/count keys are known at plan time

**G-06: Prefer for_each over count**

- Problem: List order-dependent count usage, index shift risks
- Impact: Unexpected resource recreation, destructive changes on reordering
- Recommendation: Use for_each with unique keys; count acceptable only for toggle (0/1)
- Check: for_each used instead of count except for enable/disable flags

**G-07: Module Argument Validity**

- Problem: Missing required arguments, type mismatches, misused defaults
- Impact: Module malfunction, runtime errors, unintended behavior
- Recommendation: Verify module README/variables.tf, set correct types and values
- Check: All required module arguments provided correctly

**G-08: Module Output Usage**

- Problem: Unused outputs defined, needed outputs missing
- Impact: Integration issues, code bloat, reduced readability
- Recommendation: Output only necessary values, remove unreferenced outputs
- Check: Outputs match actual usage patterns

**G-09: tfsec → trivy Migration**

- Problem: Using deprecated tfsec, missing latest vulnerability detection
- Impact: Missed security vulnerabilities, reduced CI/CD quality
- Recommendation: Migrate to Trivy, integrate into CI/CD pipeline
- Check: No tfsec references; trivy in use
