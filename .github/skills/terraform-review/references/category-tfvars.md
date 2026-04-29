## 5. tfvars (T)

**T-01: No Secrets in tfvars**

Check: Are there no hardcoded secrets in tfvars files?
Why: Secrets in tfvars (passwords, tokens) cause repository leak risk, Git history contamination, and security breaches
Fix: Reference external secret stores (data sources), use environment variables

**T-02: Environment-Specific File Separation**

Check: Is there clear environment-specific file separation?
Why: Mixed environment configs and single tfvars files cause misdeployment risk, environment contamination, and operational errors
Fix: Separate files per environment (dev.tfvars, prd.tfvars)

**T-03: No Cross-Environment Identifiers**

Check: Are there no foreign environment IDs (account IDs, VPC IDs, etc.)?
Why: Cross-environment ID mixing and incorrect IDs from other environments cause cross-environment contamination and unintended resource references
Fix: Use only environment-specific values, validate variables/locals

**T-04: No Environment Prefix Mixing**

Check: Are environment prefixes consistent throughout?
Why: Incorrect environment prefixes and naming inconsistencies cause resource naming errors, identification difficulties, and operational confusion
Fix: Verify correct environment prefix, follow naming rules
