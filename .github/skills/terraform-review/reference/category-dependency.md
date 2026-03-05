## 18. Dependency & Ordering (DEP)

**DEP-01: Minimal depends_on**

Check: Is depends_on used only when necessary?
Why: Overuse of `depends_on` and excessive explicit dependencies cause increased execution time and complex dependencies
Fix: Prefer implicit dependencies, use minimal depends_on

**DEP-02: Avoid Circular References**

Check: Are there no circular dependencies?
Why: Circular dependencies between resources and mutual references cause apply errors and make execution impossible
Fix: Review design, resolve dependencies, split modules

**DEP-03: Make Implicit Dependencies Explicit When Needed**

Check: Are critical dependencies explicit?
Why: Missing dependencies and unconsidered implicit dependencies cause apply errors and ordering issues
Fix: Set explicit dependencies when needed, control ordering
