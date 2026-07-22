## Input Schema

Provided via prompt context by the calling workflow (loop-prompt-generate action).

```json
{
  "commit_range": "abc1234..def5678",
  "level": "L2",
  "skip": false,
  "findings": [
    {
      "file": "docs/guide/overview.md",
      "reason": "references deleted workflow ci-build.yaml",
      "source_commit": "def5678"
    }
  ]
}
```

| Field                      | Type    | Description                                                                     |
| -------------------------- | ------- | ------------------------------------------------------------------------------- |
| `commit_range`             | string  | SHA range that triggered detection                                              |
| `level`                    | enum    | Operating level: `L1` (report only), `L2` (edit + PR), `L3` (edit + auto-merge) |
| `skip`                     | boolean | When true, no documentation impact detected                                     |
| `findings`                 | array   | Detected documentation drift items (may be empty)                               |
| `findings[].file`          | string  | Path to affected documentation file                                             |
| `findings[].reason`        | string  | Why the file is stale or needs update                                           |
| `findings[].source_commit` | string  | Commit that caused the drift                                                    |

`findings` may be an empty array. `level` defaults to `L2` when omitted by the workflow.

### Detect → findings pipeline

1. **`detect_changes.sh`** emits mechanical facts: `changed_files`, `deleted_files`, `renamed_files`, `affected_docs`, `commit_range`, `skip`. It does not build semantic `findings[]`.
2. **`loop-prompt-generate`** (caller) maps detect facts into `findings[]` with `file`, `reason`, and `source_commit` before invoking this skill.
3. **This skill** classifies each `findings[]` entry, fixes High-Priority items at `L2`/`L3`, and emits the triage report.

### Operating levels

| Level | Agent behavior for docs-updater (loop path)               |
| ----- | --------------------------------------------------------- |
| `L1`  | Emit triage report only — do not edit documentation files |
| `L2`  | Emit report and fix High-Priority items within allowlist  |
| `L3`  | Same edits as `L2`; caller may auto-merge the docs PR     |

Path allowlist is repeated in the implementer prompt `## Constraints` section from the caller (`LOOP_ALLOWLIST`). Denylist is a caller `denylist` input enforced by loop-execute verifier. When `LOOP_ALLOWLIST` is absent, no allowlist restriction within skill-specific limits — see [category-scope.md](category-scope.md).


