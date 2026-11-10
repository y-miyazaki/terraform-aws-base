# Guidelines Chapter Review Checks

This file contains review checks specific to the Guidelines chapter of instructions files.

## Guidelines Chapter (GUIDE)

**GUIDE-01 (SHOULD): Code Modification Guidelines**

Check: Modification procedures are clearly documented; do not embed always-run lint/validate recipes or "hooks handle it, skip lint" explanations
Why: Always-on validation recipes waste context and fight Agent hooks; unclear modification procedures still cause errors
Fix: Document domain modification procedures only; defer executable validation to skills and automation

**GUIDE-02 (SHOULD): Tool Usage**

Check: When the file directs agents to use a specific tool (CLI, MCP server, or other integration), is a usage example documented for that tool? Files that direct no specific tool pass.
Why: Missing examples cause operational variations and inefficient workflows
Fix: Add a usage example for each tool the file directs agents to use

**GUIDE-03 (SHOULD): Anti-Patterns**

Check: Common anti-patterns and pitfalls are documented
Why: Missing warnings lead to repeated mistakes
Fix: Document common anti-patterns to avoid with explanations

**GUIDE-04 (SHOULD): No ID-less Bullet Rules in Guidelines**

Check: Are there no ID-less bullet rules in the Guidelines rule groups? `### Code Modification Guidelines` is exempt — its procedural bullets may be ID-less and may cite ItemIDs inline.
Why: Rules without IDs cannot be referenced in review checklists, causing tracking gaps and audit failures
Fix: Convert rule bullets to the standard format: `- PREFIX-nn (LEVEL): title`
