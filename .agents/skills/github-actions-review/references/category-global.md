## Global / Base (G)

**G-01 (SHOULD): Clear Workflow Naming**

Check: Is the workflow name clear and expressive of its purpose?
Why: Missing/unclear names make execution identification difficult, delay triage
Fix: Set concise `name` (e.g., `terraform/init (audit)`)

**G-02 (SHOULD): Limit Triggers (on)**

Check: Are triggers appropriately narrowed down?
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
