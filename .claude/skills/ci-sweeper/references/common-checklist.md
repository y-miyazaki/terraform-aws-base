# CI Sweeper Checklist

Gate IDs are for agent self-check and Deferred/Watch reasons. Failure identity in reports remains workflow / job / path / log excerpt — not these IDs.

## Classification

### CLASS-01: Failure type routing

- [ ] `regression` → `### Candidates` when `may_edit` is `false`; `### Changes` when `may_edit` is `true`
- [ ] `flake` → `### Watch` (no auto-fix)
- [ ] `infra` / `env` → `### Watch` (escalate to human)
- [ ] Detect `failure_type` is a hint only — reclassify when `log_excerpt` contradicts it
- [ ] `ignored[]` → note in Overview when non-empty; omit dedicated section
- **PASS** if every failure has one primary classification row

## Scope

### SCOPE-01: Fix caps and path guards

- [ ] Respect path scope per [category-scope.md](category-scope.md)
- [ ] Fix at most one regression when more than three failures are present
- [ ] Defer fixes requiring more than five files as Watch
- **PASS** if apply edits stay within scope and caps

## Verification

### VERIFY-01: Post-fix validation record

- [ ] When validation was run after edits, record commands and outcomes in `## Verification` (apply) or Session Metrics (automation)
- **PASS** if apply claims match commands actually run

## Output

### OUT-01: Survey vs apply shape

- [ ] Emit survey or apply shape per [common-output-format.md](common-output-format.md)
- [ ] When `may_edit` is `false`, survey shape only — do not edit files
- [ ] When `may_edit` is `true`, apply shape; reconcile **Changes** / **Deferred** with `git diff --name-only`
- [ ] **Deferred** failures MUST NOT leave edits in git diff — revert stray fixes before synthesis
- **PASS** if survey and apply shapes are not mixed

## Error handling

- `skip` true or no actionable failures → survey no-op; stop
- More than three failures → fix the first regression only when `may_edit` is `true`; defer rest as Watch
- Fix requires >5 files → classify as Watch; no edits
- Validation tool missing → defer as Watch unless fixing one line from `log_excerpt`

## Examples

| Failure signal              | Classification | Section / action        |
| --------------------------- | -------------- | ----------------------- |
| Workflow lint (actionlint)  | regression     | Fix workflow YAML only  |
| Shell lint (shellcheck)     | regression     | Fix reported line only  |
| Runner OOM in logs          | flake / infra  | Watch; escalate         |
