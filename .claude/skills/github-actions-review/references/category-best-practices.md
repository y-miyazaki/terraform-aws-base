## Best Practices (BP)

**BP-01 (SHOULD): Reusable Workflow Design**

Check: Are common processes extracted into reusable workflows or composite actions?
Why: Manual workflow copying increases maintenance costs, causes feature divergence
Fix: Extract to reusable workflows/composite actions

**BP-02 (SHOULD): DRY Principle for Duplication Reduction**

Check: Is there code duplication?
Why: Code duplication increases update burden, causes human errors
Fix: Templatize, parameterize inputs

**BP-03 (SHOULD): Explicit Job Dependencies**

Check: Are job dependencies explicitly defined with `needs`?
Why: Ambiguous job dependencies cause serialization, failure propagation
Fix: Make explicit with `needs`

**BP-04 (SHOULD): Simplify Conditional Branches**

Check: Are `if` expressions concise and understandable?
Why: Complex `if` expressions cause judgment errors, job inconsistencies
Fix: Simplify `if`, add intent comments

**BP-05 (SHOULD): Limit Environment Variable Scope**

Check: Are secrets or sensitive values exposed at broader scope than necessary? Non-sensitive configuration values at top-level for readability are acceptable.
Why: Secrets at excessive scope risk accidental exposure via logs or downstream steps.
Fix: Keep secrets and sensitive values at minimal scope. Non-sensitive settings may remain at top-level when organized for clarity.
