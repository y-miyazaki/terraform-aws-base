# Performance & Limits (PERF)

**PERF-01 (SHOULD): Bound for_each/count collections; avoid unbounded expansion**

Check: Are for_each/count driven by bounded, plan-time-known collections rather than unbounded dynamic data?
Why: Unbounded collections cause slow plans, provider rate limits, and state file bloat
Fix: Split large resource sets into separate modules/states; use bounded variables with known upper limits
