# Go Review Checklist

## Global & Base

- G-01: No Hardcoded Secrets
- G-02: Appropriate Function Signatures
- G-03: Leverage Standard Library
- G-04: Appropriate Log Levels
- G-05: Declaration Order (File Level)
- G-06: Declaration Order (Within Groups)
- G-07: Restrict init() Complexity
- G-08: Zero Value Design
- G-09: Defensive Copy at Boundaries

## Context Handling (CTX)

- CTX-01: Accept context in public APIs
- CTX-02: Avoid context.Background()/TODO() Overuse
- CTX-03: Propagate context to goroutines
- CTX-04: Appropriate cancel Invocation

## Concurrency (CON)

- CON-01: Avoid goroutine Leaks
- CON-02: Clarify channel close Responsibility
- CON-03: Appropriate buffered/unbuffered channel Selection
- CON-04: Appropriate sync primitives Usage
- CON-05: for+goroutine Variable Capture Issue
- CON-06: data race Detection and Prevention

## Code Standards (CODE)

- CODE-01: Appropriate Interface Design
- CODE-02: API/Package Boundary Design
- CODE-03: Appropriate Struct Design
- CODE-04: Safe Type Assertions
- CODE-05: Appropriate defer Usage
- CODE-06: Appropriate slice/map Operations
- CODE-07: Error String Format
- CODE-08: Import Grouping
- CODE-09: Avoid Naked Returns in Long Functions

## Function Design (FUNC)

- FUNC-01: Appropriate Function Splitting
- FUNC-02: Appropriate Argument Design
- FUNC-03: Return Value Design
- FUNC-04: Recommend Pure Functions
- FUNC-05: Appropriate Receiver Design
- FUNC-06: Method Set Design
- FUNC-07: Appropriate Initialization Functions
- FUNC-08: Leverage Higher-Order Functions
- FUNC-09: Appropriate Generics Usage
- FUNC-10: Comprehensive Function Documentation

## Error Handling (ERR)

- ERR-01: Appropriate Error Wrapping
- ERR-02: Appropriate Custom Error Definition
- ERR-03: Avoid and Recover from Panics
- ERR-04: Appropriate Error Log Information
- ERR-05: Error Propagation to Upper Layers
- ERR-06: Error Handling Strategy
- ERR-07: External Dependency Error Handling
- ERR-08: Validation Errors
- ERR-09: Error Message Security

## Security (SEC)

- SEC-01: Input Validation
- SEC-02: Output Sanitization
- SEC-03: Appropriate Encryption
- SEC-04: Authentication and Authorization Implementation
- SEC-05: Rate Limiting and DOS Prevention
- SEC-06: Log Security
- SEC-07: Secure Defaults
- SEC-08: OWASP Compliance

## Performance (PERF)

- PERF-01: Memory Optimization
- PERF-02: CPU Optimization
- PERF-03: I/O Optimization
- PERF-04: Appropriate Data Structure Selection
- PERF-05: GC Consideration
- PERF-06: String Processing Optimization
- PERF-07: Parallel Processing Optimization
- PERF-08: Caching Strategy
- PERF-09: Leverage pprof
- PERF-10: Hot Path Optimization

## Testing (TEST)

- TEST-01: Table-Driven Tests
- TEST-02: testify Usage and Test Design
- TEST-03: Appropriate Mock Usage
- TEST-04: Separate Test Helpers
- TEST-05: Benchmark Tests
- TEST-06: Separate Integration Tests
- TEST-07: Test Data Management
- TEST-08: Efficient Test Parallel Execution
- TEST-09: Use t.Helper() in Test Helpers

## Documentation (DOC)

- DOC-01: Package Documentation Exists
- DOC-02: godoc for Public Functions
- DOC-03: Complex Logic Comments
- DOC-04: Struct Field Comments
- DOC-05: Constant and Variable Descriptions
- DOC-06: English Comment Consistency
- DOC-07: README.md Maintenance
- DOC-08: API Specification (OpenAPI)
- DOC-09: Operations Documentation
- DOC-10: CHANGELOG

## Architecture (ARCH)

- ARCH-01: Layer Separation
- ARCH-02: Dependency Injection
- ARCH-03: Domain-Driven Design
- ARCH-04: SOLID Principles
- ARCH-05: Appropriate Package Structure
- ARCH-06: Unified Configuration Management
- ARCH-07: Unified Log Management
- ARCH-08: Unified Error Management
- ARCH-09: External Integration Abstraction
- ARCH-10: Module Design

## Dependencies (DEP)

- DEP-01: Explicit Direct Dependencies
- DEP-02: Dependency Update Strategy
- DEP-03: vendor Management (Only When Necessary)
- DEP-04: Prioritize Standard Library
- DEP-05: AWS SDK Version Management
- DEP-06: Separate Development Dependencies
- DEP-07: License Compatibility
