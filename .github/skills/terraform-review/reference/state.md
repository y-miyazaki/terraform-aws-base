### 13. State & Backend (STATE)

**STATE-01: Remote Backend with Encryption (SSE) + DynamoDB Lock**

- Problem: Insufficient state protection, no encryption, missing lock mechanism
- Impact: Conflicts, corruption, information leak risk
- Recommendation: Enable S3 encryption + DynamoDB lock, set versioning
- Check: Backend configured with encryption and locking

**STATE-02: No Credentials in Backend Configuration**

- Problem: Credentials in backend config, hardcoded access keys
- Impact: Leak risk, security breach, Git history contamination
- Recommendation: Use environment variables, IAM roles, profiles
- Check: No hardcoded credentials in backend blocks

**STATE-03: No Workspace (Unless Documented)**

- Problem: Inappropriate workspace usage, ambiguous environment separation
- Impact: Environment confusion, misdeployment
- Recommendation: Recommend directory-based environment separation, document workspace usage policy
- Check: Workspaces not used or policy is documented

**STATE-04: terraform state Manual Operations Documented**

- Problem: Manual operations as black box, no records
- Impact: Operational risk, non-reproducible, troubleshooting difficulties
- Recommendation: Record operation procedures/reasons, manage change history
- Check: State modifications are documented
