# Checklist

## Evidence (EVID)

- EVID-01: Cite the production file and the behavior each new test asserts.
- EVID-02: When the target's paired test file path appears in `ledger.processed[]`, state the new reason for selecting it again (a target listed in an optional caller-supplied `## Open Rejections` prompt section counts as one).

## Test quality (TEST)

- TEST-01: Every test asserts an observable result (return value, side effect, error path). No test may pass regardless of the implementation.
- TEST-02: Do not assert only on mocks. Mock external boundaries; assert on the unit's own behavior.
- TEST-03: Follow the nearest existing test file's layout, helpers, and naming.
- TEST-04: Tests are deterministic: no time-of-day, no randomness without a fixed seed, no network.

## Edit boundary (EDIT)

- EDIT-01: Touch only `Allowed paths`.
- EDIT-02: Never modify production code. Report a suspected production bug under `### Deferred` (apply) or in Overview (survey).
- EDIT-03: Never delete, skip, comment out, or loosen an existing test or assertion.

## Honesty (HON)

- HON-01: Run the repository's existing test command when available and report the actual result. When you cannot run it (no tooling, or the caller says tests are not run here), write the command and the expected result and mark it not run. Never write that tests passed without running them.
