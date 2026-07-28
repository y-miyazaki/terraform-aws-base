## Performance (PERF)

**PERF-01 (SHOULD): Deterministic cache keys invalidated by dependency changes**

Check: Are cache keys deterministic and invalidated by dependency changes?
Why: Poor cache invalidation leads to stale dependencies or low cache hit rates.
Fix: Build keys from lockfiles and use scoped restore-keys.

**PERF-02 (SHOULD): Balance matrix/parallelism vs runner cost**

Check: Is matrix or parallel execution used where beneficial without excessive runner cost?
Why: Under-parallelization slows feedback, over-parallelization inflates CI cost.
Fix: Tune matrix dimensions and parallelism based on critical path and cost.

**PERF-03 (SHOULD): Cancel redundant runs with concurrency (caller-owned for reusable)**

Check: Is `concurrency` configured to cancel redundant in-progress runs on same branch/context? Skip this check for reusable workflows (`workflow_call`), where concurrency is the caller's responsibility.
Why: Missing concurrency controls wastes runners and delays important builds.
Fix: Add concurrency group with `cancel-in-progress: true` where appropriate. For reusable workflows, document concurrency expectations for callers.
