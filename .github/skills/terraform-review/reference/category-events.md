## 8. Events & Observability (E)

**E-01: EventBridge event_pattern Precision**

Check: Are event patterns specific and targeted?
Why: Overly broad event patterns and insufficient filters cause unnecessary invocations, increased costs, and noise
Fix: Filter only necessary events, narrow detail-type/source

**E-02: CloudWatch Log Group Retention**

Check: Do log groups have explicit retention periods?
Why: Unset retention period and indefinite storage cause increased storage costs, log bloat, and management difficulties
Fix: Set appropriate `retention_in_days` (7/30/90/365), match requirements

**E-03: Alarm/Metrics/Dashboard Consistency**

Check: Do alarms match deployed resources?
Why: Monitoring setup inconsistencies and missing alarms cause missed fault detection, operational difficulties, and SLA violations
Fix: Sync resource/monitoring configs, set alarms for critical metrics

**E-04: Step Functions Log Level Appropriateness**

Check: Do log levels match environment requirements?
Why: Inappropriate log level, ALL setting, and too much or too little logging cause debugging difficulties, log cost increase, and slow troubleshooting
Fix: Use appropriate log level (OFF/ALL/ERROR/FATAL), ERROR recommended for production
