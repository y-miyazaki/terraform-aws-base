### 5. tfvars (T)

**T-01: No Secrets in tfvars**

- Problem: Secrets in tfvars, passwords, tokens
- Impact: Repository leak risk, Git history contamination, security breach
- Recommendation: Reference external secret stores (data sources), use environment variables
- Check: No hardcoded secrets in tfvars files

**T-02: Environment-Specific File Separation**

- Problem: Mixed environment configs, single tfvars file
- Impact: Misdeployment risk, environment contamination, operational errors
- Recommendation: Separate files per environment (dev.tfvars, prd.tfvars)
- Check: Clear environment-specific file separation

**T-03: No Cross-Environment Identifiers**

- Problem: Cross-environment ID mixing, incorrect IDs from other environments
- Impact: Cross-environment contamination, unintended resource references
- Recommendation: Only environment-specific values, validate variables/locals
- Check: No foreign environment IDs (account IDs, VPC IDs, etc.)

**T-04: No Environment Prefix Mixing**

- Problem: Incorrect environment prefixes, naming inconsistencies
- Impact: Resource naming errors, identification difficulties, operational confusion
- Recommendation: Verify correct environment prefix, follow naming rules
- Check: Consistent environment prefixes throughout
