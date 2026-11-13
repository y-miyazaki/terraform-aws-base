# Testing (TEST)

**TEST-01 (SHOULD): Module changes come with tests that assert behavior**

Check: Does a change to a module add or update tests next to it (for example `terraform test` files), and do the assertions check content (keys, actions, conditions, values, defaults and overrides) rather than only counts of resources or statements?
Why: Count-only assertions pass when the wrong thing is created, and untested modules make refactors (such as `count` to `for_each`) unsafe
Fix: Add `*.tftest.hcl` cases for the enabled, disabled and override paths; assert on the attributes that matter. When no test framework is feasible, state what was verified instead and what was not
