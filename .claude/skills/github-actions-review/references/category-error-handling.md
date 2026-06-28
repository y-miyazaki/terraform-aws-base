## Error Handling (ERR)

**ERR-01 (SHOULD): Careful Use of continue-on-error**

Check: Is `continue-on-error` used only for non-critical steps with explicit justification?
Why: Overuse of failure masking hides real pipeline regressions and causes unsafe releases.
Fix: Restrict `continue-on-error` to optional checks and document rationale.

**ERR-02 (SHOULD): Failure and Always Guards for Cleanup/Notify**

Check: Are `if: failure()` and `if: always()` used for cleanup, artifact upload, and notifications where step failure must not skip them?
Why: Missing failure-path handling reduces observability and leaves environments in inconsistent state.
Fix: Add explicit guard conditions for failure handling and always-run housekeeping.

**ERR-03 (SHOULD): Timeout Configuration**

Check: Are `timeout-minutes` values set for jobs or long-running steps?
Why: Missing timeout settings can block runners indefinitely and increase CI cost.
Fix: Set conservative timeout values at job/step scope.

**ERR-04 (SHOULD): Retry Strategy for Flaky Integrations**

Check: Is retry logic configured for transient external failures (network/service instability)?
Why: No retry strategy increases false-negative failures and operator burden.
Fix: Add bounded retry with max attempts and per-attempt timeout.
