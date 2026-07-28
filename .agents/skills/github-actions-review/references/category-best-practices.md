## Best Practices (BP)

**BP-01 (SHOULD): Extract shared pipelines to reusable workflows/composites**

Check: Are common processes extracted into reusable workflows or composite actions?
Why: Manual workflow copying increases maintenance costs, causes feature divergence
Fix: Extract to reusable workflows/composite actions

**BP-02 (SHOULD): Declare job dependencies with needs**

Check: Are job dependencies explicitly defined with `needs`?
Why: Ambiguous job dependencies cause serialization, failure propagation
Fix: Make explicit with `needs`

**BP-03 (SHOULD): Keep secrets at minimal env scope**

Check: Are secrets or sensitive values exposed at broader scope than necessary? Non-sensitive configuration values at top-level for readability are acceptable.
Why: Secrets at excessive scope risk accidental exposure via logs or downstream steps.
Fix: Keep secrets and sensitive values at minimal scope. Non-sensitive settings may remain at top-level when organized for clarity.

**BP-04 (SHOULD): Explicit with: for security/cache/core action inputs**

Check: Are action inputs that affect security, caching, or core behavior specified explicitly in `with` blocks, even when matching the action's default value?
Why: Implicit defaults for critical settings hide intent and break silently when upstream actions change their defaults.
Fix: Specify inputs that affect security, caching, or core behavior explicitly in `with` blocks.
