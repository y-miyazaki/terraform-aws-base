## 19. Data Sources & Imports (DATA)

**Note**: Data sources are recommended when:

- Referencing existing resources is a requirement (integration with other modules/externally managed resources)
- Retrieving dynamically changing values (AMI IDs, availability zones, etc.)
- Prefer variables when static values are sufficient

**DATA-01: Reconsider data sources (Replace with Static Values)**

Check: Are data sources justified?
Why: Unnecessary data source references and replaceable with static values cause external dependencies and increased execution time
Fix: Consider static value replacement, use data sources only when needed

**DATA-02: Document import Procedures**

Check: Are import operations documented?
Why: Unclear import background and undocumented procedures cause management difficulties and non-reproducible operations
Fix: Document procedures, record in comments, manage change history

**DATA-03: Externalize IDs/ARNs as Variables**

Check: Do cross-environment references use variables?
Why: Hardcoded IDs/ARNs and environment dependence cause difficult environment portability and multi-account incompatibility
Fix: Define as variables, separate tfvars, use environment-independent design

**DATA-04: Remove Unused data sources**

Check: Are all data sources referenced?
Why: Unused data sources and dead code cause wasted API calls and increased execution time
Fix: Remove unused data sources, perform periodic cleanup
