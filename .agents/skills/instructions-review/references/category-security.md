## Security Guidelines Chapter Review Checks

This file contains review checks specific to the Security Guidelines chapter of instructions files.

## Security Guidelines Chapter (SEC)

**SEC-01 (MUST): Tool-Undetectable Risks Documented**

Check: Are security practices that automated tools (gitleaks, detect-secrets) cannot detect documented (e.g., destructive command defaults, untrusted link sources)?
Why: Automated scanners handle secrets and credentials; instructions must cover risks that require human/AI judgment
Fix: Document security items that CI/pre-commit cannot detect (unsafe defaults, link trust, privilege assumptions)

**SEC-02 (MUST): Secrets Management**

Check: Is a policy against embedding secrets in instruction files documented?
Why: Missing guidelines risk credential leakage and authentication information exposure
Fix: Document that secrets must not appear in instruction files (reference environment variables or secret managers)

**SEC-03 (MUST): Scope Limited to Document Safety**

Check: Are security items limited to documentation-specific risks rather than duplicating what CI/pre-commit tools enforce?
Why: Duplicating tool-enforceable rules bloats instructions and creates false sense of coverage
Fix: Remove items already enforced by gitleaks/detect-secrets/CI and keep only document-safety concerns

**SEC-04 (SHOULD): Examples**

Check: YAML/code examples are included (where applicable)
Why: Missing examples lead to implementation errors and unclear best practices
Fix: Add YAML/code examples where needed
