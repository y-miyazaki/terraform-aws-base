## Input Schema

Interactive runs may pass free-form path/symbol in the user prompt. When structured JSON is present (interactive helper or automation envelope), parse:

```json
{
  "target": "path/or/symbol",
  "mode": "survey",
  "hint": {
    "kind": "duplication_block",
    "path": "scripts/example.sh",
    "detail": "optional locator"
  },
  "allowlist": [".apm/packages/**", "scripts/**"],
  "denylist": ["docs/report/**"],
  "intent": "structural",
  "approved_slice": "optional — one slice from Phase A proposal for architecture Phase B",
  "constraints": {
    "max_tier": "O2"
  }
}
```

| Field                  | Type                           | Description                                                                                                                                         |
| ---------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `target`               | string                         | Optional scope anchor; when set, survey within that path/symbol                                                                                     |
| `mode`                 | `survey` \| `apply`            | Interactive only: `survey` → `may_edit: false`; `apply` → `may_edit: true`. Default `survey` when omitted                                           |
| `hint`                 | object                         | Optional structure hint (future detect H1 shapes)                                                                                                   |
| `hint.kind`            | string                         | `duplication_block` or `oversized_unit` only                                                                                                        |
| `hint.path`            | string                         | Path associated with the hint                                                                                                                       |
| `hint.detail`          | string                         | Optional locator (range, symbol name)                                                                                                               |
| `allowlist`            | string[]                       | Optional path globs; when set, restrict edits to matching paths. When absent, no allowlist restriction — see [category-scope.md](category-scope.md) |
| `denylist`             | string[]                       | Optional path globs; when set, do not edit matching paths. When absent, no skill denylist — see [category-scope.md](category-scope.md)              |
| `intent`               | `structural` \| `architecture` | Agent-classified from user language; default `structural`                                                                                           |
| `approved_slice`       | string                         | One slice from Phase A proposal; required for architecture Phase B apply                                                                            |
| `constraints.max_tier` | `O1` \| `O2`                   | Loop/tool depth cap only (`O1` local, `O2` same-package). Not the interactive O3 entry. Default `O2`.                                               |

### Interactive mode triggers

| User language (examples)                                     | Resolved `may_edit` |
| ------------------------------------------------------------ | ------------------- |
| 洗い出し, 候補, survey, inventory, list (default when vague) | `false`             |
| リファクタ, refactor, 実施, fix, apply, 適用して             | `true`              |

### Rules

- When structured JSON includes `mode`, resolve `may_edit` from `mode` before natural-language triggers
- If neither actionable scope nor `hints[]` nor exploratory target → no-op after survey
- `hint.kind` values outside the closed set → ignore hint; fall back to `target` or scope exploration
- Classify `intent` from user natural language ([category-operations.md](category-operations.md)); do not require users to pass `max_tier: O3`
- Architecture intent without `approved_slice` → Phase A proposal only; Outcome `proposal`
- Architecture Phase B requires `approved_slice` and runs survey + apply for that slice only (O2 cap)
- Automation envelope: `intent` is always `structural`; `constraints.max_tier` is `O1` or `O2` only
- Do **not** accept tech-debt report file paths as required input fields in v1
- Stack skill names are **not** schema fields — they arrive under `## Instructions` (A')

## Automation envelope (caller JSON)

When `hints[]` is present (from `loop-prompt-generate` / `detect_refactor.sh`):

```json
{
  "commit_range": "abc1234..def5678",
  "level": "L2",
  "skip": false,
  "hints": [
    {
      "kind": "duplication_block",
      "path": "scripts/example.sh",
      "detail": "lines 10-17 duplicate scripts/other.sh:40-47",
      "lines": 8
    }
  ]
}
```

| Field            | Type    | Description                                                                                                                               |
| ---------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `commit_range`   | string  | SHA range when detect scope is `range`                                                                                                    |
| `level`          | enum    | Caller metadata only — map to `may_edit` via [category-automation-envelope.md](category-automation-envelope.md); do not branch on `level` |
| `skip`           | boolean | When true, no actionable hints                                                                                                            |
| `hints`          | array   | Mechanical H1 hints from detect — survey **all** entries                                                                                  |
| `hints[].kind`   | enum    | `duplication_block` or `oversized_unit` only                                                                                              |
| `hints[].path`   | string  | Primary file path for the hint                                                                                                            |
| `hints[].detail` | string  | Locator (line range, peer path, line count)                                                                                               |
| `hints[].lines`  | number  | Optional size metric                                                                                                                      |

`may_edit` is not a JSON field. It arrives in `## Constraints` — see [category-automation-envelope.md](category-automation-envelope.md).

### Automation rules

- Survey **every** `hints[]` entry; apply every candidate marked apply within allowlist when `may_edit` is `true`
- Force `intent: structural`; `constraints.max_tier: O2`
- Allowlist/denylist: caller `allowlist` / `denylist` inputs (`LOOP_ALLOWLIST` / `LOOP_DENYLIST`). Allowlist is repeated in prompt `## Constraints`; denylist is enforced by loop-execute verifier — see [category-scope.md](category-scope.md).
- Session report per [common-output-format-loop.md](common-output-format-loop.md).
