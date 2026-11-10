# Issue triage label FSM

Allowlisted labels live in `scripts/labels.json` (color + description). Only catalog names may be created or applied.

## States (labels)

| Label                                            | Meaning                                                                          |
| ------------------------------------------------ | -------------------------------------------------------------------------------- |
| `needs-triage`                                   | Unclassified or low-confidence; needs human/agent attention                      |
| `triage:needs-info`                              | Waiting on author clarification                                                  |
| `triage:ready`                                   | Enough info; human may request autofix                                           |
| `triage:failed`                                  | Automated triage failed; detect skips until a human removes it                   |
| `bug` / `feature` / `question` / `documentation` | Type classification                                                              |
| `autofix`                                        | Human-triggered autofix intake label (catalogued; **not** applied by this skill) |

## Failed stop

When triage fails in a way that leaves the Issue in an unsafe or ambiguous state, apply allowlisted `triage:failed`. Detect skips the Issue while this label is present; a human must remove it before automation retries.

The Agent may apply `triage:failed` on unsafe partial failure. In a message run (the prompt names a message directory) it writes `triage:failed` into the `add` list of `message_labels.json` instead of calling `gh`; when the agent run itself fails, the platform does not apply the label. The Agent must **not** fire `repository_dispatch` or start github-issue-autofix intake; autofix remains a human-triggered follow-up via the `autofix` label.

## Choosing the event

The helper accepts only the four events in the transitions table below. Map Issue activity to them:

| Issue activity                                 | Event                                                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------ |
| Issue opened                                   | `opened`                                                                             |
| Issue reopened                                 | `opened`                                                                             |
| Human reply while `triage:needs-info` present  | Re-classify with the new facts, then `mark_ready` (enough info) or `mark_needs_info` |
| Classification complete with enough info       | `mark_ready`                                                                         |
| Facts missing                                  | `mark_needs_info`                                                                    |
| Human asks to re-triage a `triage:ready` Issue | `human_retriage`                                                                     |

Type labels are not produced by the helper; see SKILL.md Workflow step 5.

## Events → recommended transitions

Helpers: `scripts/label_fsm.sh` → `label_fsm_next_state <labels_json> <event>` → `{"add":[],"remove":[]}`.

| Event             | Add                        | Remove                              |
| ----------------- | -------------------------- | ----------------------------------- |
| `opened`          | `needs-triage` (if absent) | —                                   |
| `mark_needs_info` | `triage:needs-info`        | `triage:ready`                      |
| `mark_ready`      | `triage:ready`             | `triage:needs-info`, `needs-triage` |
| `human_retriage`  | `needs-triage`             | `triage:ready`                      |

Preserve unrelated type labels (`bug`, …) unless the agent intentionally replaces classification.
