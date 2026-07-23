# loop-ci-sweeper Checklist

## Classification

- `regression` → `### Candidates` when `may_edit` is `false`; `### Changes` when `may_edit` is `true`
- `flake` → `### Watch` (no auto-fix)
- `infra` / `env` → `### Watch` (escalate to human)
- Detect `failure_type` is a hint only — reclassify when `log_excerpt` contradicts it
- `ignored[]` → note in Overview when non-empty; omit dedicated section

## Scope Guards

- Respect path scope per `category-scope.md`
- Fix at most one regression when more than three failures are present
- Defer fixes requiring more than five files as Watch

## Validation

- Run stack-appropriate validation after edits (see `category-validation-commands.md`)
- Record outcome in `## Verification` (apply only)

## Output

- Emit survey or apply shape per [common-output-format.md](common-output-format.md)
- When `may_edit` is `false`, survey shape only — do not edit files
- When `may_edit` is `true`, apply shape; reconcile **Changes** / **Deferred** with `git diff --name-only`
- **Deferred** failures MUST NOT leave edits in git diff — revert stray fixes before synthesis

## Error Handling

- `skip` true or no actionable failures → survey no-op; stop
- More than three failures → fix the first regression only when `may_edit` is `true`; defer rest as Watch
- Fix requires >5 files → classify as Watch; no edits
- Validation tool missing → defer as Watch unless fixing one line from `log_excerpt`

## Examples

- Workflow lint failure (actionlint) → fix workflow YAML syntax only
- Shell script lint failure (shellcheck) → fix the reported script line only
- Runner OOM in logs → Watch item; escalate (no code change)
