## Input Schema

Provided via prompt context by the calling workflow (loop-prompt-generate action) or interactive detect script.

```json
{
  "since": "abc1234",
  "scope": "range",
  "level": "L2",
  "skip": false,
  "failures": [
    {
      "workflow_name": "ci-markdown",
      "workflow_run_id": "123456789",
      "head_sha": "def5678",
      "head_branch": "main",
      "job_name": "lint",
      "failure_type": "regression",
      "log_excerpt": "...",
      "run_url": "https://github.com/org/repo/actions/runs/123456789",
      "source_commit": "def5678",
      "reason": "CI failure in job lint (regression)"
    }
  ]
}
```

| Field                        | Type    | Description                                                                                          |
| ---------------------------- | ------- | ---------------------------------------------------------------------------------------------------- |
| `since`                      | string  | Last processed SHA from loop state                                                                   |
| `scope`                      | string  | Detect scope (`range` from loop-detect)                                                              |
| `level`                      | enum    | Caller metadata only (`L1`, `L2`, `L3`) — do not branch on this field; see `may_edit` in Constraints |
| `skip`                       | boolean | When true, no actionable work (detect script found no failures)                                      |
| `failures`                   | array   | Actionable CI failures to assess (may be empty)                                                      |
| `ignored`                    | array   | Skipped runs (ledger, filters, non-actionable types) for SKILL Ignored section                       |
| `failures[].workflow_name`   | string  | Failed workflow display name                                                                         |
| `failures[].workflow_run_id` | string  | GitHub Actions run ID                                                                                |
| `failures[].head_sha`        | string  | Commit SHA that failed                                                                               |
| `failures[].head_branch`     | string  | Branch name                                                                                          |
| `failures[].job_name`        | string  | Failed job name                                                                                      |
| `failures[].failure_type`    | enum    | `regression`, `flake`, `infra`, or `env` (optional hint from detect script; Skill reclassifies)      |
| `failures[].log_excerpt`     | string  | Truncated failed log lines                                                                           |
| `failures[].run_url`         | string  | Link to the workflow run                                                                             |
| `failures[].source_commit`   | string  | Commit SHA for the failure (same as `head_sha` from detect script)                                   |
| `failures[].reason`          | string  | Human-readable failure summary                                                                       |

`failures` may be an empty array.

Path allowlist is not a JSON field. When present, `may_edit` and allowed paths arrive in `## Constraints` — see [category-automation-envelope.md](category-automation-envelope.md).
