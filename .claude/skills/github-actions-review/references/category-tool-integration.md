## Tool Integration (TOOL)

**TOOL-01 (SHOULD): Reviewdog Integration for PR Feedback**

Check: Is reviewdog integrated where lint results should be surfaced on pull requests?
Why: Missing PR annotations slows down feedback loops and increases review cost.
Fix: Add reviewdog integration for lint outputs and use repository token safely.

**TOOL-02 (SHOULD): Codecov Coverage Upload Strategy**

Check: Is Codecov usage configured appropriately for repository visibility and token requirements?
Why: Incorrect Codecov configuration causes silent coverage gaps or failed uploads.
Fix: Configure Codecov with proper token strategy for public/private repositories.

**TOOL-03 (SHOULD): Artifact Retention Configuration**

Check: Are uploaded artifacts configured with explicit retention periods appropriate for use case?
Why: Default retention may be too long (cost increase) or too short (debug data loss).
Fix: Set explicit artifact retention days based on operational needs.

**TOOL-04 (SHOULD): Cache Key and Restore Strategy**

Check: Are cache keys based on lockfiles and restore-keys configured for safe fallback?
Why: Weak cache key design causes stale dependencies, flaky builds, and low cache hit rates.
Fix: Use lockfile hashes for primary keys and controlled restore-keys for fallback.
