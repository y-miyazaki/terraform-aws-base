# Logging (LOG)

**LOG-01 (SHOULD): Errors go to stderr; normal output to stdout**

Check: Are errors clearly separated to >&2 and normal output to stdout?
Why: Error messages to stdout make error detection difficult, complicate log analysis and piping
Fix: Errors to `>&2`, info to stdout, clear separation

**LOG-02 (SHOULD): Mask passwords/tokens before logging/echo**

Check: Are passwords and tokens masked before logging or echoing?
Why: Logging sensitive information causes credential leakage, security risks
Fix: Mask sensitive variables with `***`, filter before logging
