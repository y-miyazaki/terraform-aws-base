# GitHub Actions Review Checklist

## Best Practices (BP)

- BP-01 (SHOULD): Extract shared pipelines to reusable workflows/composites
- BP-02 (SHOULD): Declare job dependencies with needs
- BP-03 (SHOULD): Keep secrets at minimal env scope
- BP-04 (SHOULD): Explicit with: for security/cache/core action inputs

## Error Handling (ERR)

- ERR-01 (SHOULD): Limit continue-on-error to non-critical justified steps
- ERR-02 (SHOULD): Use if: failure()/always() for cleanup/notify uploads
- ERR-03 (SHOULD): Set timeout-minutes on jobs or long steps

## Global / Base (G)

- G-01 (SHOULD): Narrow on triggers by branch/path/event
- G-02 (SHOULD): Production jobs use environment + approval

## Ordering (ORD)

- ORD-01 (MUST): Alphabetize keys in env/permissions/with/secrets blocks

## Performance (PERF)

- PERF-01 (SHOULD): Deterministic cache keys invalidated by dependency changes
- PERF-02 (SHOULD): Balance matrix/parallelism vs runner cost
- PERF-03 (SHOULD): Cancel redundant runs with concurrency (caller-owned for reusable)

## Security (SEC)

- SEC-01 (SHOULD): Reference secrets only via secrets.\*; never echo them
- SEC-02 (SHOULD): Restrict pull_request_target on fork PRs
- SEC-03 (SHOULD): Mask sensitive values in logs (::add-mask / setSecret)
- SEC-04 (SHOULD): Validate/sanitize env inputs before use
- SEC-05 (SHOULD): Public repos gate privileged steps on private/trusted context

## Tool Integration (TOOL)

- TOOL-01 (SHOULD): Wire reviewdog for PR inline lint feedback when applicable
- TOOL-02 (SHOULD): Upload coverage to Codecov with a clear fail policy
- TOOL-03 (SHOULD): Set artifact retention intentionally (not default forever)

## Anti-Patterns (AP)

- AP-01 (MUST): Echoing or logging secrets
- AP-02 (MUST): pull_request_target on untrusted fork PRs without guards
- AP-03 (SHOULD): Floating third-party action tags
- AP-04 (SHOULD): Overly broad workflow permissions
- AP-05 (SHOULD): Passing untrusted PR input directly to shell
