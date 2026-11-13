# Configuration Completeness (CFG)

Findings here are about arguments and module inputs that are **missing or left to defaults**, not about arguments that are present but wrong. They are not detectable by `terraform validate`, `tflint` or static security scanners, so evaluate them from source.

How to find omissions: for each resource type and module call in scope, read its documentation at the pinned version (the Terraform Registry page for the provider resource or module, including the module's inputs) and compare the full argument or input list against the code, not only against the diff. Do not rely on memory of defaults or available arguments. When many resources of the same type are in scope, sweep them with a search or script that reports which ones lack an argument instead of sampling by eye. When the documentation cannot be read, defer the check and name the evidence needed. When read-only access to the live environment is available, use it to confirm the actual state.

**CFG-01 (SHOULD): Security-relevant arguments are set explicitly, not left to provider/service defaults**

Check: For each resource type in scope, are the arguments that decide security posture set explicitly (encryption key, key rotation, public access restriction, audit-log integrity, TLS and metadata-service requirements, deletion protection, point-in-time recovery, feature or protection-plan toggles)?
Why: Defaults differ between provider versions and service releases, and some arguments are applied only at creation time (for example a default-standards or auto-enable flag). Implicit defaults make the real configuration invisible in code and impossible to review
Fix: Set the argument explicitly (or expose it as a variable whose default equals the current behavior). When leaving a default on purpose, say so in a comment

**CFG-02 (SHOULD): Reliability and failure-handling arguments are set explicitly**

Check: Do asynchronous or event-driven resources set retry and timeout, failure destination or dead-letter target, concurrency limits, and backup or retention arguments?
Why: Defaults are often implicit and sometimes surprising (for example messages are dropped silently after the default retry window when no dead-letter target exists), so failure behavior cannot be reviewed or tuned
Fix: Set the value explicitly, preferably through a module variable whose default equals the service default. If a dead-letter target or limit is intentionally omitted (no consumer, no known sizing), record the reason in a comment instead of leaving it silent

**CFG-03 (SHOULD): Module calls cover the module's security and operations inputs**

Check: For each call to a registry or in-repo module, compare the call against the module's input list (not just the resources it wraps). Are inputs for encryption keys, logging and tracing, retention, ownership or access guards, and failure handling set or consciously omitted?
Why: The wrapped resource's arguments are hidden behind module inputs, so a resource-level review misses them. Mature modules expose many secure options that stay off by default
Fix: Read the module's Registry page (or variable definitions) at the pinned version, set the relevant inputs, and note deliberate omissions

**CFG-04 (SHOULD): Sibling resources and modules are configured symmetrically**

Check: Where two modules or stacks configure the same service from different sides (for example an administrative stack and a member stack, or primary and secondary region), do they expose the same set of options?
Why: A feature configurable on only one side silently falls back to defaults on the other, which causes drift between environments and surprises during rollout
Fix: Add the missing inputs on the lagging side with a safe default (disabled or empty), or document why the asymmetry is intended

**CFG-05 (SHOULD): Intentional omissions and suppressions are documented**

Check: Is every deliberate gap (scanner ignore comment, disabled resource, omitted dead-letter target, default left as is) explained next to the code?
Why: Without a reason, a later reviewer cannot tell an intentional omission from an oversight, and the gap is re-reported or "fixed" incorrectly
Fix: Add a short comment stating what is omitted and why; remove the suppression when it no longer applies
