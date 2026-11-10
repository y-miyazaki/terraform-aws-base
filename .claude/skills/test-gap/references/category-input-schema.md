# Detect JSON schema

The skill detect script (`scripts/detect_test_gap.sh`) emits:

```json
{
  "status": "ok",
  "scope": "range",
  "since": "<ref>",
  "commit_range": "<ref>..HEAD",
  "skip": false,
  "hotspots": [{ "path": "src/a.sh", "kind": "churn", "count": 7, "window": "90.days" }],
  "ledger": {
    "file": "<ledger-path>.json",
    "processed": [{ "path": "tests/foo_test.sh", "attempts": 1, "outcome": "pr_created", "processed_at": "2026-10-11T10:00:00Z" }]
  },
  "warnings": [],
  "verifier_context": "## test-gap ledger (recently processed test paths)\n..."
}
```

- `skip` is always `false`. Detect never states that tests are missing.
- `hotspots[]` lists frequently edited paths. They are hints, not findings.
- `ledger.processed[]` lists recently processed test file paths. Do not select a target whose paired test file path is listed (adding another new test file for that same target also counts as selecting it again) unless you can state a new reason. An `## Open Rejections` section, when the caller supplies one in the prompt (optional; it lists targets a reviewer rejected in an earlier run, with the reason), counts as a stated new reason for selecting a listed target again.
- `warnings[]` lists recoverable sensor problems (for example an invalid `since` ref).
- `status: "error"` is fatal: stop and report the error text.
- `verifier_context` is a markdown string listing `ledger.processed[]` paths (with attempts and outcome) so a verifying step (when the caller runs one) can confirm the target is not a recently processed one. It is an empty string when the ledger has no processed entries.
