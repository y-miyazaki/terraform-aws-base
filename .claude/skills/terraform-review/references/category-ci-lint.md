# CI & Lint (CI)

**CI-01 (SHOULD): Avoid unstable args that create noisy plan diffs**

Check: Does the code avoid patterns that cause unnecessary plan diffs (e.g., unsorted keys, unstable JSON, computed defaults)?
Why: Unstable code patterns generate noisy diffs that obscure real changes and increase review burden
Fix: Use sorted keys in jsonencode, avoid unnecessary computed attributes, keep resource arguments in stable order
