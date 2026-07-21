## Guidelines Chapter Review Checks

This file contains review checks specific to the Guidelines chapter of instructions files.

## Guidelines Chapter (GUIDE)

**GUIDE-01 (SHOULD): Code Modification Guidelines**

Check: Modification procedures are clearly documented; do not embed always-run lint/validate recipes or "hooks handle it, skip lint" explanations
Why: Always-on validation recipes waste context and fight Agent hooks; unclear modification procedures still cause errors
Fix: Document domain modification procedures only; defer executable validation to skills and automation

**GUIDE-02 (SHOULD): Tool Usage**

Check: MCP Tool usage examples are documented
Why: Missing examples cause operational variations and inefficient workflows
Fix: Add MCP Tool usage examples (where applicable)

**GUIDE-03 (SHOULD): Anti-Patterns**

Check: Common anti-patterns and pitfalls are documented
Why: Missing warnings lead to repeated mistakes
Fix: Document common anti-patterns to avoid with explanations

**GUIDE-04 (SHOULD): No ID-less Bullet Rules in Guidelines**

Check: Are there no ID-less bullet rules in the Guidelines chapter?
Why: Rules without IDs cannot be referenced in review checklists, causing tracking gaps and audit failures
Fix: Convert all bullet rules to the standard format: `**ID (LEVEL)**: rule — rationale`
