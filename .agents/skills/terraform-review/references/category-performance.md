## Performance & Limits (PERF)

**PERF-01 (SHOULD): Avoid Unbounded for_each/count**

Check: Are for_each/count driven by bounded, plan-time-known collections rather than unbounded dynamic data?
Why: Unbounded collections cause slow plans, provider rate limits, and state file bloat
Fix: Split large resource sets into separate modules/states; use bounded variables with known upper limits

**PERF-02 (SHOULD): Reduce Provider Calls**

Check: Are data sources not duplicated unnecessarily across files or modules?
Why: Duplicate data sources cause redundant API calls and risk rate limit hits
Fix: Query once and share via locals or module outputs

**PERF-03 (SHOULD): Meaningful Alarms Only**

Check: Does each alarm have a clear action owner and response procedure?
Why: Alarm proliferation buries critical alerts in noise
Fix: Create alarms only for actionable conditions; consolidate related metrics
