# Execution Protocol

Operational procedures for task execution by AI agents.

## Task Classification

Classify work before starting:

- Question / Investigation / Implementation / Review / Planning / Refactoring

Adjust verification depth accordingly.

## Context Continuity

When resuming work or operating in long sessions, verify that current understanding of requirements and constraints is still accurate before major implementation steps.

Applies to: resumed tasks, multi-step implementations, work after significant context changes.

## Exploration Budget

Limit unproductive retries and repeated failed approaches.

If repeated attempts fail to make progress:

- change strategy
- simplify the approach
- or ask the user

Avoid infinite trial-and-error loops.

## Parallelism Policy

Execute tasks in parallel only when:

- tasks are independent
- execution ordering is not safety-critical
- tooling safely supports parallel execution

Otherwise prefer sequential execution.

## Stop-and-Ask Criteria

Stop and ask the user before proceeding when encountering:

- destructive operations
- conflicting requirements
- unclear specifications
- irreversible architectural decisions
- security-sensitive ambiguity
- disproportionate cost or resource consumption

Otherwise proceed autonomously where safe.
