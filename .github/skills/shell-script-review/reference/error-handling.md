### 4. Error Handling (ERR)

**ERR-01: Trap Configuration**

Check: Are trap handlers set for EXIT, ERR, INT, TERM?
Why: Missing traps prevent cleanup, causing resource leaks and temporary file remnants
Fix: Set `trap 'cleanup' EXIT ERR`, implement cleanup function

**ERR-02: Exit Code Checking**

Check: Are command exit codes properly checked?
Why: Not checking exit codes or overusing `|| true` prevents failure detection, causing silent failures
Fix: Check `$?`, use `|| error_exit`, apply proper error handling

**ERR-03: Clear Error Messages**

Check: Do error messages include context information and line numbers?
Why: Unclear messages make debugging difficult, delay problem identification, confuse users
Fix: Use clear messages, output variable values, add `"${BASH_SOURCE}:${LINENO}"`

**ERR-04: Resource Cleanup**

Check: Does cleanup function release temporary files, processes, and locks?
Why: Missing cleanup causes disk leaks, process leaks, deadlocks
Fix: Implement cleanup function, set trap, ensure resource release

**ERR-05: Retry Strategy**

Check: Is there a retry strategy for transient errors?
Why: No retry strategy increases operational burden, prevents auto-recovery, reduces availability
Fix: Implement retry loop, use exponential backoff, set max retry count

**ERR-06: Partial Failure Tolerance**

Check: Is `set +e` explicitly used for acceptable errors?
Why: Overusing `|| true` in `set -e` context reduces readability and obscures intent
Fix: Use `set +e; command; set -e`, explicitly document error tolerance

**ERR-07: Error Logging**

Check: Are errors persistently logged to a log file?
Why: Output-only errors make failure history unclear, prevent trend analysis, hinder post-incident investigation
Fix: Log errors to file with timestamps, implement log rotation
