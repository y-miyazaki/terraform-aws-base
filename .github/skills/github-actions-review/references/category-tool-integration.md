## 3. Tool Integration (TOOL)

**TOOL-01: PR Diff Lint (Reviewdog, etc.) Configuration**

Check: Are PR comment-based lint tools configured?
Why: Missing PR diff lint delays problem review, increases fix costs
Fix: Auto-comment on PRs with Reviewdog, etc.

**TOOL-02: Reviewdog Reporter Configuration**

Check: Is Reviewdog's `reporter` properly configured?
Why: Unspecified reporter reduces visibility, risks missed responses
Fix: Improve visibility with `reporter: github-pr-review`, etc.

**TOOL-03: Coverage Report Token Management**

Check: Are coverage tokens secretized with minimal permissions?
Why: Improper token management causes token leaks, report failures
Fix: Secretize tokens, minimize permissions, verify success

**TOOL-04: Artifact Naming and Protection**

Check: Are artifact naming conventions established and sensitive information excluded?
Why: Missing naming/retention causes storage bloat, sensitive exposure risks
Fix: Establish naming conventions, set `retention-days`, exclude sensitive data

**TOOL-05: Artifact Retention Period and Rotation**

Check: Is appropriate `retention-days` set for artifacts?
Why: Missing/excessive retention wastes storage, exposes old information
Fix: Set `retention-days`, implement periodic cleanup

**TOOL-06: actions/cache Key Design**

Check: Are cache keys designed with stable hashes and `restore-keys` present?
Why: Poor cache key design causes cache misses, rebuilds, increased time
Fix: Use `runner.os` prefix + stable hash, set `restore-keys`
