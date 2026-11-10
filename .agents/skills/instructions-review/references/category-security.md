# Security Guidelines Chapter Review Checks

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

Check: When a security rule requires a specific non-obvious form (for example a secret reference syntax or a safe default value), is a short YAML/code example included? Rules that are clear from their wording do not need one.
Why: Missing examples for non-obvious forms lead to implementation errors; examples for self-evident rules waste always-on tokens
Fix: Add a minimal YAML/code example only for security rules whose correct form is not self-evident
