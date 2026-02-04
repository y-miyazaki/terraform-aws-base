### 11. CI & Lint (CI)

**CI-01: plan Diff Intentional (No Unintended Changes)**

- Problem: Unintended diff generation, drift, configuration inconsistencies
- Impact: Unexpected change application, resource recreation
- Recommendation: Scrutinize `plan` results, resolve diffs, verify state consistency
- Note: Expected diffs excluded: provider version upgrades, resource reordering, computed attributes
- Check: All plan diffs are intentional and documented

**CI-02: New Resources Clearly Justified**

- Problem: Unnecessary resource creation, unclear requirements
- Impact: Cost increase, security risks, management burden
- Recommendation: Create only necessary resources based on requirements, provide justification
- Check: New resources have clear business justification
