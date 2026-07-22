# loop-ci-sweeper Checklist

## Classification

- `regression` → Actionable Fixes (minimal fix candidate at L2+)
- `flake` → Watch Items (no auto-fix)
- `infra` / `env` → Watch Items (escalate to human)
- Detect script emits `failure_type` as an optional hint; **Skill** classifies Fix / Watch / Escalate

## Scope Guards

- Respect path scope per `category-scope.md` (interactive: no skill allowlist/denylist; loop: caller `allowlist` in `## Constraints`, caller `denylist` via verifier)
- Fix at most one regression when more than three failures are present
- Defer fixes requiring more than five files as Watch

## Validation

- Run stack-appropriate validation after edits (see `category-validation-commands.md`)
- Document validation outcome in Summary; do not claim success on failure

## Output

- Emit all four report sections per `common-output-format.md`
- Include `Actionable Fixes` and `Watch Items` headings even when empty
- Before PR synthesis: reconcile **Fixes Applied** / **Deferred** with `git diff --name-only` per [common-output-format.md](common-output-format.md)
- **Deferred** failures MUST NOT leave edits in git diff — revert stray fixes from earlier attempts

## Error Handling

- `skip` true or no actionable failures → four-section report, empty Actionable Fixes, stop
- More than three failures → fix the first regression only; defer rest as Watch
- Fix requires >5 files → classify as Watch, set Summary **Outcome** to `watch`, recommend human review
- Validation tool missing → note in Summary, defer fix as Watch unless the change is a single reported line from `log_excerpt`

## Examples

- Workflow lint failure (actionlint) → fix workflow YAML syntax only
- Shell script lint failure (shellcheck) → fix the reported script line only
- Runner OOM in logs → Watch item, set **Outcome** to `watch`, escalate (no code change)

