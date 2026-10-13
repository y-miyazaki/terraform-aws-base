# Compliance & Policy (COMP)

**COMP-01 (MUST): No default network, open firewall, or public storage by default**

Check: Is there no use of default networks, are firewall/security rules restrictive, and is storage private by default?
Why: Unsafe default settings expand attack surface and risk information leakage
Fix: Use explicit network/subnet references, restrict ingress/egress rules, block public access on storage

**COMP-02 (MUST): Policy documents via jsonencode or provider policy data sources**

Check: Do policy documents use jsonencode() or a provider policy-document data source instead of raw JSON strings?
Why: Hand-written JSON strings cause syntax errors, reduce readability, and prevent static validation
Fix: Use `jsonencode` for simple policies or the provider's policy-document data source for complex ones
