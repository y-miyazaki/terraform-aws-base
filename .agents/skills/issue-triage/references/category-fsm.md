# Issue triage label FSM

Allowlisted labels live in `scripts/labels.json` (color + description). Only catalog names may be created or applied.

## States (labels)

| Label | Meaning |
| --- | --- |
| `needs-triage` | Unclassified or low-confidence; needs human/agent attention |
| `triage:needs-info` | Waiting on author clarification |
| `triage:ready` | Enough info; human may request autofix |
| `triage:failed` | Automated triage failed; detect skips until a human removes it |
| `bug` / `feature` / `question` / `documentation` | Type classification |
| `autofix` | Human-triggered autofix intake label (catalogued; **not** applied by this skill) |

## Failed stop

When triage fails in a way that leaves the Issue in an unsafe or ambiguous state, apply allowlisted `triage:failed`. Detect skips the Issue while this label is present; a human must remove it before automation retries.

The Agent may apply `triage:failed` on unsafe partial failure. The Agent must **not** fire `repository_dispatch` or start issue-autofix intake; autofix remains a human-triggered follow-up via `autofix` or trusted platform hooks.

## Events → recommended transitions

Helpers: `scripts/label_fsm.sh` → `label_fsm_next_state <labels_json> <event>` → `{"add":[],"remove":[]}`.

| Event | Add | Remove |
| --- | --- | --- |
| `opened` | `needs-triage` (if absent) | — |
| `mark_needs_info` | `triage:needs-info` | `triage:ready` |
| `mark_ready` | `triage:ready` | `triage:needs-info`, `needs-triage` |
| `human_retriage` | `needs-triage` | `triage:ready` |

Preserve unrelated type labels (`bug`, …) unless the agent intentionally replaces classification.
