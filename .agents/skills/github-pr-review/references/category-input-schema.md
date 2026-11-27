# Detect JSON schema

The skill detect script (`scripts/detect_pr_review.sh`) emits one JSON object with mechanical facts only; it never states findings:

```json
{
  "status": "ok",
  "skip": false,
  "message": "",
  "result": {
    "handoff_key": "entity:pr:5",
    "entity": { "kind": "pr" },
    "pr_number": 5,
    "base_sha": "<base commit>",
    "head_sha": "<head commit>",
    "changed_files": ["path/a.sh"],
    "report_path": ".loop-review/pr-5.json",
    "event_name": "pull_request",
    "event_action": "opened",
    "force": false
  },
  "verifier_context": "PR #5 base <sha> head <sha> files: 1"
}
```

- `skip: true` means no review is due (bot-authored, draft, fork, excluded label, or a review with this skill's marker already exists and `force` is not set). Report `message` and stop without writing a report.
- `result.base_sha` and `result.head_sha` pin the review to commits: read rules at the base commit and cite lines at the head commit.
- `result.changed_files` is the scope of the review.
- `result.report_path` is the path to write the report JSON to when `agent_edit_allowed` is `true`.
- `result.force` is `true` when the caller asked for a re-review despite an existing review marker.
- `status: "error"` is fatal (the script fails closed when it cannot obtain a required fact): stop and report the error text.
- `verifier_context` is a one-line markdown string for a verifying step (when the caller runs one).
