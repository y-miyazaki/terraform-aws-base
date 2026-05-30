## Logging (LOG)

**LOG-01 (SHOULD): Separate stdout/stderr**

Check: Are errors clearly separated to >&2 and info to stdout?
Why: Error messages to stdout make error detection difficult, complicate log analysis
Fix: Errors to `>&2`, info to stdout, clear separation

**LOG-02 (SHOULD): Implement Log Levels**

Check: Are INFO, WARN, ERROR log levels implemented?
Why: Missing log levels cause log noise, important logs buried, difficult monitoring
Fix: Implement INFO/WARN/ERROR levels

**LOG-03 (SHOULD): Structured Logging**

Check: Is structured log format with timestamp, level, message used?
Why: Unstructured logs make log analysis difficult, prevent chronological tracking
Fix: Use `[timestamp] [LEVEL] message` format, structured logging

**LOG-04 (SHOULD): Mask Sensitive Information**

Check: Are passwords and tokens masked before logging?
Why: Logging sensitive information causes credential leakage, security risks
Fix: Mask sensitive variables with `***`, filter before logging

**LOG-05 (SHOULD): Implement verbose**

Check: Is detailed log control available with -v/--verbose option?
Why: Debug logs in production cause log bloat, important logs buried
Fix: Add -v/--verbose option, conditional detailed logging, level control
