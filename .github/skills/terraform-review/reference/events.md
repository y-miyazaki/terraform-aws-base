### 8. Events & Observability (E)

**E-01: EventBridge event_pattern Precision**

- Problem: Overly broad event patterns, insufficient filters
- Impact: Unnecessary invocations, increased costs, noise
- Recommendation: Filter only necessary events, narrow detail-type/source
- Check: Event patterns are specific and targeted

**E-02: CloudWatch Log Group Retention**

- Problem: Unset retention period, indefinite storage
- Impact: Increased storage costs, log bloat, management difficulties
- Recommendation: Set appropriate `retention_in_days` (7/30/90/365), match requirements
- Check: Log groups have explicit retention periods

**E-03: Alarm/Metrics/Dashboard Consistency**

- Problem: Monitoring setup inconsistencies, missing alarms
- Impact: Missed fault detection, operational difficulties, SLA violations
- Recommendation: Sync resource/monitoring configs, set alarms for critical metrics
- Check: Alarms match deployed resources

**E-04: Step Functions Log Level Appropriateness**

- Problem: Inappropriate log level, ALL setting, too much or too little logging
- Impact: Debugging difficulties, log cost increase, slow troubleshooting
- Recommendation: Use appropriate log level (OFF/ALL/ERROR/FATAL), ERROR recommended for production
- Check: Log levels match environment requirements
