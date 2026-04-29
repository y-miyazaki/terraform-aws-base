## 3. variables.tf (V)

**V-01: Concrete Types (Avoid Excessive map(any)/any)**

Check: Is use of `any` and `map(any)` minimal?
Why: Excessive `any` type usage and lack of type safety cause runtime type errors, unexpected behavior, and difficult debugging
Fix: Use concrete types (`string`, `number`, `object({...})`), enforce type constraints

**V-02: Default Value Validity**

Check: Are there no sentinel values; are defaults meaningful or absent?
Why: Inappropriate defaults, empty string/0 defaults, and sentinel values cause missed misconfigurations, unintended behavior, and security risks
Fix: Remove default for required variables, use appropriate defaults, consider null

**V-03: Description Comments + (Required)/(Optional)**

Check: Do all variables have descriptions with required/optional markers?
Why: Insufficient variable descriptions and unclear required/optional status cause user confusion, misuse, and documentation gaps
Fix: Write `description`, explicitly mark (Required)/(Optional), add examples

**V-04: Validation Pattern Restrictions**

Check: Are validation rules reasonable and necessary?
Why: Inappropriate validations and excessive constraints (e.g., length > 0) cause rejection of valid values, errors, and operational difficulties
Fix: Use appropriate condition expressions, implement business logic validation

**V-05: No Unused Variables**

Check: Are all variables referenced?
Why: Unused variables remaining as dead code and noise cause confusion, increased maintenance cost, and reduced readability
Fix: Remove unused variables, perform periodic cleanup
