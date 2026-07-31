# Events & Observability (E)

**E-01 (SHOULD): Keep EventBridge patterns narrow (source/detail-type)**

Check: Are event patterns specific and targeted?
Why: Overly broad event patterns and insufficient filters cause unnecessary invocations, increased costs, and noise
Fix: Filter only necessary events, narrow detail-type/source

**E-02 (SHOULD): Set CloudWatch log group retention explicitly**

Check: Do log groups have explicit retention periods?
Why: Unset retention period and indefinite storage cause increased storage costs, log bloat, and management difficulties
Fix: Set appropriate `retention_in_days` (7/30/90/365), match requirements
