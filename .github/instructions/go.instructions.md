---
applyTo: "**/*.go"
description: "AI Assistant Instructions for Go Development"
---

# AI Assistant Instructions for Go Development

## Scope

- Scope is limited to implementing, testing, and validating Go source code (`*.go`).

## Standards

### Naming Conventions

| Component | Rule       | Example          |
| --------- | ---------- | ---------------- |
| Interface | er suffix  | UserRepository   |
| File name | snake_case | event_handler.go |

### Core Go Conventions

- **S-01 (MUST)**: Add GoDoc-style comments to public APIs - package, public functions, methods, and structs are in scope.
- **S-02 (MUST)**: Use lowercase single-word names for packages - this preserves readability and import consistency.
- **S-03 (MUST)**: Prohibit ignored errors (`_` assignment) - allow exceptions only with explicit rationale.
- **S-04 (MUST)**: Prefer error wrapping with `fmt.Errorf(... %w ...)` - keep causal tracing available to callers.

### File Declaration Order

- **G-05 (MUST)**: Enforce declaration order within each file - inconsistent order reduces code navigability:
  1. const
  2. var
  3. type（interface → struct）
  4. func（constructor → public methods → private methods → helpers）
- **G-06 (SHOULD)**: Keep declarations in alphabetical order inside each section where practical. Place `main` first in the function section.

### Unexported Helper Placement

| Condition                             | Preferred placement              |
| ------------------------------------- | -------------------------------- |
| Single-struct-specific responsibility | Unexported method on that struct |
| Pure helper shared across types/files | Package-level free function      |

## Guidelines

### Architecture (ARCH)

- ARCH-01 (SHOULD): Layer Separation
  - Check: Are handler/usecase/repository separated and business/infrastructure layers separated?
- ARCH-02 (SHOULD): Dependency Injection
  - Check: Are constructor injection, wire/dig utilization, and interface dependencies present?
- ARCH-03 (SHOULD): Domain-Driven Design
  - Check: Are aggregate roots defined, Value Objects utilized, and Repositories abstracted?
- ARCH-04 (SHOULD): SOLID Principles
  - Check: Are SRP/OCP/LSP/ISP/DIP applied, interfaces segregated, and abstractions used?
- ARCH-05 (SHOULD): Appropriate Package Structure
  - Check: Are there no circular dependencies, standard layout compliance, and internal/ utilization?
- ARCH-06 (SHOULD): Unified Configuration Management
  - Check: Are viper/envconfig used, config structs consolidated, and environment variables prioritized?
- ARCH-07 (SHOULD): Unified Log Management
  - Check: Are zap/zerolog unified, structured logging used, and trace ID propagated?
- ARCH-08 (SHOULD): Unified Error Management
  - Check: Are error packages consolidated, error code systems defined, and standardized?
- ARCH-09 (SHOULD): External Integration Abstraction
  - Check: Are adapter patterns, interface definitions, and abstraction layers implemented?
- ARCH-10 (SHOULD): Module Design
  - Check: Are boundaries clear, loosely coupled, highly cohesive, and public APIs minimized?

### Code Standards (CODE)

- CODE-01 (SHOULD): Appropriate Interface Design
  - Check: Are interface method counts (5+) and consumer-side definitions appropriate?
- CODE-02 (SHOULD): API/Package Boundary Design
  - Check: Are there no excessive exports, unclear package name responsibilities, or unused internal/?
- CODE-03 (SHOULD): Appropriate Struct Design
  - Check: Are there no public fields, exposed mutexes, or excessive field counts (20+)?
- CODE-04 (SHOULD): Safe Type Assertions
  - Check: Do type assertions have ok checks (v, ok := i.(string) format)?
- CODE-05 (SHOULD): Appropriate defer Usage
  - Check: Are there no defer in loops and is resource release appropriate?
- CODE-06 (SHOULD): Appropriate slice/map Operations
  - Check: Are nil checks, out-of-bounds prevention, and map race condition measures present?
- CODE-07 (SHOULD): Error String Format
  - Check: Do error strings start with a lowercase letter and have no trailing punctuation?
- CODE-08 (SHOULD): Import Grouping
  - Check: Are imports organized into 3 groups: stdlib / external packages / internal packages, separated by blank lines?
- CODE-09 (SHOULD): Avoid Naked Returns in Long Functions
  - Check: Are naked returns (bare return statements with named return values) avoided in functions longer than ~10 lines?

### Concurrency (CON)

- CON-01 (SHOULD): Avoid goroutine Leaks
  - Check: Do goroutines terminate properly and monitor context.Done()?
- CON-02 (SHOULD): Clarify channel close Responsibility
  - Check: Is channel close responsibility on the sender side?
- CON-03 (SHOULD): Appropriate buffered/unbuffered channel Selection
  - Check: Is buffered/unbuffered selection appropriate with justified size?
- CON-04 (SHOULD): Appropriate sync primitives Usage
  - Check: Are sync.Mutex/RWMutex/WaitGroup/atomic used appropriately?
- CON-05 (SHOULD): for+goroutine Variable Capture Issue
  - Check: Are loop variables not directly referenced in goroutines?
- CON-06 (SHOULD): data race Detection and Prevention
  - Check: Is go test -race executed and shared memory protected with sync?

### Context Handling (CTX)

- CTX-01 (SHOULD): Accept context in public APIs
  - Check: Do public functions and methods accept context.Context as first argument?
- CTX-02 (SHOULD): Avoid context.Background()/TODO() Overuse
  - Check: Are there no excessive context.Background() uses or lingering context.TODO()?
- CTX-03 (SHOULD): Propagate context to goroutines
  - Check: Is context passed when launching goroutines?
- CTX-04 (SHOULD): Appropriate cancel Invocation
  - Check: Is cancel from WithCancel/WithTimeout called with defer?

### Dependencies (DEP)

- DEP-01 (SHOULD): Explicit Direct Dependencies
  - Check: Are direct dependencies explicitly in go.mod, versions pinned, and regularly updated?
- DEP-02 (SHOULD): Dependency Update Strategy
  - Check: Are regular go get -u, Renovate/Dependabot adoption, and update policies established?
- DEP-03 (SHOULD): vendor Management (Only When Necessary)
  - Check: Is vendor only when necessary, .gitignore configured, and module proxy utilized?
- DEP-04 (SHOULD): Prioritize Standard Library
  - Check: Is standard library prioritized, minimal dependency principle followed, and dependency reasons clarified?
- DEP-05 (SHOULD): AWS SDK Version Management
  - Check: Are AWS SDK v2 migration, latest version usage, and deprecated API replacement done?
- DEP-06 (SHOULD): Separate Development Dependencies
  - Check: Are //go:build tools used, development dependencies clarified, and production excluded?
- DEP-07 (SHOULD): License Compatibility
  - Check: Are go-licenses utilized, license lists generated, and compatibility verified?

### Documentation (DOC)

- DOC-01 (SHOULD): Package Documentation Exists
  - Check: Are package doc comments, package purpose, and usage documented?
- DOC-02 (SHOULD): godoc for Public Functions
  - Check: Are all public APIs documented with godoc, arguments, return values, and error conditions specified?
- DOC-03 (SHOULD): Complex Logic Comments
  - Check: Are Why-focused comments, algorithm explanations, and preconditions documented?
- DOC-04 (SHOULD): Struct Field Comments
  - Check: Are each field commented with constraints, default values, and required status?
- DOC-05 (SHOULD): Constant and Variable Descriptions
  - Check: Are constants/variables commented with units, constraints, and reasons?
- DOC-06 (SHOULD): English Comment Consistency
  - Check: Are comments unified in English, grammar-checked, and concise?
- DOC-07 (SHOULD): README.md Maintenance
  - Check: Are purpose, prerequisites, setup, usage examples, and contribution methods documented?
- DOC-08 (SHOULD): API Specification (OpenAPI)
  - Check: Are OpenAPI 3.0 descriptions, swag usage, and auto-generation verification present?
- DOC-09 (SHOULD): Operations Documentation
  - Check: Are deployment procedures, monitoring items, incident response procedures, and log analysis methods documented?
- DOC-10 (SHOULD): CHANGELOG
  - Check: Are Keep a Changelog format, semantic versioning, and breaking changes documented?

### Error Handling (ERR)

- ERR-01 (SHOULD): Appropriate Error Wrapping
  - Check: Are errors wrapped with fmt.Errorf("%w", err) and context information included?
- ERR-02 (SHOULD): Appropriate Custom Error Definition
  - Check: Are sentinel errors defined and custom errors compatible with errors.Is/As?
- ERR-03 (SHOULD): Avoid and Recover from Panics
  - Check: Are panics only for fatal errors and defer+recover implemented?
- ERR-04 (SHOULD): Appropriate Error Log Information
  - Check: Are error log levels unified, stack traces recorded, and sensitive information masked?
- ERR-05 (SHOULD): Error Propagation to Upper Layers
  - Check: Are errors not swallowed and error context preserved?
- ERR-06 (SHOULD): Error Handling Strategy
  - Check: Are error classifications defined, retry logic, and Fail Fast implemented?
- ERR-07 (SHOULD): External Dependency Error Handling
  - Check: Are timeouts set, retries implemented, and errors classified?
- ERR-08 (SHOULD): Validation Errors
  - Check: Are input validations, field-level errors, and user-friendly messages present?
- ERR-09 (SHOULD): Error Message Security
  - Check: Are there no internal implementation exposure, external stack trace disclosure, or SQL statement exposure?

### Function Design (FUNC)

- FUNC-01 (SHOULD): Appropriate Function Splitting
  - Check: Are there no multiple responsibilities or mixed business/infrastructure layers in single functions?
- FUNC-02 (SHOULD): Appropriate Argument Design
  - Check: Are there no excessive positional arguments or bool argument overuse, and are options handled appropriately?
- FUNC-03 (SHOULD): Return Value Design
  - Check: Are named returns minimized, error placed last, and multiple returns appropriate?
- FUNC-04 (SHOULD): Recommend Pure Functions
  - Check: Are there no global variable references, mixed side effects, or non-deterministic behavior?
- FUNC-05 (SHOULD): Appropriate Receiver Design
  - Check: Are there no mixed pointer/value receivers or large value receivers?
- FUNC-06 (SHOULD): Method Set Design
  - Check: Are there no unrelated methods mixed, God Object formation, or unclear responsibility scope?
- FUNC-07 (SHOULD): Appropriate Initialization Functions
  - Check: Do New functions implement error handling and validation?
- FUNC-08 (SHOULD): Leverage Higher-Order Functions
  - Check: Are callbacks and function pointers appropriately utilized?
- FUNC-09 (SHOULD): Appropriate Generics Usage
  - Check: Are there no interface{} overuse or unnecessary generics?
- FUNC-10 (SHOULD): Comprehensive Function Documentation
  - Check: Do all public functions have godoc with argument and return value descriptions?

### Global / Base (G)

- G-01 (SHOULD): No Hardcoded Secrets
  - Check: Are API keys, passwords, and tokens not embedded in source code?
- G-02 (SHOULD): Appropriate Function Signatures
  - Check: Are argument count (4+), return types, and bool return overuse appropriate?
- G-03 (SHOULD): Leverage Standard Library
  - Check: Are external dependencies avoided for features implementable with standard library?
- G-04 (SHOULD): Appropriate Log Levels
  - Check: Are Debug/Info/Warn/Error levels appropriate and structured logging used?
- G-05 (MUST): Declaration Order (File Level)
  - Check: Is order const→var→type (interface→struct)→func (constructor→methods→helpers)?
- G-06 (SHOULD): Declaration Order (Within Groups)
  - Check: Is each group sorted A→Z alphabetically (recommended)?
- G-07 (SHOULD): Restrict init() Complexity
  - Check: Does init() avoid panics, external I/O, and non-trivial side effects? Is it minimal and deterministic?
- G-08 (SHOULD): Zero Value Design
  - Check: Are types designed so their zero value is a valid and useful state where possible?
- G-09 (SHOULD): Defensive Copy at Boundaries
  - Check: Are slices and maps copied when accepting from or returning to external callers?

### Performance (PERF)

- PERF-01 (SHOULD): Memory Optimization
  - Check: Are slice capacity pre-allocated, map initial capacity specified, and sync.Pool utilized?
- PERF-02 (SHOULD): CPU Optimization
  - Check: Are there no O(n²) algorithms, unnecessary calculations, or duplicate processing in loops?
- PERF-03 (SHOULD): I/O Optimization
  - Check: Are bufio used, connection pools implemented, and buffer sizes appropriate?
- PERF-04 (SHOULD): Appropriate Data Structure Selection
  - Check: Are map/set utilized, appropriate indexes, and data structures optimized?
- PERF-05 (SHOULD): GC Consideration
  - Check: Are allocations reduced, value types utilized, and sync.Pool used?
- PERF-06 (SHOULD): String Processing Optimization
  - Check: Are strings.Builder used, bytes.Buffer utilized, and string concatenation minimized?
- PERF-07 (SHOULD): Parallel Processing Optimization
  - Check: Are worker pools implemented, GOMAXPROCS considered, and buffered channels used?
- PERF-08 (SHOULD): Caching Strategy
  - Check: Are caches implemented, TTL set, and LRU/LFU strategies present?
- PERF-09 (SHOULD): Leverage pprof
  - Check: Are regular pprof measurements and CPU/memory/goroutine profile analyses performed?
- PERF-10 (SHOULD): Hot Path Optimization
  - Check: Are critical paths identified, high-frequency processing optimized, and before/after measured?

### Security (SEC)

- SEC-01 (SHOULD): Input Validation
  - Check: Are input validation, prepared statements, and sanitization implemented?
- SEC-02 (SHOULD): Output Sanitization
  - Check: Are HTML escaping, JSON injection prevention, and CRLF injection prevention present?
- SEC-03 (SHOULD): Appropriate Encryption
  - Check: Are TLS 1.2+, AES-256-GCM, and crypto/rand used?
- SEC-04 (SHOULD): Authentication and Authorization Implementation
  - Check: Are all endpoints authenticated, JWT signature verified, and RBAC implemented?
- SEC-05 (SHOULD): Rate Limiting and DOS Prevention
  - Check: Are rate limiters, timeout settings, and request size limits present?
- SEC-06 (SHOULD): Log Security
  - Check: Are sensitive information masking functions and password/token masking present?
- SEC-07 (SHOULD): Secure Defaults
  - Check: Are least privilege principle, production debug disabled, and explicit CORS settings present?
- SEC-08 (SHOULD): OWASP Compliance
  - Check: Are OWASP Top 10 addressed, Security Headers set, and CSP configured?

### Testing (TEST)

- TEST-01 (SHOULD): Table-Driven Tests
  - Check: Are []struct format table-driven tests, subtests, and edge cases covered?
- TEST-02 (SHOULD): testify Usage and Test Design
  - Check: Are assert/require appropriately used, testable API designed, and time/rand injected?
- TEST-03 (SHOULD): Appropriate Mock Usage
  - Check: Are gomock/testify mock used, interfaces segregated, and dependency injection present?
- TEST-04 (SHOULD): Separate Test Helpers
  - Check: Are testing_test.go separated, common helper functions, and fixture management present?
- TEST-05 (SHOULD): Benchmark Tests
  - Check: Are Benchmark functions, benchstat comparisons, and CI integration present?
- TEST-06 (SHOULD): Separate Integration Tests
  - Check: Are build tags separated, // +build integration, and parallel execution configured?
- TEST-07 (SHOULD): Test Data Management
  - Check: Are testdata/ directory utilized, factory pattern, and Golden File Testing present?
- TEST-08 (SHOULD): Efficient Test Parallel Execution
  - Check: Are t.Parallel() used, -race -parallel specified, and parallel-safe implementation present?
- TEST-09 (SHOULD): Use t.Helper() in Test Helpers
  - Check: Do test helper functions call t.Helper() as their first statement?

### Code Modification Guidelines

- After changes, prioritize running validate.sh from [go-validation Skill](../../apm_modules/y-miyazaki/config/.apm/packages/go/.apm/skills/go-validation/SKILL.md).
- Use individual commands (gofumpt/go vet/go test/golangci-lint) only for debugging.

## Testing and Validation

Operational rules:

- Target at least 80% test coverage and verify with `go test -cover`.
- Separate integration tests from regular tests by using `//go:build integration`.

**Entry point (recommended)**:

```bash
bash <agent-root>/skills/go-validation/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
gofumpt -l ./...
go vet ./...
golangci-lint run ./...
go test -race -cover ./...
```

**Detailed guide**: See [go-validation Skill](../../apm_modules/y-miyazaki/config/.apm/packages/go/.apm/skills/go-validation/SKILL.md).

## Security Guidelines

- Do not hardcode secrets or credentials in source code, logs, or test data.
- Validate external inputs and use explicit error handling for privilege-boundary operations.
- Wrap error outputs to avoid sensitive data leakage and log only the minimum required information.
