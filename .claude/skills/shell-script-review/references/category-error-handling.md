## Error Handling (ERR)

**ERR-01 (SHOULD): Trap EXIT/ERR/INT/TERM when cleanup is required**

Check: Are trap handlers set for EXIT, ERR, INT, TERM when the script creates temporary resources or must clean up on interrupt?
Why: Missing traps prevent cleanup, causing resource leaks and temporary file remnants
Fix: Set `trap 'cleanup' EXIT ERR`, implement cleanup function

**ERR-02 (SHOULD): Check exit codes; avoid blanket || true**

Check: Are command exit codes properly checked without overusing `|| true`?
Why: Not checking exit codes or overusing `|| true` prevents failure detection, causing silent failures
Fix: Check `$?`, use `|| error_exit`, apply proper error handling

**ERR-03 (SHOULD): Errors include enough context to locate the failure**

Check: Do error messages include enough context to locate the failure (command, path, or relevant values)?
Why: Unclear messages make debugging difficult, delay problem identification, confuse users
Fix: Use clear messages, output variable values, add `"${BASH_SOURCE}:${LINENO}"` when helpful

**ERR-04 (SHOULD): Clean up temps/processes/locks on exit**

Check: Does cleanup release temporary files, background processes, and locks?
Why: Missing cleanup causes disk leaks, process leaks, deadlocks
Fix: Implement cleanup function, set trap, ensure resource release

**ERR-05 (SHOULD): Use set +e / set -e explicitly for tolerated failures**

Check: Is `set +e` / `set -e` explicitly used for acceptable errors instead of opaque `|| true`?
Why: Overusing `|| true` in `set -e` context reduces readability and obscures intent
Fix: Use `set +e; command; set -e`, explicitly document error tolerance
