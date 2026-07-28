## Error Handling (ERR)

**ERR-01 (SHOULD): Limit continue-on-error to non-critical justified steps**

Check: Is `continue-on-error` used only for non-critical steps with explicit justification?
Why: Overuse of failure masking hides real pipeline regressions and causes unsafe releases.
Fix: Restrict `continue-on-error` to optional checks and document rationale.

**ERR-02 (SHOULD): Use if: failure()/always() for cleanup/notify uploads**

Check: Are `if: failure()` and `if: always()` used for cleanup, artifact upload, and notifications where step failure must not skip them?
Why: Missing failure-path handling reduces observability and leaves environments in inconsistent state.
Fix: Add explicit guard conditions for failure handling and always-run housekeeping.

**ERR-03 (SHOULD): Set timeout-minutes on jobs or long steps**

Check: Are `timeout-minutes` values set for jobs or long-running steps?
Why: Missing timeout settings can block runners indefinitely and increase CI cost.
Fix: Set conservative timeout values at job/step scope.
