# Security (SEC)

**SEC-01 (SHOULD): Validate user input used in paths/commands**

Check: Is user input validated with regex patterns or whitelists when used in paths, commands, or destructive operations?
Why: Unvalidated input enables command injection, path traversal, data corruption
Fix: Validate input with regex patterns, whitelists, and range checks

**SEC-02 (SHOULD): Quote expansions; avoid eval on untrusted input**

Check: Are variables quoted with `"$var"` where needed, and is `eval` avoided for untrusted input?
Why: Unquoted variables or eval use enable arbitrary command execution, privilege escalation, system compromise
Fix: Quote variables with `"$var"`, avoid eval, use arrays for argument lists

**SEC-03 (SHOULD): Normalize/restrict user-controlled paths**

Check: Are user-controlled paths normalized and restricted to allowed directories when the script writes or reads outside a known root?
Why: Allowing `../` enables unauthorized file access, data leakage, tampering
Fix: Use realpath/normalization, restrict to allowed directories

**SEC-04 (SHOULD): Create temps with mktemp and trap cleanup**

Check: Are temporary files created with mktemp and cleaned up with trap?
Why: Predictable paths with fixed names enable symlink attacks and information leakage
Fix: Use `mktemp -d`, clean up with trap, use secure paths

**SEC-05 (SHOULD): Check privileges before destructive/privileged ops**

Check: Are required privileges (root, sudo, writable paths) validated before destructive or privileged operations?
Why: Missing permission checks cause execution failures, partial success, security risks
Fix: Use appropriate EUID/path writability checks with clear error messages

**SEC-06 (SHOULD): Initialize/validate inherited env that affects behavior**

Check: Are inherited environment variables that affect behavior explicitly initialized or validated?
Why: Trusting inherited environment variables causes unexpected behavior, security bypass, data corruption
Fix: Explicitly initialize environment variables, set defaults, validate

**SEC-07 (SHOULD): Set umask 027 (or stricter) near script start**

Check: Is umask 027 (or stricter) set near script start with other secure defaults?
Why: Default umask settings enable information leakage, unauthorized access, sensitive file exposure
Fix: Set umask 027, explicitly set permissions, apply least privilege principle
