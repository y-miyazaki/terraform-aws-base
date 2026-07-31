# Exit Codes and Error Envelope

| Exit code | Meaning                                                                                                                       |
| --------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 0         | Success — parse stdout JSON per schema below                                                                                  |
| 1         | Fatal error — parse stdout JSON with `status: "error"`, `message`, and `skip: true`; do not treat as success-path detect JSON |

Missing dependencies emit the same error envelope via `emit_error_json` before exit 1.

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
  "allowlist": ["src/**"],
  "denylist": [],
  "intent": "structural",
  "approved_slice": "optional — one slice from Phase A proposal for architecture Phase B",
  "constraints": {
    "max_tier": "O2"
  }
}
```

| Field                  | Type                           | Description                                                                                                                             |
| ---------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| `target`               | string                         | Optional scope anchor; when set, survey within that path/symbol                                                                         |
| `mode`                 | `survey` \| `apply`            | Interactive only: `survey` → `may_edit: false`; `apply` → `may_edit: true`. Default `survey` when omitted                               |
| `hint`                 | object                         | Optional structure hint                                                                                                                 |
| `hint.kind`            | string                         | `duplication_block` or `oversized_unit` only                                                                                            |
| `hint.path`            | string                         | Path associated with the hint                                                                                                           |
| `hint.detail`          | string                         | Optional locator (range, symbol name)                                                                                                   |
| `allowlist`            | string[]                       | Optional path globs; when set, restrict edits to matching paths. When absent, no allowlist — see [category-scope.md](category-scope.md) |
| `denylist`             | string[]                       | Optional path globs; when set, do not edit matching paths. When absent, no skill denylist — see [category-scope.md](category-scope.md)  |
| `intent`               | `structural` \| `architecture` | Agent-classified from user language; default `structural`                                                                               |
| `approved_slice`       | string                         | One slice from Phase A proposal; required for architecture Phase B apply                                                                |
| `constraints.max_tier` | `O1` \| `O2`                   | Depth cap for apply (`O1` local, `O2` same-package). Default `O2`. Architecture intent uses contract Phase A/B — not this field.        |

Natural-language `may_edit` triggers: SKILL.md Workflow table (not duplicated here). Structured `mode` wins over natural-language when both are present.

### Rules

- When structured JSON includes `mode`, resolve `may_edit` from `mode` before natural-language triggers
- Bare skill name `refactor` or bare `fix` alone do **not** set `may_edit: true` — require explicit apply language or `mode: apply`
- If neither actionable scope nor `hints[]` nor exploratory target → no-op after survey
- `hint.kind` values outside the closed set → ignore hint; fall back to `target` or scope exploration
- Classify `intent` from user natural language ([category-contract.md](category-contract.md))
- Architecture without / with `approved_slice`: follow [category-contract.md](category-contract.md) O3
- Automation envelope: `intent` is always `structural`; `constraints.max_tier` is `O1` or `O2` only

## Automation envelope (caller JSON)

When `hints[]` is present (from caller-supplied detect JSON or an optional skill detect script):

```json
{
  "commit_range": "abc1234..def5678",
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

| Field            | Type    | Description                                           |
| ---------------- | ------- | ----------------------------------------------------- |
| `commit_range`   | string  | SHA range when detect scope is `range`                |
| `skip`           | boolean | When true, no actionable hints                        |
| `hints`          | array   | Mechanical hints from detect — survey **all** entries |
| `hints[].kind`   | enum    | `duplication_block` or `oversized_unit` only          |
| `hints[].path`   | string  | Primary file path for the hint                        |
| `hints[].detail` | string  | Locator (line range, peer path, line count)           |
| `hints[].lines`  | number  | Optional size metric                                  |

`may_edit` is not a JSON field. It arrives in `## Constraints` — see [category-automation-envelope.md](category-automation-envelope.md).

### Automation rules

- Survey **every** `hints[]` entry; apply every candidate marked apply within allowlist when `may_edit` is `true` and `write_target` is `fix`
- Force `intent: structural`; `constraints.max_tier: O2`
- Allowlist/denylist from caller configuration — see [category-scope.md](category-scope.md)
- Session report per [common-output-format-automation.md](common-output-format-automation.md)
