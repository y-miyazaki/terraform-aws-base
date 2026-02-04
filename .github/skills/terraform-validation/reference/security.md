# Terraform Validation - Security Best Practices

## Required Security Measures

- ✅ KMS encryption for S3, SNS, Logs, State Machines
- ✅ IAM policies follow least privilege
- ✅ Resource policies include Condition clauses
- ✅ No plaintext secrets
- ✅ Logging enabled
- ✅ No default VPC usage
- ✅ No open security groups
- ✅ No public S3 buckets

## trivy Severity Levels

- **CRITICAL**: Immediate fix required
- **HIGH**: Fix before production
- **MEDIUM**: Fix in next iteration
- **LOW**: Consider fixing

See main [SKILL.md](../SKILL.md) for comprehensive validation workflow.
