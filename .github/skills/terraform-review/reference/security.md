### 6. Security (SEC)

**Note**: The following security guidelines are AWS-specific. For multi-cloud repositories, verify the cloud provider context before applying.

**SEC-01: KMS Encryption (SNS/S3/Logs/StateMachines) [AWS-specific]**

- Problem: Missing encryption, plaintext data storage
- Impact: Data leak risk, compliance violations, audit failures
- Recommendation: Enable CMK/AWS managed key encryption, set kms_key_id
- Check: Encryption enabled for sensitive resources

**SEC-02: IAM Least Privilege**

- Problem: Excessive permissions, wildcard (\*) overuse
- Impact: Increased damage on breach, privilege escalation, information leakage
- Recommendation: Limit to necessary actions/resources, document reason for `*` usage
- Check: IAM policies follow least privilege; wildcards justified

**SEC-03: Resource Policy with Condition**

- Problem: Insufficient resource policy restrictions, missing Condition
- Impact: Unintended source access, unauthorized use, security risks
- Recommendation: Add `Condition` block with `SourceArn`/`SourceAccount` restrictions
- Check: Resource policies (SNS, SQS) include appropriate conditions

**SEC-04: No Plaintext Secrets**

- Problem: Plaintext secrets in code, hardcoded credentials
- Impact: Leak risk, Git history persistence, security breach
- Recommendation: Use Secrets Manager/SSM Parameter Store, reference via data sources
- Check: All secrets retrieved from secure stores

**SEC-05: Appropriate Logging Configuration**

- Problem: Inadequate logging, disabled log output, improper retention
- Impact: No audit trail, troubleshooting difficulties, compliance violations
- Recommendation: Proper log output/retention settings, CloudWatch Logs integration
- Check: CloudTrail, CloudWatch Logs properly configured
