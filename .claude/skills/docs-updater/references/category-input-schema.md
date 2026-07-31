# Exit Codes

| Exit code | Meaning                                                                                                                                  |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 0         | Success — stdout is detect script JSON. Parse per **Detect script stdout** below and continue the workflow.                              |
| 1         | Fatal — stdout is detect script error JSON. Read stdout for the message, then **stop**. Do not treat stdout as success-path detect JSON. |

Detect scripts require `jq`. When `jq` is unavailable at fatal-error emission, stdout may be only `{status, skip, message}` instead of the full error field set.

## Detect script stdout (exit 0 only)

Field set emitted by this skill's detect script or an equivalent caller-supplied JSON object.

```json
{
  "status": "ok",
  "scope": "staged",
  "since": "",
  "commit_range": "abc1234..def5678",
  "skip": false,
  "changed_files": ["src/module.go"],
  "deleted_files": [],
  "renamed_files": [],
  "affected_docs": ["docs/guide/overview.md"]
}
```

| Field           | Type    | Description                                            |
| --------------- | ------- | ------------------------------------------------------ |
| `status`        | string  | `ok` on success path                                   |
| `scope`         | string  | Detect scope (`staged`, `all`, or `range`)             |
| `since`         | string  | Range start ref when `scope` is `range` (may be empty) |
| `commit_range`  | string  | Active revision range label                            |
| `skip`          | boolean | When true, no documentation impact detected            |
| `changed_files` | array   | Repository-relative changed paths (may be empty)       |
| `deleted_files` | array   | Deleted paths (may be empty)                           |
| `renamed_files` | array   | Rename pairs `old=>new` (may be empty)                 |
| `affected_docs` | array   | Candidate documentation paths to triage (may be empty) |

Edit permission and path scope are **not** JSON fields. Read them from `## Constraints` per [category-automation-envelope.md](category-automation-envelope.md) and [category-scope.md](category-scope.md).
