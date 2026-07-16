## Testing (TEST)

**TEST-00 (MUST): Add Tests With Script Changes**

Check: When adding or materially changing a shell script or sourced library, is a matching Bats suite added or updated in the same change?
Why: Production and test code diverge when tests are deferred; regressions reach CI or production (see [Google eng-practices: Keep related test code in the same CL](https://google.github.io/eng-practices/review/developer/small-cls.html#test_code))
Fix: Mirror the script path under test/bats/, follow companion Bats rules (stem `bats`), and run bats before submitting

**TEST-01 (MUST): Implement Unit Tests**

Check: Are unit tests implemented with Bats per companion Bats rules (stem `bats`)?
Why: Missing tests cause regressions, bug introduction, difficult CI/CD
Fix: Introduce Bats, create tests under test/bats/, automate

**TEST-02 (SHOULD): Bats Test Functions in a-z Order**

Check: Are test functions placed in a-z order after setup/teardown?
Why: Inconsistent test function order makes test maintenance difficult, reduces review efficiency
Fix: Place test functions in a-z order after setup/teardown

**TEST-03 (SHOULD): CI/CD Integration**

Check: Are tests integrated into CI/CD like GitHub Actions?
Why: No automated test execution causes production failures, quality degradation, deployment risks
Fix: Integrate with GitHub Actions, automated tests on PRs, quality gates
