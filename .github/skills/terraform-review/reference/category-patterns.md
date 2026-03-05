## 12. Patterns (P)

**P-01: Avoid Excessive dynamic Blocks**

Check: Are dynamic blocks used only when necessary?
Why: Dynamic block overuse and over-abstraction cause reduced readability, complexity, and debugging difficulties
Fix: Use minimally, prefer static declarations, prioritize clarity

**P-02: Stable for_each Keys**

Check: Are for_each keys stable identifiers?
Why: Unstable key usage and values prone to change cause resource recreation, unexpected deletion, and state inconsistencies
Fix: Use unchanging unique values as keys, prefer IDs or names

**P-03: Avoid count = 0/1 Toggle Chains**

Check: Is conditional logic straightforward?
Why: Complex conditional branching and count chains cause understanding difficulties, bug-prone code, and maintenance difficulties
Fix: Simplify logic, split modules, organize conditions
