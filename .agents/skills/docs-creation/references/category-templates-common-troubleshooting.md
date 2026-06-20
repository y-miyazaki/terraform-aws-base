## troubleshooting

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

````markdown
# Troubleshooting

<!-- Answer: What are the most common failure modes? Source: read CI logs, error handling code, existing issues. -->

Focus on:
- symptom-driven diagnosis (what the user sees first)
- concrete investigation commands
- verified recovery steps

Avoid:
- shallow "restart and retry" guidance without diagnosis
- undocumented assumptions about environment
- generic advice not specific to this project

## <Symptom or Error Message>

<!-- Use the actual error message or observable symptom as the heading. -->

### Symptoms

<!-- Answer: What does the user observe? What log output or behavior indicates this issue? -->

### Likely Causes

<!-- Answer: What are the 2-3 most common causes? Source: read error handling code paths that produce this symptom. -->

### Investigation

<!-- Answer: What commands reveal the root cause? Source: read diagnostic tooling, health checks, log locations. -->

```sh
# concrete investigation commands
```

### Resolution

<!-- Answer: What specific steps fix each cause? Are any destructive? Source: read recovery scripts, migration tools. -->

```sh
# concrete resolution steps
```

### Prevention (Optional)

<!-- Answer: How to reduce recurrence? Source: read CI checks, validation scripts, monitoring. -->

## Decision Prompts

Consider:
- Which failures are hardest to diagnose?
- Which symptoms indicate systemic issues?
- Which recovery actions are destructive?
````
