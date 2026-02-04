### 3. variables.tf (V)

**V-01: Concrete Types (Avoid Excessive map(any)/any)**

- Problem: Excessive `any` type usage, lack of type safety
- Impact: Runtime type errors, unexpected behavior, difficult debugging
- Recommendation: Use concrete types (`string`, `number`, `object({...})`), enforce type constraints
- Check: Minimal use of `any` and `map(any)`

**V-02: Default Value Validity**

- Problem: Inappropriate defaults, empty string/0 defaults, sentinel values
- Impact: Missed misconfigurations, unintended behavior, security risks
- Recommendation: Remove default for required variables, appropriate defaults, consider null
- Check: No sentinel values; defaults are meaningful or absent

**V-03: Description Comments + (Required)/(Optional)**

- Problem: Insufficient variable descriptions, unclear required/optional status
- Impact: User confusion, misuse, documentation gaps
- Recommendation: Write `description`, explicitly mark (Required)/(Optional), add examples
- Check: All variables have descriptions with required/optional markers

**V-04: Validation Pattern Restrictions**

- Problem: Inappropriate validations, excessive constraints (e.g., length > 0)
- Impact: Rejecting valid values, errors, operational difficulties
- Recommendation: Appropriate condition expressions, business logic validation
- Check: Validation rules are reasonable and necessary

**V-05: No Unused Variables**

- Problem: Unused variables remaining, dead code, noise
- Impact: Confusion, increased maintenance cost, reduced readability
- Recommendation: Remove unused variables, periodic cleanup
- Check: All variables are referenced
