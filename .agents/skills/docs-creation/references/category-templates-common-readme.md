## readme

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

````markdown
# <Repository Name>

<!-- Answer: What does this repository do? In 1-3 sentences. Source: read package config, main entry point, existing description. -->

README is the repository entry point for humans and AI assistants.

Focus on:
- repository identification and purpose
- quick operational entry points
- high-level navigation
- contributor guidance

Avoid:
- duplicating docs/ content
- embedding large generated tables
- exhaustive configuration references
- implementation-specific details

## Status

<!-- Answer: What is the maturity and primary stack? Source: read package config, CI status. -->

| Item              | Value |
| ----------------- | ----- |
| Lifecycle         |       |
| Primary Stack     |       |
| Deployment Target |       |

## Repository Purpose

<!-- Answer: What does this repo manage? Who operates it? What are the boundaries? Source: read top-level structure and package description. -->

## Quick Start

<!-- Answer: What are the 3-5 commands to get started? Source: read Makefile, scripts/, CI setup steps. -->

### Prerequisites

<!-- list from devcontainer, Dockerfile, or CI setup -->

### Common Commands

```sh
# from Makefile or scripts/
```

## Repository Structure

<!-- Answer: What are the major directories and their purpose? Source: read top-level directory listing. -->

| Path     | Purpose |
| -------- | ------- |

## Documentation Index

<!-- Answer: What docs exist and where? Source: read docs/ directory. -->

| Document                              | Purpose                     |
| ------------------------------------- | --------------------------- |
| `docs/index.md`                       | Documentation catalog       |
| `docs/explanation/architecture.md`    | System architecture         |
| `docs/explanation/design-decisions.md` | Architectural rationale     |
| `docs/how-to/troubleshooting.md`      | Operational troubleshooting |

## Contribution Guidance

<!-- Answer: How do people contribute? Source: read CONTRIBUTING.md, AGENTS.md, PR templates. -->

## Decision Prompts

Consider:
- Can a new contributor understand repository purpose within 2 minutes?
- Are common workflows discoverable?
- Are deep details delegated to specialized docs?
- Does README avoid becoming a duplicate of docs/?
````
