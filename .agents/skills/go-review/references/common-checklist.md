# Go Review Checklist

## Architecture (ARCH)
- ARCH-01 (SHOULD): Layer Separation
- ARCH-02 (SHOULD): Dependency Injection
- ARCH-03 (SHOULD): Domain-Driven Design
- ARCH-04 (SHOULD): SOLID Principles
- ARCH-05 (SHOULD): Appropriate Package Structure
- ARCH-06 (SHOULD): Unified Configuration Management
- ARCH-07 (SHOULD): Unified Log Management
- ARCH-08 (SHOULD): Unified Error Management
- ARCH-09 (SHOULD): External Integration Abstraction
- ARCH-10 (SHOULD): Module Design

## Code Standards (CODE)
- CODE-01 (SHOULD): Appropriate Interface Design
- CODE-02 (SHOULD): API/Package Boundary Design
- CODE-03 (SHOULD): Appropriate Struct Design
- CODE-04 (SHOULD): Safe Type Assertions
- CODE-05 (SHOULD): Appropriate defer Usage
- CODE-06 (SHOULD): Appropriate slice/map Operations
- CODE-07 (SHOULD): Error String Format
- CODE-08 (SHOULD): Import Grouping
- CODE-09 (SHOULD): Avoid Naked Returns in Long Functions

## Concurrency (CON)
- CON-01 (SHOULD): Avoid goroutine Leaks
- CON-02 (SHOULD): Clarify channel close Responsibility
- CON-03 (SHOULD): Appropriate buffered/unbuffered channel Selection
- CON-04 (SHOULD): Appropriate sync primitives Usage
- CON-05 (SHOULD): for+goroutine Variable Capture Issue
- CON-06 (SHOULD): data race Detection and Prevention

## Context Handling (CTX)
- CTX-01 (SHOULD): Accept context in public APIs
- CTX-02 (SHOULD): Avoid context.Background()/TODO() Overuse
- CTX-03 (SHOULD): Propagate context to goroutines
- CTX-04 (SHOULD): Appropriate cancel Invocation

## Dependencies (DEP)
- DEP-01 (SHOULD): Explicit Direct Dependencies
- DEP-02 (SHOULD): Dependency Update Strategy
- DEP-03 (SHOULD): vendor Management (Only When Necessary)
- DEP-04 (SHOULD): Prioritize Standard Library
- DEP-05 (SHOULD): AWS SDK Version Management
- DEP-06 (SHOULD): Separate Development Dependencies
- DEP-07 (SHOULD): License Compatibility

## Documentation (DOC)
- DOC-01 (SHOULD): Package Documentation Exists
- DOC-02 (SHOULD): godoc for Public Functions
- DOC-03 (SHOULD): Complex Logic Comments
- DOC-04 (SHOULD): Struct Field Comments
- DOC-05 (SHOULD): Constant and Variable Descriptions
- DOC-06 (SHOULD): English Comment Consistency
- DOC-07 (SHOULD): README.md Maintenance
- DOC-08 (SHOULD): API Specification (OpenAPI)
- DOC-09 (SHOULD): Operations Documentation
- DOC-10 (SHOULD): CHANGELOG

## Error Handling (ERR)
- ERR-01 (SHOULD): Appropriate Error Wrapping
- ERR-02 (SHOULD): Appropriate Custom Error Definition
- ERR-03 (SHOULD): Avoid and Recover from Panics
- ERR-04 (SHOULD): Appropriate Error Log Information
- ERR-05 (SHOULD): Error Propagation to Upper Layers
- ERR-06 (SHOULD): Error Handling Strategy
- ERR-07 (SHOULD): External Dependency Error Handling
- ERR-08 (SHOULD): Validation Errors
- ERR-09 (SHOULD): Error Message Security

## Function Design (FUNC)
- FUNC-01 (SHOULD): Appropriate Function Splitting
- FUNC-02 (SHOULD): Appropriate Argument Design
- FUNC-03 (SHOULD): Return Value Design
- FUNC-04 (SHOULD): Recommend Pure Functions
- FUNC-05 (SHOULD): Appropriate Receiver Design
- FUNC-06 (SHOULD): Method Set Design
- FUNC-07 (SHOULD): Appropriate Initialization Functions
- FUNC-08 (SHOULD): Leverage Higher-Order Functions
- FUNC-09 (SHOULD): Appropriate Generics Usage
- FUNC-10 (SHOULD): Comprehensive Function Documentation

## Global / Base (G)
- G-01 (SHOULD): No Hardcoded Secrets
- G-02 (SHOULD): Appropriate Function Signatures
- G-03 (SHOULD): Leverage Standard Library
- G-04 (SHOULD): Appropriate Log Levels
- G-05 (MUST): Declaration Order (File Level)
- G-06 (SHOULD): Declaration Order (Within Groups)
- G-07 (SHOULD): Restrict init() Complexity
- G-08 (SHOULD): Zero Value Design
- G-09 (SHOULD): Defensive Copy at Boundaries

## Performance (PERF)
- PERF-01 (SHOULD): Memory Optimization
- PERF-02 (SHOULD): CPU Optimization
- PERF-03 (SHOULD): I/O Optimization
- PERF-04 (SHOULD): Appropriate Data Structure Selection
- PERF-05 (SHOULD): GC Consideration
- PERF-06 (SHOULD): String Processing Optimization
- PERF-07 (SHOULD): Parallel Processing Optimization
- PERF-08 (SHOULD): Caching Strategy
- PERF-09 (SHOULD): Leverage pprof
- PERF-10 (SHOULD): Hot Path Optimization

## Security (SEC)
- SEC-01 (SHOULD): Input Validation
- SEC-02 (SHOULD): Output Sanitization
- SEC-03 (SHOULD): Appropriate Encryption
- SEC-04 (SHOULD): Authentication and Authorization Implementation
- SEC-05 (SHOULD): Rate Limiting and DOS Prevention
- SEC-06 (SHOULD): Log Security
- SEC-07 (SHOULD): Secure Defaults
- SEC-08 (SHOULD): OWASP Compliance

## Testing (TEST)
- TEST-01 (SHOULD): Table-Driven Tests
- TEST-02 (SHOULD): testify Usage and Test Design
- TEST-03 (SHOULD): Appropriate Mock Usage
- TEST-04 (SHOULD): Separate Test Helpers
- TEST-05 (SHOULD): Benchmark Tests
- TEST-06 (SHOULD): Separate Integration Tests
- TEST-07 (SHOULD): Test Data Management
- TEST-08 (SHOULD): Efficient Test Parallel Execution
- TEST-09 (SHOULD): Use t.Helper() in Test Helpers
