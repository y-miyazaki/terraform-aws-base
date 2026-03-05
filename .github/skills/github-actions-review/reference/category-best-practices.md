## 6. Best Practices (BP)

**BP-01: Reusable Workflow Design**

Check: Are common processes extracted into reusable workflows or composite actions?
Why: Manual workflow copying increases maintenance costs, causes feature divergence
Fix: Extract to reusable workflows/composite actions

**BP-02: DRY Principle for Duplication Reduction**

Check: Is there code duplication?
Why: Code duplication increases update burden, causes human errors
Fix: Templatize, parameterize inputs

**BP-03: Explicit Job Dependencies**

Check: Are job dependencies explicitly defined with `needs`?
Why: Ambiguous job dependencies cause serialization, failure propagation
Fix: Make explicit with `needs`

**BP-04: Simplify Conditional Branches**

Check: Are `if` expressions concise and understandable?
Why: Complex `if` expressions cause judgment errors, job inconsistencies
Fix: Simplify `if`, add intent comments

**BP-05: Limit Environment Variable Scope**

Check: Is `env` defined with minimal scope?
Why: Excessive env scope causes unexpected behavior, secret exposure
Fix: Use minimal scope `env`, utilize outputs/inputs
