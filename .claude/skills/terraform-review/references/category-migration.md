# Migration & Refactor (MIG)

**MIG-01 (SHOULD): Use moved blocks to avoid resource recreation on refactors**

Check: Do refactors use moved blocks where appropriate?
Why: Resource recreation during refactoring and downtime cause service interruption, data loss, and user impact
Fix: Use `moved` block for state migration, avoid destructive changes

**MIG-02 (SHOULD): Replace deprecated resource/argument features**

Check: Are there no deprecated features in use?
Why: Using deprecated features and end-of-life APIs cause future operation failures and security risks
Fix: Replace with recommended alternatives, verify latest documentation
Note: `tflint` reports deprecated resources and arguments covered by the enabled provider ruleset. When validation output is supplied, take the status of those findings from tflint and cite it; still evaluate deprecations the ruleset does not cover (for example provider upgrade notes or deprecated module inputs).
