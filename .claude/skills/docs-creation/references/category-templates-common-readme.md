## readme

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

````markdown
# <Repository Name>

<!-- Answer: Badges (CI status, coverage, version, license). Optional but recommended for OSS. Source: read CI workflows, package config. -->

<!-- Answer: 1-3 sentence description of what this repository does. Source: read package config, main entry point. -->

<!-- Answer: Hero links to documentation, tutorials, getting started. Place immediately after description. Source: read docs/ structure. -->

README is the repository entry point for humans and AI assistants.

Focus on:
- immediate identification of what this repository is
- quick navigation to documentation and getting started
- minimal self-contained content (delegate details to docs/)

Avoid:
- duplicating docs/ content in README
- embedding large generated tables or catalogs
- exhaustive configuration references
- manual TOC (GitHub renders section navigation automatically)

## Key Features (Optional)

<!-- Answer: What are 3-6 distinguishing capabilities? Use bold + one-line description per item. Source: read package config, main modules. Remove this section for internal/utility repositories. -->

## Quick Start

<!-- Answer: What are the 3-5 commands to get from zero to working? Source: read Makefile, scripts/, CI setup steps. -->

### Prerequisites

<!-- Answer: What tools, versions, and permissions does the reader need before starting? Source: read devcontainer, mise.toml, Dockerfile. -->

### Install

```sh
# minimal install commands
```

## Documentation

<!-- Answer: Where is the full documentation? Prefer a single link to the docs site or docs/index.md. Add a brief category table only if no docs site exists. Source: read docs/ directory. -->

## Repository Structure (Optional)

<!-- Answer: What are the major directories and their purpose? Use only for repositories where structure is non-obvious. Source: read top-level directory listing. -->

| Path | Purpose |
| ---- | ------- |

## Contributing

<!-- Answer: How do people contribute? Keep brief; link to CONTRIBUTING.md for details. Source: read CONTRIBUTING.md, PR templates. -->

## License

<!-- Answer: What license? One line with link to LICENSE file. Source: read LICENSE. -->

## Decision Prompts

Consider:
- Can a reader understand what this repository does within 10 seconds?
- Is Quick Start reachable without scrolling on a standard screen?
- Are details delegated to docs/ rather than embedded in README?
- Does README work as a portal, not an encyclopedia?
````
