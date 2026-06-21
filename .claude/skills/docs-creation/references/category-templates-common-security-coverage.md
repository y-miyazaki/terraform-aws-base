## security-coverage

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Security Coverage

<!-- Answer: What security controls are implemented? Source: read IAM policies, encryption configs, security scanning CI steps. -->

Focus on:
- security boundaries and enforcement mechanisms
- ownership of each control
- intentional exclusions with rationale

Avoid:
- vague "secured" statements without specifics
- undocumented trust assumptions
- generic security checklists

## Coverage Matrix

<!-- Answer: What controls exist and what is their status? Source: read IaC security resources, policy configs. -->

| Control/Service | Status | Owner | Notes |
| --------------- | ------ | ----- | ----- |

## Security Boundaries

<!-- Answer: What are the trust boundaries? What is externally exposed? Source: read network configs, API gateways, auth middleware. -->

## Known Gaps and Exclusions

<!-- Answer: What is intentionally not covered? Why? Source: read security review notes, risk acceptance docs. -->

## Validation and Enforcement

<!-- Answer: How are controls verified? Source: read security scanning CI steps, policy-as-code configs. -->

## Decision Prompts

Consider:
- Which trust assumptions are implicit?
- Which controls rely on human process?
- Which failures could expose sensitive systems?
```
