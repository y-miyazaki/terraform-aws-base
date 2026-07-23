## Input Schema

Provided via prompt context by the calling workflow (loop-prompt-generate action).

```json
{
  "commit_range": "abc1234..def5678",
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

| Field                      | Type    | Description                                       |
| -------------------------- | ------- | ------------------------------------------------- |
| `commit_range`             | string  | SHA range that triggered detection                |
| `skip`                     | boolean | When true, no documentation impact detected       |
| `findings`                 | array   | Detected documentation drift items (may be empty) |
| `findings[].file`          | string  | Path to affected documentation file               |
| `findings[].reason`        | string  | Why the file is stale or needs update             |
| `findings[].source_commit` | string  | Commit that caused the drift                      |

`findings` may be an empty array.

Edit permission is **not** a JSON field. Read `may_edit` from `## Constraints` per [category-automation-envelope.md](category-automation-envelope.md).

Path allowlist is not a JSON field. When present, it arrives in `## Constraints` — see [category-scope.md](category-scope.md).

### Detect → findings pipeline

1. **`detect_changes.sh`** emits mechanical facts: `changed_files`, `deleted_files`, `renamed_files`, `affected_docs`, `commit_range`, `skip`. It does not build semantic `findings[]`.
2. **`loop-prompt-generate`** (caller) maps detect facts into `findings[]` with `file`, `reason`, and `source_commit` before invoking this skill.
3. **This skill** classifies each `findings[]` entry, fixes High-Priority items when `may_edit` is `true`, and emits the triage report.
