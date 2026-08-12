# issue-triage detect dispatch hook

Trusted platform path (never the Agent) may run `on_detect_dispatch.sh` after
detect when `result.dispatch_requested` is true.

## When flags are set

`detect_issue.sh` sets dispatch flags only when:

- Issue labels include both `triage:ready` and `autofix` (and not `triage:failed`)
- The event is `issues` / `labeled` with label name `autofix` (autofix intake)
- Bot actors and bot comments do not request dispatch

## Invoke semantics

`loop-entity-detect` invokes this hook whenever `dispatch_requested==true` and
detect `status==ok`. Agent execute may still be skipped (`skip==true`) on the
same detect result — for example when `autofix` is labeled while the Issue is
already `triage:ready`.

## Dry run

Set `DISPATCH_DRY_RUN=1` to log the intended `repository_dispatch` without
calling GitHub (used by Bats).
