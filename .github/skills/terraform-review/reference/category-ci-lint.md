## 11. CI & Lint (CI)

**CI-01: plan Diff Intentional (No Unintended Changes)**

Check: Are all plan diffs intentional and documented?
Why: Unintended diff generation, drift, and configuration inconsistencies cause unexpected change application and resource recreation
Fix: Scrutinize `plan` results, resolve diffs, verify state consistency
Note: Expected diffs excluded: provider version upgrades, resource reordering, computed attributes

**CI-02: New Resources Clearly Justified**

Check: Do new resources have clear business justification?
Why: Unnecessary resource creation and unclear requirements cause cost increase, security risks, and management burden
Fix: Create only necessary resources based on requirements, provide justification
