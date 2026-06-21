## architecture

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Architecture Overview

<!-- Answer: What does this system do and why does this document exist? Source: README, main entry point. -->

Focus on:
- system boundaries and ownership
- runtime topology and data flow
- dependency relationships
- operational constraints

Avoid:
- low-level implementation details (use design.md)
- directory listings without explanation
- generic descriptions that apply to any system

## System Overview

<!-- Answer: What are the 3-5 major components? How do they communicate? What are the trust boundaries? Source: read main package/module structure and entry points. -->

## Component Responsibilities

<!-- Answer: What does each component own? What are the boundaries between them? Source: read top-level directories, interfaces, and exported APIs. -->

| Component | Responsibility | Owns |
| --------- | -------------- | ---- |

## Data and Control Flow

<!-- Answer: How does data move through the system? What triggers processing? Source: read main handlers, event sources, and storage layers. -->

## Runtime Topology

<!-- Answer: How is this deployed? What are the scaling boundaries? What depends on what at runtime? Source: read deployment configs, Dockerfiles, CI/CD. -->

## Architectural Constraints

<!-- Answer: What intentional limitations exist? Why? What would break if they were violated? Source: read config constraints, version pins, compatibility notes. -->

## Key Decisions

<!-- Reference design-decisions.md for full rationale. List only the decisions that affect system structure. -->

## Decision Prompts

Consider:
- Which components are tightly coupled?
- Which boundaries are operationally sensitive?
- What assumptions exist around scaling or failure isolation?
- Which dependencies are hardest to replace?
```
