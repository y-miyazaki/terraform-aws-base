## Testing (TEST)

**TEST-00 (MUST): Add/update paired Bats suite in the same change**

Check: When adding or materially changing a shell script or sourced library, is a matching Bats suite added or updated in the same change?
Why: Production and test code diverge when tests are deferred; regressions reach CI or production (see [Google eng-practices: Keep related test code in the same CL](https://google.github.io/eng-practices/review/developer/small-cls.html#test_code))
Fix: Add or update the paired Bats suite per companion Bats rules (stem `bats`) and the repository's layout; run `bats` on the changed suite before submitting

**TEST-01 (SHOULD): Bats test functions ordered a-z after setup/teardown**

Check: Are test functions placed in a-z order after setup/teardown?
Why: Inconsistent test function order makes test maintenance difficult, reduces review efficiency
Fix: Place test functions in a-z order after setup/teardown
