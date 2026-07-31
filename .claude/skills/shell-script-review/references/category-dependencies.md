# Dependencies (DEP)

**DEP-01 (SHOULD): Verify required commands with command -v before use**

Check: Are required external commands verified with `command -v` and clear error messages before use?
Why: Missing command checks cause runtime errors with unclear messages and delayed failure
Fix: Use `command -v` checks, provide clear error messages, show installation instructions when helpful
