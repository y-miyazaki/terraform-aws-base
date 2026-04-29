# GitHub Actions Review Checklist

## Global

- G-01: Clear workflow naming
- G-02: Trigger scope is limited
- G-03: Steps are named and ordered
- G-04: Environment and approval flow are explicit

## Error Handling

- ERR-01: `continue-on-error` usage is justified
- ERR-02: Failure post-processing is prepared
- ERR-03: Failure notifications are configured for critical jobs
- ERR-04: `timeout-minutes` is set

## Tool Integration

- TOOL-01: PR diff lint integration is configured when needed
- TOOL-02: Reviewdog reporter is configured when Reviewdog is used
- TOOL-03: Coverage token handling uses secrets and minimal permissions
- TOOL-04: Artifact naming excludes sensitive data
- TOOL-05: Artifact retention policy is defined
- TOOL-06: Cache key design includes stable hash and `restore-keys`

## Security

- SEC-01: Top-level permissions are explicit and minimal
- SEC-02: Secret references use `${{ secrets.NAME }}` and are not logged
- SEC-03: `pull_request_target` includes guardrails
- SEC-04: Sensitive values are masked in logs
- SEC-05: Third-party actions are pinned to SHA for critical paths
- SEC-06: Environment variable inputs are sanitized
- SEC-07: Public repository guardrails are implemented

## Performance

- PERF-01: Matrix parallelization is used for multi-environment testing
- PERF-02: Dependency caching is configured
- PERF-03: Redundant steps are removed
- PERF-04: `concurrency` cancels stale runs

## Best Practices

- BP-01: Reusable workflows or composite actions are used where practical
- BP-02: Duplication is reduced (DRY)
- BP-03: Job dependencies are explicit with `needs`
- BP-04: Conditional expressions are readable and maintainable
- BP-05: Environment variable scope is minimal
