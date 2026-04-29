## 13. State & Backend (STATE)

**STATE-01: Remote Backend with Encryption (SSE) + DynamoDB Lock**

Check: Is backend configured with encryption and locking?
Why: Insufficient state protection, no encryption, and missing lock mechanism cause conflicts, corruption, and information leak risk
Fix: Enable S3 encryption + DynamoDB lock, set versioning

**STATE-02: No Credentials in Backend Configuration**

Check: Are there no hardcoded credentials in backend blocks?
Why: Credentials in backend config and hardcoded access keys cause leak risk, security breach, and Git history contamination
Fix: Use environment variables, IAM roles, profiles

**STATE-03: No Workspace (Unless Documented)**

Check: Are workspaces not used or is policy documented?
Why: Inappropriate workspace usage and ambiguous environment separation cause environment confusion and misdeployment
Fix: Recommend directory-based environment separation, document workspace usage policy

**STATE-04: terraform state Manual Operations Documented**

Check: Are state modifications documented?
Why: Manual operations as black box and no records cause operational risk, non-reproducible operations, and troubleshooting difficulties
Fix: Record operation procedures/reasons, manage change history
