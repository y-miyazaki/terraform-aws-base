# Terraform Validation - Security Remediation Guide

Use this guide when the trivy step (`trivy fs`) reports security findings. The step prints findings but does not fail on them, so apply this policy as reviewer guidance.

## Severity Handling Policy

- **CRITICAL**: Fix before merge; flag it as blocking in the report.
- **HIGH**: Fix before merge; flag it as blocking in the report.
- **MEDIUM**: Fix in the current or next planned change window.
- **LOW**: Fix when practical and track in backlog if deferred.

## Common trivy Findings and Fixes

### Public Storage Access

**Typical finding**: storage allows public principals or public access is not blocked.

**Fix**: Enable the provider's block-public-access setting and remove public principals from policies.

### Missing Encryption at Rest

**Typical finding**: storage, disks, databases, or log targets missing encryption settings.

**Fix**: Enable encryption at rest and set the managed-key argument explicitly.

### Overly Permissive Access Policies

**Typical finding**: wildcards in actions or resources without strict conditions.

**Fix**: Limit actions and resources to what is required and add condition guards.

### Firewall Rule Open to Internet

**Typical finding**: inbound rules expose sensitive ports to `0.0.0.0/0`.

**Fix**: Restrict source CIDRs to known ranges. Avoid unrestricted inbound SSH/RDP unless explicitly required and documented.

## Revalidation Commands

After applying fixes, rerun validation with the standard script:

```bash
bash scripts/validate.sh
```

For faster feedback on specific directories:

```bash
bash scripts/validate.sh <terraform-dir-1> <terraform-dir-2>
```

## Escalation Rule

- If a finding cannot be fixed immediately (for operational reasons), add documented justification and compensating controls in code review.
- Do not suppress CRITICAL or HIGH findings without explicit approval.
