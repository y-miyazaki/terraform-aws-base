### 9. Testing (TEST)

**TEST-01: Table-Driven Tests**

Check: Are []struct format table-driven tests, subtests, and edge cases covered?
Why: Duplicate test cases and Go idiom violations cause test omissions, increased maintenance cost
Fix: []struct format table-driven, use subtests, cover edge cases

**TEST-02: testify Usage and Test Design**

Check: Are assert/require appropriately used, testable API designed, and time/rand injected?
Why: Excessive testify dependency, untestable APIs, and direct time/randomness usage increase external dependencies, unstable tests
Fix: Decide testify dependency project policy, consider testability, inject time.Now/rand interfaces

**TEST-03: Appropriate Mock Usage**

Check: Are gomock/testify mock used, interfaces segregated, and dependency injection present?
Why: Real calls to external dependencies cause unstable tests, long execution time, production impact
Fix: Use gomock/testify mock, segregate interfaces, dependency injection

**TEST-04: Separate Test Helpers**

Check: Are testing_test.go separated, common helper functions, and fixture management present?
Why: Duplicate test code and scattered setup/teardown make maintenance difficult, increase test addition cost
Fix: Separate testing_test.go, common helper functions, fixture management

**TEST-05: Benchmark Tests**

Check: Are Benchmark functions, benchstat comparisons, and CI integration present?
Why: Undetectable performance regressions and unclear optimization effects cause performance degradation
Fix: Benchmark functions in *_test.go, benchstat comparison, CI integration

**TEST-06: Separate Integration Tests**

Check: Are build tags separated, // +build integration, and parallel execution configured?
Why: Mixed unit/integration tests and long execution time delay CI/CD, feedback
Fix: Separate build tags, // +build integration, configure parallel execution

**TEST-07: Test Data Management**

Check: Are testdata/ directory utilized, factory pattern, and Golden File Testing present?
Why: Hardcoded test data and unmanaged fixtures cause test fragility, data inconsistency
Fix: Utilize testdata/ directory, factory pattern, Golden File Testing

**TEST-08: Efficient Test Parallel Execution**

Check: Are t.Parallel() used, -race -parallel specified, and parallel-safe implementation present?
Why: Unused t.Parallel() and long test execution time increase CI time, reduce development velocity
Fix: Add t.Parallel(), specify -race -parallel, parallel-safe implementation
