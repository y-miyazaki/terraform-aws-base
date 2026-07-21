# Shell Script Review Checklist

## Anti-Patterns (AP)

- AP-01 (SHOULD): Executable Rules on Sourced Libraries
- AP-02 (SHOULD): Preserve DOC Comment Blocks
- AP-03 (SHOULD): Globals Section Required
- AP-04 (SHOULD): Consistent Library Comment Style

## Code Standards (CODE)

- CODE-01 (SHOULD): Proper Array Usage
- CODE-02 (SHOULD): Minimize Global Variables
- CODE-03 (SHOULD): Proper Here Document Usage
- CODE-04 (SHOULD): Proper Process Substitution Usage
- CODE-05 (SHOULD): Single Responsibility Functions with Explicit Arguments

## Dependencies (DEP)

- DEP-01 (SHOULD): Document Required Commands
- DEP-02 (SHOULD): Command Existence Check

## Documentation (DOC)

- DOC-01 (MUST): Standard Header Format
- DOC-02 (SHOULD): show_usage Required
- DOC-03 (SHOULD): Function Comment Blocks
- DOC-04 (SHOULD): Complex Logic Comments
- DOC-05 (SHOULD): Variable Documentation
- DOC-06 (SHOULD): English Comment Consistency
- DOC-07 (SHOULD): README.md Maintenance
- DOC-08 (SHOULD): Error Message Documentation
- DOC-09 (SHOULD): CHANGELOG History

## Error Handling (ERR)

- ERR-01 (SHOULD): Trap Configuration
- ERR-02 (SHOULD): Exit Code Checking
- ERR-03 (SHOULD): Clear Error Messages
- ERR-04 (SHOULD): Resource Cleanup
- ERR-05 (SHOULD): Retry Strategy
- ERR-06 (SHOULD): Partial Failure Tolerance
- ERR-07 (SHOULD): Error Logging

## Function Design (FUNC)

- FUNC-01 (SHOULD): Functions Under 50 Lines Recommended
- FUNC-02 (SHOULD): Standardize parse_arguments
- FUNC-03 (SHOULD): Implement show_usage
- FUNC-04 (SHOULD): Return Value Design
- FUNC-05 (SHOULD): Implement main Function

## Global / Base (G)

- G-01 (MUST): Set SCRIPT_DIR
- G-02 (SHOULD): No Hardcoded Secrets
- G-03 (MUST): Follow Function Order
- G-04 (SHOULD): Remove Dead Code
- G-05 (SHOULD): Script Idempotency

## Logging (LOG)

- LOG-01 (SHOULD): Separate stdout/stderr
- LOG-02 (SHOULD): Implement Log Levels
- LOG-03 (SHOULD): Structured Logging
- LOG-04 (SHOULD): Mask Sensitive Information
- LOG-05 (SHOULD): Implement verbose

## Performance (PERF)

- PERF-01 (SHOULD): Minimize External Commands
- PERF-02 (SHOULD): Reduce Subshells
- PERF-03 (SHOULD): Optimize File I/O
- PERF-04 (SHOULD): Efficient Loops
- PERF-05 (SHOULD): Optimize String Processing
- PERF-06 (SHOULD): Optimize Conditional Branching
- PERF-07 (SHOULD): Leverage Parallel Execution
- PERF-08 (SHOULD): Caching Strategy
- PERF-09 (SHOULD): Resource Limits (ulimit)
- PERF-10 (SHOULD): Profiling

## Security (SEC)

- SEC-01 (SHOULD): Input Validation
- SEC-02 (SHOULD): Command Injection Prevention
- SEC-03 (SHOULD): Path Traversal Prevention
- SEC-04 (SHOULD): Temporary File Cleanup
- SEC-05 (SHOULD): Permission Checks
- SEC-06 (SHOULD): Sensitive Data Masking in Logs
- SEC-07 (SHOULD): External Command Validation
- SEC-08 (SHOULD): Environment Variable Isolation
- SEC-09 (SHOULD): Secure Defaults (umask 027)

## Testing (TEST)

- TEST-00 (MUST): Add Tests With Script Changes
- TEST-01 (MUST): Implement Unit Tests
- TEST-02 (SHOULD): Bats Test Functions in a-z Order
- TEST-03 (SHOULD): CI/CD Integration
