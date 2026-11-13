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

**MIG-03 (SHOULD): State-address changes are called out with their migration path**

Check: When a change alters resource addresses (`count` to `for_each`, key changes, renames, moving into a module), is the migration path stated, and is it correct for the keys involved? `moved` blocks cannot target dynamically computed keys
Why: Address changes plan as destroy and create. For security-sensitive, permission-bearing or stateful resources this can detach permissions, break connections or lose data, even when the final configuration is right
Fix: Use `moved` blocks where the new address is static, otherwise document the `terraform state mv` steps; call out resources whose destroy and create has runtime impact and ask for a `terraform plan` review before apply
