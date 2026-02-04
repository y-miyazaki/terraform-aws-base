### 19. Data Sources & Imports (DATA)

**Note**: Data sources are recommended when:

- Referencing existing resources is a requirement (integration with other modules/externally managed resources)
- Retrieving dynamically changing values (AMI IDs, availability zones, etc.)
- Prefer variables when static values are sufficient

**DATA-01: Reconsider data sources (Replace with Static Values)**

- Problem: Unnecessary data source references, replaceable with static values
- Impact: External dependencies, increased execution time
- Recommendation: Consider static value replacement, use data sources only when needed
- Check: Data sources are justified

**DATA-02: Document import Procedures**

- Problem: Unclear import background, undocumented procedures
- Impact: Management difficulties, non-reproducible
- Recommendation: Document procedures, record in comments, manage change history
- Check: Import operations are documented

**DATA-03: Externalize IDs/ARNs as Variables**

- Problem: Hardcoded IDs/ARNs, environment dependence
- Impact: Difficult environment portability, multi-account incompatibility
- Recommendation: Define as variables, separate tfvars, environment-independent design
- Check: Cross-environment references use variables

**DATA-04: Remove Unused data sources**

- Problem: Unused data sources, dead code
- Impact: Wasted API calls, increased execution time
- Recommendation: Remove unused data sources, periodic cleanup
- Check: All data sources are referenced
