# Detect JSON schema

The skill detect script (`scripts/detect_issue.sh`) emits one JSON object:

```json
{
  "status": "ok",
  "skip": false,
  "result": {
    "handoff_key": "entity:issue:12",
    "entity": { "kind": "issue" },
    "issue_number": 12,
    "title": "<title>",
    "body": "<body>",
    "labels": ["bug"],
    "event_name": "issues",
    "event_action": "opened",
    "comment_id": null,
    "actor": "<login>",
    "actor_type": "User",
    "gate": { "entity": { "kind": "issue", "number": 12, "state": "open" } }
  },
  "verifier_context": "Issue #12: <title>"
}
```

- `skip: true` means the detect step already decided not to triage (for example a bot actor or a scheduled run on an Issue that already has a `triage:*` label). Report the reason and stop; do not mutate the Issue.
- `result.issue_number`, `title`, `body`, and `labels` are the Issue facts at event time. `labels` is the FSM input state.
- `result.event_name` and `result.event_action` identify the trigger (for example `issues` / `opened`, `issue_comment` / `created`). Use them to pick the FSM event per [category-fsm.md](category-fsm.md).
- `result.comment_id` is set only for `issue_comment` events; otherwise `null`.
- `result.gate` is present only when the Issue state is known. It carries facts for the caller; the agent does not act on it.
- `status: "error"` is fatal: stop and report the error text.
- `verifier_context` is a one-line markdown string for a verifying step (when the caller runs one).
