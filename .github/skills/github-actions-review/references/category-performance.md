## 5. Performance (PERF)

**PERF-01: Parallelization with Matrix**

Check: Is `matrix` utilized for multi-environment testing?
Why: Not using matrix causes redundancy, increases execution time
Fix: Introduce parallelization with `matrix`

**PERF-02: Work Reduction with Caching**

Check: Is appropriate caching configured for dependencies?
Why: Not using dependency caching causes repeated fetching, increases time
Fix: Cache appropriate paths, design `restore-keys`

**PERF-03: Remove Redundant Steps**

Check: Are there duplicate steps?
Why: Duplicate steps cause unnecessary execution, increase time/cost
Fix: Consolidate steps, share common logic

**PERF-04: Cancel Old Executions with Concurrency**

Check: Does `concurrency` configuration cancel old executions?
Why: Duplicate executions waste resources, cause delays
Fix: Configure `concurrency` to cancel old executions
