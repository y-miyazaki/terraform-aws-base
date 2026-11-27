# Detect JSON schema

The skill detect script (`scripts/detect_autofix.sh`) emits one JSON object. The `result` shape depends on the mode the caller chose.

Single-Issue mode (default):

```json
{
  "status": "ok",
  "skip": false,
  "message": "<reason or proceed note>",
  "result": {
    "issue_number": "12",
    "gate": { "entity": { "kind": "issue", "number": 12, "state": "open" } }
  }
}
```

Items mode (the caller sets `AUTOFIX_ITEMS=true`) and scan mode (`AUTOFIX_SCAN=true`) emit `result.items[]`:

```json
{
  "status": "ok",
  "skip": false,
  "message": "<N> eligible Issue(s)",
  "result": {
    "items": [
      {
        "key": "issue:12",
        "entity": { "kind": "issue", "number": 12 },
        "context": { "issue_number": 12 },
        "gate": { "entity": { "kind": "issue", "number": 12, "state": "open" } }
      }
    ]
  }
}
```

- `skip: true` means no work: an open or draft PR already closes the Issue, the open autofix PR limit is reached, or no Issue qualifies. Report `message` and stop; skip results carry `result: {}`.
- `result.issue_number` is the Issue to fix in single-Issue mode. In items mode the run handles one item at a time: use `context.issue_number` of the item you were given.
- `result.gate` carries facts for the caller; the agent does not act on it.
- `status: "error"` is fatal (the script fails closed when it cannot read the Issue or the PR list): stop and report the error text.
