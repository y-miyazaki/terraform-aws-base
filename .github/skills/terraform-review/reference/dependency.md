### 18. Dependency & Ordering (DEP)

**DEP-01: Minimal depends_on**

- Problem: Overuse of `depends_on`, excessive explicit dependencies
- Impact: Increased execution time, complex dependencies
- Recommendation: Prefer implicit dependencies, minimal depends_on
- Check: depends_on used only when necessary

**DEP-02: Avoid Circular References**

- Problem: Circular dependencies between resources, mutual references
- Impact: Apply errors, execution impossible
- Recommendation: Review design, resolve dependencies, split modules
- Check: No circular dependencies

**DEP-03: Make Implicit Dependencies Explicit When Needed**

- Problem: Missing dependencies, unconsidered implicit dependencies
- Impact: Apply errors, ordering issues
- Recommendation: Set explicit dependencies when needed, control ordering
- Check: Critical dependencies are explicit
