# Ordering (ORD)

**ORD-01 (MUST): Alphabetize keys in env/permissions/with/secrets blocks**

Note: Not enforced by deterministic validators (`actionlint`, `ghalint`, `zizmor`). Omit from review output unless workflow YAML key ordering is the primary finding.

Check: Are map keys sorted alphabetically (A-Z) within each ORD-01 in-scope block listed below?
Why: Inconsistent key ordering adds diff noise and makes change detection harder across workflow files
Fix: Sort keys alphabetically within each listed block.

In-scope blocks:

- Workflow and job: `env`, `permissions`, `with`, `secrets`
- Reusable workflow declaration: `on.workflow_call.inputs`, `on.workflow_call.secrets`
- Composite `action.yml`: `inputs`, `outputs`; per-step `with`, `env`

Out of scope:

- `jobs` map keys and `on` trigger keys — keep semantic order (pipeline stage, event priority)
- `steps` — ordered lists, not key maps
