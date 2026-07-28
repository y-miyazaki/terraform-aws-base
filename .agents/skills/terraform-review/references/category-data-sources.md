## Data Sources & Imports (DATA)

**DATA-01 (SHOULD): Prefer variables over data sources when caller knows the value**

Check: Is each data source necessary, or can the value be passed as a variable?
Why: Unnecessary data sources add external dependencies, increase plan time, and couple modules to specific infrastructure state
Fix: Use variables for values that callers already know; reserve data sources for truly dynamic lookups (latest AMI, availability zones, existing resources managed elsewhere)

**DATA-02 (SHOULD): Pass IDs/ARNs as variables instead of hardcoding lookups**

Check: Do cross-environment references use variables rather than hardcoded IDs?
Why: Hardcoded IDs/ARNs break environment portability and multi-account deployment
Fix: Define as variables, separate per-environment tfvars
