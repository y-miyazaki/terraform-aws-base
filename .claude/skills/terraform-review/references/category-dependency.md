# Dependency & Ordering (DEP)

**DEP-01 (SHOULD): Use depends_on only when implicit edges are insufficient**

Check: Is depends_on used only when necessary?
Why: Overuse of `depends_on` and excessive explicit dependencies cause increased execution time and complex dependencies
Fix: Prefer implicit dependencies, use minimal depends_on
