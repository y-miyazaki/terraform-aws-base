## Cost Optimization (COST)

**COST-01 (SHOULD): Avoid High-Cost Metrics/Long Retention**

Check: Are retention periods and metric collection explicitly set rather than left at expensive defaults?
Why: Unset retention defaults to indefinite storage; unnecessary custom metrics incur per-metric charges
Fix: Set explicit retention_in_days, enable only required metrics

**COST-02 (SHOULD): Minimize Optional Defaults (monitoring/xray/retention)**

Check: Are optional features (X-Ray tracing, enhanced monitoring, detailed metrics) explicitly enabled only when needed?
Why: Enabling all optional features by default wastes cost and adds complexity
Fix: Default to minimal configuration; enable features with explicit justification in comments
