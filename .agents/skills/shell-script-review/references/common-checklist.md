# Shell Script Review Checklist

## Code Standards (CODE)
- CODE-01 (SHOULD): Proper Array Usage
- CODE-02 (SHOULD): Minimize Global Variables
- CODE-03 (SHOULD): Proper Here Document Usage
- CODE-04 (SHOULD): Proper Process Substitution Usage
- CODE-05 (SHOULD): Single Responsibility Functions with Explicit Arguments

## Dependencies (DEP)
- DEP-01 (SHOULD): Leverage lib/all.sh
- DEP-02 (SHOULD): Use validate_dependencies
- DEP-03 (SHOULD): Document Required Commands
- DEP-04 (SHOULD): Command Existence Check

## Documentation (DOC)
- DOC-01 (SHOULD): Standard Header Format
- DOC-02 (SHOULD): show_usage Required
- DOC-03 (SHOULD): Function Separators and Comments
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
- FUNC-05 (SHOULD): Leverage Common Library
- FUNC-06 (SHOULD): validate_dependencies Function
- FUNC-07 (SHOULD): Implement main Function

## Global / Base (G)
- G-01 (SHOULD): Set SCRIPT_DIR and Source lib/all.sh
- G-02 (SHOULD): No Hardcoded Secrets
- G-03 (SHOULD): Follow Function Order
- G-04 (SHOULD): Remove Dead Code
- G-05 (SHOULD): Use error_exit for Error Handling
- G-06 (SHOULD): Script Idempotency

## Logging (LOG)
- LOG-01 (SHOULD): Leverage log_message/echo_section
- LOG-02 (SHOULD): Separate stdout/stderr
- LOG-03 (SHOULD): Implement Log Levels
- LOG-04 (SHOULD): Structured Logging
- LOG-05 (SHOULD): Mask Sensitive Information
- LOG-06 (SHOULD): Section Separators with echo_section
- LOG-07 (SHOULD): Implement verbose

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
- TEST-01 (SHOULD): Implement Unit Tests
- TEST-02 (SHOULD): Bats Test Functions in a-z Order
- TEST-03 (SHOULD): CI/CD Integration
