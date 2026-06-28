## Global / Base (G)

**G-01 (SHOULD): Clear Workflow Naming**

Check: Is the workflow name clear and expressive of its purpose?
Why: Missing/unclear names make execution identification difficult, delay triage
Fix: Set concise `name` (e.g., `terraform/init (audit)`)

**G-02 (SHOULD): Limit Triggers (on)**

Check: Are triggers limited to specific branches, paths, or event types rather than triggering on all pushes/PRs?
Why: Overly broad triggers cause unnecessary executions, increase costs, generate noise
Fix: Narrow triggers with `paths`/`types`

**G-03 (SHOULD): Step Clarification and Order Guarantee**

Check: Does each step have a `name` and logical order?
Why: Unclear steps/mixed order weakens builds, reduces maintainability
Fix: Add `name`, ensure logical order, separate `uses`/`run` roles

**G-04 (SHOULD): Explicit Environment and Approval Flow**

Check: Do production jobs have `environment` configuration and approval?
Why: Missing environment/approval causes accidental production execution, secret leak risks
Fix: Set `environment` for critical jobs, specify approvers

**G-05 (MUST): Alphabetical Key Ordering**

Note: This check is deterministic and should be enforced by `github-actions-validation` (linting), not by human review. Included here for reference only — do not evaluate in review output.

Check: Are keys in `inputs`, `env`, `permissions`, and `with` sorted alphabetically (A-Z)?
Why: Inconsistent key ordering adds diff noise and makes change detection harder across workflow files
Fix: Sort all keys alphabetically within `inputs`, `env`, `permissions`, and `with` blocks
