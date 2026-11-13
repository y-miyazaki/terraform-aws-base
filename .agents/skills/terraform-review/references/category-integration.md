# Integration & Consistency (INT)

Findings here are about how resources work **together**: permissions that must exist on both sides, failure paths that must reach a human, and code that no longer participates in the system.

**INT-01 (MUST): Encryption and resource-policy changes are matched on every side that must use the key or policy**

Check: When a resource starts using a customer-managed key, role or resource policy, are all required sides granted: the key or policy owner (service principals such as log delivery or cross-service grants), the consumer's role (decrypt and data-key permissions), and any other caller that needs access? Are the grants scoped (encryption context, source resource or account conditions, allowed-service conditions)?
Why: Enabling encryption or a new policy without the matching grant breaks log delivery, executions or reads at apply or run time, and `terraform validate` cannot see it. Over-broad grants (whole key, wildcard principal) give the role access to unrelated data encrypted under a shared key
Fix: Check the service documentation for the exact principals and conditions, add the missing grants, scope them with the service's context or source conditions, and avoid dependency cycles by building identifiers from known names when needed

**INT-02 (SHOULD): Failure paths reach a notification target**

Check: Does every alarm have a notification action (or an equivalent route), does every dead-letter target or failure destination have an alarm or consumer, and do asynchronous targets have a documented behavior when delivery fails?
Why: An alarm without an action, or a queue nobody reads, fails silently and defeats the purpose of the monitoring
Fix: Wire the alarm to the shared notification target, add an alarm on dead-letter depth, or document that the path is intentionally unmonitored

**INT-03 (SHOULD): No dead or permanently disabled code**

Check: Are there resources with hard-coded `count = 0`, commented-out resources, or variables/outputs/locals that nothing uses?
Why: Dead code misleads readers, keeps stale references (for example to resources that no longer exist when re-enabled) and hides which behavior is actually active
Fix: Remove it, or turn it into an explicit enable flag with a comment stating why it is off and what would be needed to enable it
