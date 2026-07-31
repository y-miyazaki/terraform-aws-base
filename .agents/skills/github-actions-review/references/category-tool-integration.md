# Tool Integration (TOOL)

**TOOL-01 (SHOULD): Wire reviewdog for PR inline lint feedback when applicable**

Check: Is reviewdog integrated where lint results should be surfaced on pull requests?
Why: Missing PR annotations slows down feedback loops and increases review cost.
Fix: Add reviewdog integration for lint outputs and use repository token safely.

**TOOL-02 (SHOULD): Upload coverage to Codecov with a clear fail policy**

Check: Is Codecov configured with token for private repos, and without token for public repos where the Codecov app is installed?
Why: Incorrect Codecov configuration causes silent coverage gaps or failed uploads.
Fix: Configure Codecov with proper token strategy for public/private repositories.

**TOOL-03 (SHOULD): Set artifact retention intentionally (not default forever)**

Check: Are uploaded artifacts configured with explicit retention periods appropriate for use case?
Why: Default retention may be too long (cost increase) or too short (debug data loss).
Fix: Set explicit artifact retention days based on operational needs.
