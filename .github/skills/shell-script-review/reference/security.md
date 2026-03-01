### 5. Security (SEC)

**SEC-01: Input Validation**

Check: Is user input validated with regex patterns or whitelists?
Why: Unvalidated input enables command injection, path traversal, data corruption
Fix: Validate input with regex patterns, whitelists, and range checks

**SEC-02: Command Injection Prevention**

Check: Are all variables quoted with `"$var"` and eval avoided?
Why: Unquoted variables or eval use enable arbitrary command execution, privilege escalation, system compromise
Fix: Quote all variables with `"$var"`, avoid eval, use arrays

**SEC-03: Path Traversal Prevention**

Check: Are paths normalized with realpath and restricted to allowed directories?
Why: Allowing `../` enables unauthorized file access, data leakage, tampering
Fix: Use realpath, normalize paths, restrict to allowed directories

**SEC-04: Temporary File Cleanup**

Check: Are temporary files created with mktemp and cleaned up with trap?
Why: Predictable paths with fixed names enable symlink attacks and information leakage
Fix: Use `mktemp -d`, clean up with trap, use secure paths

**SEC-05: Permission Checks**

Check: Are required permissions (root, etc.) validated before execution?
Why: Missing permission checks cause execution failures, partial success, security risks
Fix: Use `[[ $EUID -eq 0 ]]` checks with appropriate error messages

**SEC-06: Sensitive Data Masking in Logs**

Check: Are passwords and tokens masked before logging?
Why: Logging sensitive data causes credential leakage, audit log pollution, security compromise
Fix: Mask sensitive variables with `***`, filter before logging

**SEC-07: External Command Validation**

Check: Are external commands invoked via absolute paths or verified with command -v?
Why: PATH-dependent invocation enables command hijacking, malware execution, unexpected behavior
Fix: Use absolute paths like `/usr/bin/`, verify with command -v

**SEC-08: Environment Variable Isolation**

Check: Are environment variables explicitly initialized with defaults?
Why: Trusting inherited environment variables causes unexpected behavior, security bypass, data corruption
Fix: Explicitly initialize environment variables, set defaults, validate

**SEC-09: Secure Defaults (umask 027)**

Check: Is umask 027 set and least privilege principle applied?
Why: Default umask settings enable information leakage, unauthorized access, sensitive file exposure
Fix: Set umask 027, explicitly set permissions, apply least privilege principle
