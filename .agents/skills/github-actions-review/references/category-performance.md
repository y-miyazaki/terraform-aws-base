## Performance (PERF)

**PERF-01 (SHOULD): Cache Strategy and Invalidation**

Check: Are cache keys deterministic and invalidated by dependency changes?
Why: Poor cache invalidation leads to stale dependencies or low cache hit rates.
Fix: Build keys from lockfiles and use scoped restore-keys.

**PERF-02 (SHOULD): Matrix/Parallel Execution Balance**

Check: Is matrix or parallel execution used where beneficial without excessive runner cost?
Why: Under-parallelization slows feedback, over-parallelization inflates CI cost.
Fix: Tune matrix dimensions and parallelism based on critical path and cost.

**PERF-03 (SHOULD): Concurrency Control**

Check: Is `concurrency` configured to cancel redundant in-progress runs on same branch/context? Skip this check for reusable workflows (`workflow_call`), where concurrency is the caller's responsibility.
Why: Missing concurrency controls wastes runners and delays important builds.
Fix: Add concurrency group with `cancel-in-progress: true` where appropriate. For reusable workflows, document concurrency expectations for callers.

**PERF-04 (SHOULD): Reduce Unnecessary Workload**

Check: Are broad triggers, full-repo checkout, and repeated setup steps minimized?
Why: Excessive workload increases runtime and resource consumption without quality gain.
Fix: Narrow triggers with `paths/types`, optimize checkout depth, and deduplicate setup steps.
