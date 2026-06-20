## CI & Lint (CI)

**CI-01 (SHOULD): Minimize Unintended Plan Diffs**

Check: Does the code avoid patterns that cause unnecessary plan diffs (e.g., unsorted keys, unstable JSON, computed defaults)?
Why: Unstable code patterns generate noisy diffs that obscure real changes and increase review burden
Fix: Use sorted keys in jsonencode, avoid unnecessary computed attributes, keep resource arguments in stable order

**CI-02 (SHOULD): New Resources Clearly Justified**

Check: Do new resources have clear business justification?
Why: Unnecessary resource creation and unclear requirements cause cost increase, security risks, and management burden
Fix: Create only necessary resources based on requirements, provide justification
