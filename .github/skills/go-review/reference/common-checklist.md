# Go Code Review Checklist

## Error Handling

- ERR-01: Error wrapping and stack traces
- ERR-02: Sentinel error usage
- ERR-03: Error message clarity and context
- ERR-04: Panic usage justification

## Context & Concurrency

- CTX-01: context.Context propagation
- CTX-02: context timeout and cancellation
- CONC-01: Goroutine safety (race conditions)
- CONC-02: Channel patterns and deadlocks
- CONC-03: Mutex correctness

## Code Standards

- STD-01: Naming conventions (variables, functions, packages)
- STD-02: Simplicity and readability
- STD-03: Golf anti-pattern (avoiding overly terse code)
- STD-04: Comments and documentation

## Function Design

- FUNC-01: Parameter and return value design
- FUNC-02: Interface design and compliance
- FUNC-03: Function cohesion and responsibility

## Security

- SEC-01: Input validation
- SEC-02: Cryptographic usage
- SEC-03: SQL injection prevention
- SEC-04: Secret handling (no hardcoding)

## Performance

- PERF-01: Memory allocations and efficiency
- PERF-02: String operations (avoid concatenation)
- PERF-03: Collection preallocation
- PERF-04: Unnecessary boxing/unboxing

## Testing

- TEST-01: Test structure and clarity
- TEST-02: Table-driven test patterns
- TEST-03: Mocking and dependencies
- TEST-04: Coverage and edge cases

## Architecture

- ARCH-01: Package design and dependencies
- ARCH-02: Dependency injection patterns
- ARCH-03: Interface cohesion

## Dependencies

- DEPS-01: Module versioning
- DEPS-02: Dependency minimization
