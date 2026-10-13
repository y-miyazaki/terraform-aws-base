# Security (SEC)

**SEC-01 (SHOULD): Enable encryption at rest with managed keys for sensitive resources**

Check: Is encryption enabled for sensitive resources?
Why: Missing encryption and plaintext data storage cause data leak risk, compliance violations, and audit failures
Fix: Enable provider-managed or customer-managed key encryption and set the key argument explicitly

**SEC-02 (SHOULD): Access policies follow least privilege**

Check: Do Access policies follow least privilege; are wildcards justified?
Why: Excessive permissions and wildcard (\*) overuse increase damage on breach, enable privilege escalation, and cause information leakage
Fix: Limit to necessary actions/resources, document reason for `*` usage

**SEC-03 (SHOULD): Resource policies include Condition guards**

Check: Do resource policies include appropriate conditions?
Why: Insufficient resource policy restrictions and missing Condition blocks allow unintended source access, unauthorized use, and security risks
Fix: Add condition guards that restrict the source account/resource

**SEC-04 (MUST): No plaintext secrets in code or state-bound literals**

Check: Are all secrets retrieved from secure stores?
Why: Plaintext secrets in code and hardcoded credentials cause leak risk, Git history persistence, and security breaches
Fix: Use a secret manager or parameter store, reference via data sources

**SEC-05 (SHOULD): Enable appropriate audit/access logging for sensitive resources**

Check: Are audit and access logs properly configured?
Why: Inadequate logging, disabled log output, and improper retention leave no audit trail, create troubleshooting difficulties, and cause compliance violations
Fix: Configure proper log output/retention settings, integrate with the platform log service
