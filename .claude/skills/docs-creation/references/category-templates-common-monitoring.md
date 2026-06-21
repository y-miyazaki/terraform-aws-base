## monitoring

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Monitoring

<!-- Answer: What needs to be monitored? What are the critical signals? Source: read alerting configs, CloudWatch/Prometheus definitions, health checks. -->

Focus on:
- operational visibility and actionable alerts
- ownership and escalation paths
- incident investigation support

Avoid:
- dashboards without operational purpose
- noisy non-actionable alerts
- generic monitoring advice

## Monitoring Strategy

<!-- Answer: What are the critical signals? What SLOs exist? Source: read service definitions, SLA docs. -->

## Alerts

<!-- Answer: What alerts exist? What action does each require? Source: read alerting config files. -->

| Alert | Trigger | Severity | Owner | Runbook |
| ----- | ------- | -------- | ----- | ------- |

## Dashboards

<!-- Answer: What dashboards exist and for whom? Source: read dashboard definitions or IaC. -->

## Runbooks

<!-- Answer: What are the step-by-step responses to each alert? Source: read incident history, recovery scripts. -->

## Decision Prompts

Consider:
- Which failures are hardest to detect?
- Which alerts require immediate action?
- Which metrics predict incidents early?
```
