# Issue Autofix Checklist

Gate IDs are for agent self-check and Deferred reasons. Issue identity in reports remains issue number — not these IDs.

## Scope

### SCOPE-01: Fix and PR shape

- [ ] Implement a minimal fix for the source Issue when `agent_edit_allowed: true` and `agent_edit_target: fix`
- [ ] PR body includes `Fixes #<N>` (or equivalent closing keyword)
- [ ] Do not call `repository_dispatch` from the Agent
- **PASS** if apply edits address the Issue and PR body closes it

## Output

### OUT-01: Report shape

- [ ] Emit report per [common-output-format.md](common-output-format.md)
- [ ] Survey shape when `agent_edit_allowed: false`; apply shape when `agent_edit_allowed: true` and `agent_edit_target: fix`
- **PASS** if report matches automation envelope for the resolved `agent_edit_allowed` / `agent_edit_target`

## Error handling

- Detect `status: error` → stop; do not mutate repository files
- Detect `skip: true` → report skip reason; do not open a PR
- `agent_edit_allowed: false` → survey only; do not edit files
- `agent_edit_target` not `fix` when edits requested → survey only; note mismatch
