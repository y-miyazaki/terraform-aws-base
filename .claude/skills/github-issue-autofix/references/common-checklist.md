# Issue Autofix Checklist

Gate IDs are for agent self-check and Deferred reasons. Issue identity in reports remains issue number — not these IDs.

## Scope

### SCOPE-01: Fix and PR shape

- [ ] Implement a minimal fix for the source Issue when `agent_edit_allowed: true` and `agent_edit_target: fix`
- [ ] Apply shape: PR body includes the literal `Fixes #<N>`
- [ ] Survey shape: PR body references `Refs #<N>` and contains no closing keyword (`Fixes`, `Closes`, `Resolves`)
- [ ] Do not call `repository_dispatch` from the Agent
- **PASS** if apply edits address the Issue and the apply PR body closes it; a survey PR body never closes it

## Output

### OUT-01: Report shape

- [ ] Emit report per [common-output-format.md](common-output-format.md)
- [ ] Survey shape when `agent_edit_allowed: false`; apply shape when `agent_edit_allowed: true` and `agent_edit_target: fix`
- **PASS** if report matches automation envelope for the resolved `agent_edit_allowed` / `agent_edit_target`

## Error handling

Follow the Error Handling table in `SKILL.md` (`### Error Handling`); it is the single source for error conditions and actions.
