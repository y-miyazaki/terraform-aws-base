## 6. Security (SEC)

**Note**: The following security guidelines are AWS-specific. For multi-cloud repositories, verify the cloud provider context before applying.

**SEC-01: KMS Encryption (SNS/S3/Logs/StateMachines) [AWS-specific]**

Check: Is encryption enabled for sensitive resources?
Why: Missing encryption and plaintext data storage cause data leak risk, compliance violations, and audit failures
Fix: Enable CMK/AWS managed key encryption, set kms_key_id

**SEC-02: IAM Least Privilege**

Check: Do IAM policies follow least privilege; are wildcards justified?
Why: Excessive permissions and wildcard (\*) overuse increase damage on breach, enable privilege escalation, and cause information leakage
Fix: Limit to necessary actions/resources, document reason for `*` usage

**SEC-03: Resource Policy with Condition**

Check: Do resource policies (SNS, SQS) include appropriate conditions?
Why: Insufficient resource policy restrictions and missing Condition blocks allow unintended source access, unauthorized use, and security risks
Fix: Add `Condition` block with `SourceArn`/`SourceAccount` restrictions

**SEC-04: No Plaintext Secrets**

Check: Are all secrets retrieved from secure stores?
Why: Plaintext secrets in code and hardcoded credentials cause leak risk, Git history persistence, and security breaches
Fix: Use Secrets Manager/SSM Parameter Store, reference via data sources

**SEC-05: Appropriate Logging Configuration**

Check: Are CloudTrail and CloudWatch Logs properly configured?
Why: Inadequate logging, disabled log output, and improper retention leave no audit trail, create troubleshooting difficulties, and cause compliance violations
Fix: Configure proper log output/retention settings, integrate CloudWatch Logs
