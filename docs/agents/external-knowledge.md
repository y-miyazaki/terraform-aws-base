# External Knowledge and Dependency Awareness

Standards for using external knowledge and evaluating change impact.

## External Knowledge Usage

Prioritize: official documentation, primary sources, vendor documentation, repository-native documentation.

- Verify compatibility and applicability of external references
- Do not include secrets or sensitive data in external queries
- Do not rely solely on unverified third-party examples for critical decisions

## Dependency and Impact Awareness

Evaluate before modification:

- upstream dependencies
- downstream consumers
- compatibility impact
- operational impact

Consider impacts on:

- interfaces and schemas
- APIs
- generated artifacts
- runtime behavior
- deployment behavior
- automation workflows
