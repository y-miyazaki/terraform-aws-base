## 17. Migration & Refactor (MIG)

**MIG-01: Use moved Block to Avoid Resource Recreation**

Check: Do refactors use moved blocks where appropriate?
Why: Resource recreation during refactoring and downtime cause service interruption, data loss, and user impact
Fix: Use `moved` block for state migration, avoid destructive changes

**MIG-02: Replace Deprecated Features**

Check: Are there no deprecated features in use?
Why: Using deprecated features and end-of-life APIs cause future operation failures and security risks
Fix: Replace with recommended alternatives, verify latest documentation

**MIG-03: No Commented-Out Resources**

Check: Are there no commented-out resource blocks?
Why: Commented-out code and dead code cause reduced readability and confusion
Fix: Delete unnecessary code, use Git history, perform cleanup
