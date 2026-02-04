### 17. Migration & Refactor (MIG)

**MIG-01: Use moved Block to Avoid Resource Recreation**

- Problem: Resource recreation during refactoring, downtime
- Impact: Service interruption, data loss, user impact
- Recommendation: Use `moved` block for state migration, avoid destructive changes
- Check: Refactors use moved blocks where appropriate

**MIG-02: Replace Deprecated Features**

- Problem: Using deprecated features, end-of-life APIs
- Impact: Future operation failures, security risks
- Recommendation: Replace with recommended alternatives, verify latest documentation
- Check: No deprecated features in use

**MIG-03: No Commented-Out Resources**

- Problem: Commented-out code, dead code
- Impact: Reduced readability, confusion
- Recommendation: Delete unnecessary code, use Git history, cleanup
- Check: No commented-out resource blocks
