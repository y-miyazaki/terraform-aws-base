## Diataxis Document Structure

Directory layout follows [Diataxis](https://diataxis.fr/). Each `document_type` maps to a quadrant and directory.

| document_type | Diataxis quadrant | Directory | Purpose |
|---|---|---|---|
| `tutorial` | Tutorial | `docs/tutorials/` | Learning-oriented walkthrough with a single happy path |
| `troubleshooting` | How-To | `docs/how-to/` | Issue diagnostics and recovery steps |
| `maintenance-notes` | How-To | `docs/how-to/` | Periodic operations and maintenance history |
| `improvements` | How-To | `docs/how-to/` | Planned and completed improvement work |
| `general` | — | (use `target_file`) | New documentation outside predefined types |
| `specification` | Reference | `docs/reference/` | Behavioral requirements and expected flows |
| `module-catalog` | Reference | `docs/reference/` | Module catalog with key inputs/outputs |
| `monitoring` | Reference | `docs/reference/` | Alerts, dashboards, and operational runbook |
| `performance` | Reference | `docs/reference/` | Bottlenecks, benchmarks, and tuning actions |
| `security-coverage` | Reference | `docs/reference/` | Security control and service coverage |
| `architecture` | Explanation | `docs/explanation/` | System structure and boundaries |
| `design` | Explanation | `docs/explanation/` | Module-level implementation design |
| `design-decisions` | Explanation | `docs/explanation/` | Major decisions and rejected alternatives |
| `readme` | — | `README.md` | Repository entry point |
| `other` | — | (use `target_file`) | Update existing documents |

Template resolution: `category-templates-common-{document_type}.md`

Profile-specific overrides:
- `go` + `specification` → `category-templates-go-specification.md`
- `terraform` + `specification` → `category-templates-terraform-specification.md`
