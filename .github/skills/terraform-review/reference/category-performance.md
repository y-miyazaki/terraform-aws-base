## 16. Performance & Limits (PERF)

**PERF-01: Avoid Excessive for_each/count Plan Time**

Check: Does plan complete in reasonable time?
Why: Increased plan execution time and bulk processing cause reduced development efficiency and CI/CD delays
Fix: Split state, consider `-target`, use resource grouping

**PERF-02: Reduce Provider Calls**

Check: Are data sources not duplicated unnecessarily?
Why: Excessive API calls and duplicate data sources cause rate limit hits and execution delays
Fix: Cache/share data, leverage locals, minimize data sources

**PERF-03: Monitor CloudWatch Event/Alarm Generation**

Check: Are alarms meaningful and actionable?
Why: Alarm proliferation and excessive events cause increased noise and critical alarms being buried
Fix: Monitor only important events, consolidate alarms
