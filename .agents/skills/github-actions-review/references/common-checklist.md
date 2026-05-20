# GitHub Actions Review Checklist

## Best Practices (BP)
- BP-01 (SHOULD): Reusable Workflow Design
- BP-02 (SHOULD): DRY Principle for Duplication Reduction
- BP-03 (SHOULD): Explicit Job Dependencies
- BP-04 (SHOULD): Simplify Conditional Branches
- BP-05 (SHOULD): Limit Environment Variable Scope

## Error Handling (ERR)
- ERR-01 (SHOULD): Careful Use of continue-on-error
- ERR-02 (SHOULD): Failure and Always Guards for Cleanup/Notify
- ERR-03 (SHOULD): Timeout Configuration
- ERR-04 (SHOULD): Retry Strategy for Flaky Integrations

## Global / Base (G)
- G-01 (SHOULD): Clear Workflow Naming
- G-02 (SHOULD): Limit Triggers (on)
- G-03 (SHOULD): Step Clarification and Order Guarantee
- G-04 (SHOULD): Explicit Environment and Approval Flow

## Performance (PERF)
- PERF-01 (SHOULD): Cache Strategy and Invalidation
- PERF-02 (SHOULD): Matrix/Parallel Execution Balance
- PERF-03 (SHOULD): Concurrency Control
- PERF-04 (SHOULD): Reduce Unnecessary Workload

## Security (SEC)
- SEC-01 (SHOULD): Explicit Top-Level Permissions
- SEC-02 (SHOULD): Safe Secret References
- SEC-03 (SHOULD): Careful Use of pull_request_target
- SEC-04 (SHOULD): Log Masking for Sensitive Information
- SEC-05 (SHOULD): Pin Third-Party Actions
- SEC-06 (SHOULD): Sanitize Environment Variables
- SEC-07 (SHOULD): Guardrails for Public Repositories

## Tool Integration (TOOL)
- TOOL-01 (SHOULD): Reviewdog Integration for PR Feedback
- TOOL-02 (SHOULD): Codecov Coverage Upload Strategy
- TOOL-03 (SHOULD): Artifact Retention Configuration
- TOOL-04 (SHOULD): Cache Key and Restore Strategy
