## Exit Codes and Error Envelope

| Exit code | Meaning                                                                      |
| --------- | ---------------------------------------------------------------------------- |
| 0         | Success — stdout is detect script JSON. Parse per schema below and continue. |
| 1         | Fatal — stdout is detect script error JSON. Read stdout, then **stop**.      |

Detect scripts list `jq` as a required dependency. When `jq` is unavailable at fatal-error emission, stdout may be only `{status, skip, message}` (bootstrap JSON) instead of the full skill-specific field set below.

## Detect script stdout (exit 0 only)

Field set emitted by this skill's detect script or an equivalent caller-supplied JSON object. Detect scans the **full repository** by default (`scope=all`); `scope` and `since` are detect CLI parity fields and do not narrow sensors.

```json
{
  "commit_range": "abc1234..def5678",
  "report_file": "reports/tech-debt/2026-07-19.md",
  "previous_report": "reports/tech-debt/2026-07-12.md",
  "skip": false,
  "warnings": ["docs link sensor skipped: node not available"],
  "signals": [
    {
      "kind": "todo_comment",
      "path": "src/service.go",
      "line": 42,
      "snippet": "TODO: extract shared validator",
      "source": "git_grep",
      "hint": "code_quality"
    }
  ],
  "hotspots": [
    {
      "path": "scripts/deploy.sh",
      "metric": "churn",
      "value": 18,
      "window": "90d"
    }
  ]
}
```

| Field               | Type    | Description                                                                                                                                                                                                                 |
| ------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `commit_range`      | string  | SHA range that triggered detection (may be empty)                                                                                                                                                                           |
| `report_file`       | string  | Repository-relative path for the persisted report. Detect resolves a dated basename under `TECH_DEBT_DIR` when unset. Callers override via `TECH_DEBT_DIR` (detect) and/or `report_file` in detect JSON / `## Constraints`. |
| `previous_report`   | string  | Optional path to the prior dated report (empty when none). Search roots default to `TECH_DEBT_LEGACY_SEARCH_DIRS` (same default as `TECH_DEBT_DIR`).                                                                        |
| `skip`              | boolean | When true, no debt signals or hotspots detected                                                                                                                                                                             |
| `warnings`          | array   | Optional strings from detect (per-sensor recoverable failures, truncation, skipped sensors); caller may pass through                                                                                                        |
| `signals`           | array   | Mechanical debt facts from detect (may be empty)                                                                                                                                                                            |
| `signals[].kind`    | enum    | Closed set — see table below                                                                                                                                                                                                |
| `signals[].path`    | string  | File path containing the signal                                                                                                                                                                                             |
| `signals[].line`    | number  | 1-based line number                                                                                                                                                                                                         |
| `signals[].snippet` | string  | Short evidence text from the source line                                                                                                                                                                                    |
| `signals[].source`  | string  | Detection method (`git_grep`, `go_mod`, `package_json`, `markdown_link_check`, `git_log`, `mtime`)                                                                                                                          |
| `signals[].hint`    | string  | Optional detect hint toward a taxonomy category (agent still decides)                                                                                                                                                       |
| `hotspots`          | array   | Aggregate churn candidates (may be empty)                                                                                                                                                                                   |
| `hotspots[].path`   | string  | File path                                                                                                                                                                                                                   |
| `hotspots[].metric` | string  | Metric name (`churn`)                                                                                                                                                                                                       |
| `hotspots[].value`  | number  | Metric value                                                                                                                                                                                                                |
| `hotspots[].window` | string  | Observation window (e.g. `90d`)                                                                                                                                                                                             |

### Closed `signals[].kind` set

Detect emits only these kinds. Unexpected kinds → classify as Watch or Noise.

| Kind             | Sensor role | Typical `source`      |
| ---------------- | ----------- | --------------------- |
| `todo_comment`   | Secondary   | `git_grep`            |
| `fixme`          | Secondary   | `git_grep`            |
| `hack`           | Secondary   | `git_grep`            |
| `xxx`            | Secondary   | `git_grep`            |
| `pin_drift`      | Core        | `package_json`        |
| `version_range`  | Core        | `package_json`        |
| `eol_hint`       | Core        | `go_mod`              |
| `broken_doc_ref` | Core        | `markdown_link_check` |
| `stale_doc`      | Core        | `git_log` or `mtime`  |

**Marker kinds** (`todo_comment`, `fixme`, `hack`, `xxx`) are secondary enrichment — default toward Watch unless systemic. Core sensors cover dependency manifests, docs links/staleness, and churn hotspots.

`signals` and `hotspots` may be empty arrays.

`may_edit` is not a JSON field. On the automation path it arrives in `## Constraints` — see [category-automation-envelope.md](category-automation-envelope.md). Path allowlist is also injected in `## Constraints` from the caller. See [category-scope.md](category-scope.md).
