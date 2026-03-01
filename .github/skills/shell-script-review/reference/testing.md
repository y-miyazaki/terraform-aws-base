### 7. Testing (TEST)

**TEST-01: Implement Unit Tests**

Check: Are unit tests implemented with Bats?
Why: Missing tests cause regressions, bug introduction, difficult CI/CD
Fix: Introduce Bats, create tests under test/bats/, automate

**TEST-02: Bats Test Functions in a-z Order**

Check: Are test functions placed in a-z order after setup/teardown?
Why: Inconsistent test function order makes test maintenance difficult, reduces review efficiency
Fix: Place test functions in a-z order after setup/teardown

**TEST-03: CI/CD Integration**

Check: Are tests integrated into CI/CD like GitHub Actions?
Why: No automated test execution causes production failures, quality degradation, deployment risks
Fix: Integrate with GitHub Actions, automated tests on PRs, quality gates
