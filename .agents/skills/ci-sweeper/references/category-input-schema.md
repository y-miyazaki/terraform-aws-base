# Exit Codes and Error Envelope

| Exit code | Meaning                                                                      |
| --------- | ---------------------------------------------------------------------------- |
| 0         | Success — stdout is detect script JSON. Parse per schema below and continue. |
| 1         | Fatal — stdout is detect script error JSON. Read stdout, then **stop**.      |

Detect scripts list `jq` as a required dependency. When `jq` is unavailable at fatal-error emission, stdout may be only `{status, skip, message}` (bootstrap JSON) instead of the full skill-specific field set below.

## Detect script stdout (exit 0 only)

Field set emitted by this skill's detect script or an equivalent caller-supplied JSON object.

```json
{
  "status": "ok",
  "scope": "range",
  "since": "abc1234",
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
      "reason": "CI failure in job lint (regression)",
      "workflow_path": "<workflow file path>",
      "job_url": "https://github.com/org/repo/actions/runs/123456789/job/987654",
      "job_id": "987654"
    }
  ]
}
```

| Field                        | Type    | Description                                                                                                                     |
| ---------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `status`                     | string  | `ok` on success path                                                                                                            |
| `scope`                      | string  | Detect scope (for example `range`)                                                                                              |
| `since`                      | string  | Last processed SHA from caller state cursor (when supplied)                                                                     |
| `skip`                       | boolean | When true, no actionable work (detect script found no failures)                                                                 |
| `failures`                   | array   | Actionable CI failures to assess (may be empty)                                                                                 |
| `ignored`                    | array   | Skipped runs (ledger, filters, non-actionable types); note in Overview when non-empty — no dedicated section                    |
| `failures[].workflow_name`   | string  | Failed workflow display name                                                                                                    |
| `failures[].workflow_run_id` | string  | GitHub Actions run ID                                                                                                           |
| `failures[].head_sha`        | string  | Commit SHA that failed                                                                                                          |
| `failures[].head_branch`     | string  | Branch name                                                                                                                     |
| `failures[].job_name`        | string  | Failed job name                                                                                                                 |
| `failures[].failure_type`    | enum    | `regression`, `flake`, `infra`, or `env` (optional hint from detect script; Skill reclassifies)                                 |
| `failures[].log_excerpt`     | string  | Truncated failed log lines                                                                                                      |
| `failures[].run_url`         | string  | Link to the workflow run                                                                                                        |
| `failures[].source_commit`   | string  | Commit SHA for the failure (same as `head_sha` from detect script)                                                              |
| `failures[].reason`          | string  | Human-readable failure summary                                                                                                  |
| `failures[].workflow_path`   | string  | Optional repository path of the workflow file (omitted when unknown)                                                            |
| `failures[].job_url`         | string  | Optional URL of the failed job (detect derives `{run_url}/job/{job_id}` when the API gives none; omitted when neither is known) |
| `failures[].job_id`          | string  | Optional numeric ID of the failed job (omitted when unknown)                                                                    |

`failures` may be an empty array.

Path allowlist is not a JSON field. When present, `agent_edit_allowed` and allowed paths arrive in `## Constraints` — see [category-automation-envelope.md](category-automation-envelope.md).
