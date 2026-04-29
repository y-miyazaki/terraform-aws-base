# Shell Script Code Review Checklist

## Global & Base

- GLOBAL-01: SCRIPT_DIR and script location handling
- GLOBAL-02: lib/all.sh sourcing and common functions
- GLOBAL-03: Script header and documentation
- GLOBAL-04: Shebang and overall structure

## Code Standards

- STD-01: Naming conventions (variables, functions)
- STD-02: Quoting and expansion patterns
- STD-03: Script template compliance
- STD-04: Comments and function docstrings

## Function Design

- FUNC-01: Function parameters and return values
- FUNC-02: Local variable scope
- FUNC-03: Function cohesion and responsibility

## Error Handling

- ERR-01: error_exit usage and consistency
- ERR-02: cleanup trap configuration
- ERR-03: Error checking patterns
- ERR-04: Exit codes and signals

## Security

- SEC-01: Input validation
- SEC-02: Path traversal prevention
- SEC-03: Command injection prevention
- SEC-04: File permission handling

## Performance

- PERF-01: Command efficiency
- PERF-02: Unnecessary process forks
- PERF-03: Pipeline optimization
- PERF-04: Subshell avoidance

## Testing

- TEST-01: Unit test structure  (bats framework)
- TEST-02: Mock function usage
- TEST-03: Edge case coverage
- TEST-04: Integration test patterns

## Documentation

- DOC-01: Function docstrings
- DOC-02: Usage examples
- DOC-03: Parameter documentation
- DOC-04: Overall script documentation

## Dependencies

- DEPS-01: External command availability
- DEPS-02: Version requirements
- DEPS-03: aqua dependency management

## Logging

- LOG-01: log_info usage
- LOG-02: log_warn usage
- LOG-03: log_error usage
- LOG-04: Log consistency
