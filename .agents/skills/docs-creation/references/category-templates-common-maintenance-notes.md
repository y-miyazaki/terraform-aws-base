## maintenance-notes

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Maintenance Notes

<!-- Answer: What recurring maintenance does this project require? Source: read CI schedules, dependency update configs, operational runbooks. -->

Focus on:
- operational continuity and recurring tasks
- lifecycle management
- operational quirks and tribal knowledge

Avoid:
- temporary issue tracking (use issue tracker)
- undocumented operational assumptions
- tasks that should be automated instead of documented

## Recurring Tasks

<!-- Answer: What must be done periodically? By whom? Source: read cron jobs, Renovate/Dependabot config, scheduled workflows. -->

| Task | Frequency | Owner | Notes |
| ---- | --------- | ----- | ----- |

## Known Operational Quirks

<!-- Answer: What non-obvious behaviors exist? What workarounds are needed? Source: read comments in config, incident postmortems. -->

## Lifecycle Considerations

<!-- Answer: What upgrade/deprecation concerns exist? Source: read version constraints, EOL notices, migration plans. -->

## Decision Prompts

Consider:
- Which tasks are operationally risky?
- Which dependencies require proactive maintenance?
- Which operational knowledge is tribal today?
```
