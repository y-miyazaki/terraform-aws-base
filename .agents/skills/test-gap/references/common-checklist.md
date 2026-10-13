# Checklist

## Evidence (EVID)

- EVID-01: Cite the production file and the behavior each new test asserts.
- EVID-02: When the target's paired test file path appears in `ledger.processed[]`, state the new reason for selecting it again (an Open Rejections item from a previous run counts as one).

## Test quality (TEST)

- TEST-01: Every test asserts an observable result (return value, side effect, error path). No test may pass regardless of the implementation.
- TEST-02: Do not assert only on mocks. Mock external boundaries; assert on the unit's own behavior.
- TEST-03: Follow the nearest existing test file's layout, helpers, and naming.
- TEST-04: Tests are deterministic: no time-of-day, no randomness without a fixed seed, no network.

## Edit boundary (EDIT)

- EDIT-01: Touch only `Allowed paths`.
- EDIT-02: Never modify production code. A suspected production bug goes in the PR body under `### Deferred`.
- EDIT-03: Never delete, skip, comment out, or loosen an existing test or assertion.

## Honesty (HON)

- HON-01: You cannot run tests here. Never write that tests passed. Write the command CI will run and the expected result.
