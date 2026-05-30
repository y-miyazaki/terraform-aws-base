## State & Backend (STATE)

**STATE-01 (SHOULD): Remote Backend with Encryption (SSE) + DynamoDB Lock**

Check: Is backend configured with encryption and locking?
Why: Unprotected state risks data leakage and concurrent modification corruption
Fix: Enable S3 encryption + DynamoDB lock, set versioning

**STATE-02 (SHOULD): No Credentials in Backend Configuration**

Check: Are there no hardcoded credentials in backend blocks?
Why: Credentials in backend config leak via Git history and violate security policies
Fix: Use environment variables, IAM roles, or profiles

**STATE-03 (SHOULD): No Workspace (Unless Documented)**

Check: Are workspaces not used, or is workspace usage policy documented in comments?
Why: Inappropriate workspace usage causes environment confusion and misdeployment
Fix: Prefer directory-based environment separation; if workspaces are used, document the rationale
