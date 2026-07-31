# variables.tf (V)

**V-01 (SHOULD): Prefer concrete types over any / map(any)**

Check: Is use of `any` and `map(any)` minimal?
Why: Excessive `any` type usage and lack of type safety cause runtime type errors, unexpected behavior, and difficult debugging
Fix: Use concrete types (`string`, `number`, `object({...})`), enforce type constraints

**V-02 (SHOULD): Variable descriptions mark (Required)/(Optional)**

Check: Do all variables have descriptions with required/optional markers?
Why: Insufficient variable descriptions and unclear required/optional status cause user confusion, misuse, and documentation gaps
Fix: Write `description`, explicitly mark (Required)/(Optional), add examples

**V-03 (SHOULD): validation blocks match real business constraints**

Check: Are validation rules aligned with business constraints and necessary?
Why: Inappropriate validations and excessive constraints (e.g., length > 0) cause rejection of valid values, errors, and operational difficulties
Fix: Use appropriate condition expressions, implement business logic validation
