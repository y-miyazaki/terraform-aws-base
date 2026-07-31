# Cost Optimization (COST)

**COST-01 (SHOULD): Set explicit retention/metrics; avoid expensive defaults**

Check: Are retention periods and metric collection explicitly set rather than left at expensive defaults?
Why: Unset retention defaults to indefinite storage; unnecessary custom metrics incur per-metric charges
Fix: Set explicit retention_in_days, enable only required metrics
