### 12. Patterns (P)

**P-01: Avoid Excessive dynamic Blocks**

- Problem: dynamic block overuse, over-abstraction
- Impact: Reduced readability, complexity, debugging difficulties
- Recommendation: Minimal usage, prefer static declarations, prioritize clarity
- Check: Dynamic blocks used only when necessary

**P-02: Stable for_each Keys**

- Problem: Unstable key usage, values prone to change
- Impact: Resource recreation, unexpected deletion, state inconsistencies
- Recommendation: Use unchanging unique values as keys, prefer IDs or names
- Check: for_each keys are stable identifiers

**P-03: Avoid count = 0/1 Toggle Chains**

- Problem: Complex conditional branching, count chains
- Impact: Understanding difficulties, bug-prone, maintenance difficulties
- Recommendation: Simplify logic, split modules, organize conditions
- Check: Conditional logic is straightforward
