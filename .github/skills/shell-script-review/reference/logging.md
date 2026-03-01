### 10. Logging (LOG)

**LOG-01: Leverage log_message/echo_section**

Check: Are log_message and echo_section functions utilized?
Why: Direct echo output causes inconsistent log format, missing timestamps, difficult monitoring
Fix: Use log_message, echo_section separators, follow project standards

**LOG-02: Separate stdout/stderr**

Check: Are errors clearly separated to >&2 and info to stdout?
Why: Error messages to stdout make error detection difficult, complicate log analysis
Fix: Errors to `>&2`, info to stdout, clear separation

**LOG-03: Implement Log Levels**

Check: Are INFO, WARN, ERROR log levels implemented?
Why: Missing log levels cause log noise, important logs buried, difficult monitoring
Fix: Implement INFO/WARN/ERROR levels, specify level in log_message argument

**LOG-04: Structured Logging**

Check: Is structured log format with timestamp, level, message used?
Why: Unstructured logs make log analysis difficult, prevent chronological tracking
Fix: Use `[timestamp] [LEVEL] message` format, structured logging

**LOG-05: Mask Sensitive Information**

Check: Are passwords and tokens masked before logging?
Why: Logging sensitive information causes credential leakage, security risks
Fix: Mask sensitive variables with `***`, filter before logging

**LOG-06: Section Separators with echo_section**

Check: Are processing units separated with echo_section?
Why: Missing section separators make log tracking difficult, debugging hard
Fix: Use echo_section, separate processing units, improve visibility

**LOG-07: Implement verbose**

Check: Is detailed log control available with -v/--verbose option?
Why: Debug logs in production cause log bloat, important logs buried
Fix: Add -v/--verbose option, conditional detailed logging, level control
