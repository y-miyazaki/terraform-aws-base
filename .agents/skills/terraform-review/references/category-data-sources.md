## Data Sources & Imports (DATA)

**DATA-01 (SHOULD): Justify Each Data Source**

Check: Is each data source necessary, or can the value be passed as a variable?
Why: Unnecessary data sources add external dependencies, increase plan time, and couple modules to specific infrastructure state
Fix: Use variables for values that callers already know; reserve data sources for truly dynamic lookups (latest AMI, availability zones, existing resources managed elsewhere)

**DATA-02 (SHOULD): Externalize IDs/ARNs as Variables**

Check: Do cross-environment references use variables rather than hardcoded IDs?
Why: Hardcoded IDs/ARNs break environment portability and multi-account deployment
Fix: Define as variables, separate per-environment tfvars

**DATA-03 (SHOULD): Remove Unused data sources**

Check: Are all data sources referenced in at least one resource or output?
Why: Unused data sources waste API calls and add execution time
Fix: Remove unreferenced data sources
