# Code and Artifact Modification Standards

Detailed standards for modifying code and artifacts.

## Pre-flight Inspection

Before changes:

- inspect impact scope
- search related implementations
- identify duplicated logic
- identify shared interfaces or contracts

Use available repository and workspace search tools proactively.

## Minimal Diff (Detailed)

Prefer the smallest safe change. Avoid unrelated opportunistic refactors.

Refactor only when directly tied to:

- correctness
- maintainability
- recurrence prevention
- safety

## Consistency Requirements

When modifying established patterns:

- preserve repository consistency
- update all relevant locations when standardization is required

Avoid partial pattern divergence.

## Implementation Quality

After modifications:

- verify behavior
- resolve introduced errors autonomously where reasonable
- avoid placeholder implementations unless explicitly requested

Generated code and artifacts MUST be reviewed for:

- security impact
- dependency risk
- compatibility
- licensing concerns
- operational maintainability

## Version Control Awareness

- Keep changes logically scoped
- Avoid mixing unrelated changes
- Preserve reviewability and traceability
