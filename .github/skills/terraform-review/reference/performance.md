### 16. Performance & Limits (PERF)

**PERF-01: Avoid Excessive for_each/count Plan Time**

- Problem: Increased plan execution time, bulk processing
- Impact: Reduced development efficiency, CI/CD delays
- Recommendation: Split state, consider `-target`, resource grouping
- Check: Plan completes in reasonable time

**PERF-02: Reduce Provider Calls**

- Problem: Excessive API calls, duplicate data sources
- Impact: Rate limit hit, execution delays
- Recommendation: Cache/share data, leverage locals, minimize data sources
- Check: Data sources are not duplicated unnecessarily

**PERF-03: Monitor CloudWatch Event/Alarm Generation**

- Problem: Alarm proliferation, excessive events
- Impact: Increased noise, critical alarms buried
- Recommendation: Monitor only important events, consolidate alarms
- Check: Alarms are meaningful and actionable
