# CI Sweeper Checklist

Gate IDs are for agent self-check and Deferred/Watch reasons. Failure identity in reports remains workflow / job / path / log excerpt — not these IDs.

## Classification

### CLASS-01: Failure type routing

- [ ] `regression` → `### Candidates` when `agent_edit_allowed` is `false`; `### Changes` when `agent_edit_allowed` is `true`
- [ ] `flake` → Watch-class (no auto-fix)
- [ ] `infra` / `env` → Watch-class (escalate to human)
- [ ] Watch-class rows go under `### Watch` in survey shape and under `### Deferred` in apply shape (apply shape has no `### Watch`)
- [ ] Detect `failure_type` is a hint only — reclassify when `log_excerpt` contradicts it
- [ ] `ignored[]` → note in Overview when non-empty; omit dedicated section
- **PASS** if every failure has one primary classification row

## Scope

### SCOPE-01: Fix caps and path guards

- [ ] Respect path scope per [category-scope.md](category-scope.md)
- [ ] When more than three failures are present, fix only the first regression; defer the rest
- [ ] A fix requiring more than five files is Watch-class — no edits for that failure
- **PASS** if apply edits stay within scope and caps

## Verification

### VERIFY-01: Post-fix validation record

- [ ] After edits, run the repository's existing check for each fixed job when available; record commands and outcomes in `## Verification` (and Session Metrics on the automation path)
- **PASS** if apply claims match commands actually run

## Output

### OUT-01: Survey vs apply shape

- [ ] Emit survey or apply shape per [common-output-format.md](common-output-format.md)
- [ ] When `agent_edit_allowed` is `false`, survey shape only — do not edit files
- [ ] When `agent_edit_allowed` is `true`, apply shape; reconcile **Changes** / **Deferred** with `git diff --name-only`
- [ ] **Deferred** failures MUST NOT leave edits in git diff — revert stray fixes before synthesis
- **PASS** if survey and apply shapes are not mixed

## Error handling

- `skip` true or no actionable failures → survey no-op per [common-output-format.md](common-output-format.md) (Overview explains no-op); stop
- More than three failures and `agent_edit_allowed` is `true` → fix only the first regression; defer the rest under `### Deferred`
- Fix requires >5 files → Watch-class; no edits for that failure
- Validation tool missing → defer the failure unless fixing one line from `log_excerpt`

## Examples

| Failure signal             | Classification | Section / action       |
| -------------------------- | -------------- | ---------------------- |
| Workflow lint (actionlint) | regression     | Fix workflow YAML only |
| Shell lint (shellcheck)    | regression     | Fix reported line only |
| Runner OOM in logs         | flake / infra  | Watch; escalate        |
