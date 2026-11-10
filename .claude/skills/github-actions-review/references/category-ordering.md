# Ordering (ORD)

**ORD-01 (MUST): Alphabetize keys in env/inputs/outputs/permissions/secrets/with maps**

Note: The companion `github-actions-validation` ORD-01 step checks map key order in the files it scans: by default, git-tracked `.github/workflows/*.yml|yaml` and `.github/actions/**/action.yml|yaml`; with a directory argument, only the YAML files under that directory. When its output is supplied, take ORD-01's status for those files from it and cite it; still evaluate from source any changed workflow or action file it did not scan (for example untracked new files or an `action.yml` outside `.github/actions/`).

Check: Are map keys sorted alphabetically (A-Z, ASCII order) within each ORD-01 in-scope map listed below?
Why: Inconsistent key ordering adds diff noise and makes change detection harder across workflow files
Fix: Sort keys alphabetically within each listed map.

In-scope maps (any `env`, `inputs`, `outputs`, `permissions`, `secrets`, or `with` map in workflow or composite action YAML), for example:

- Workflow and job: `env`, `outputs`, `permissions`, `secrets`, `with`
- Reusable workflow declaration: `on.workflow_call.inputs`, `on.workflow_call.outputs`, `on.workflow_call.secrets`
- Composite `action.yml`: `inputs`, `outputs`; per-step `env`, `with`

Out of scope:

- `jobs` map keys and `on` trigger keys — keep semantic order (pipeline stage, event priority)
- `steps` — ordered lists, not key maps
