# PR Revise Checklist

Gate IDs are for agent self-check and Deferred reasons. PR identity in reports remains PR number — not these IDs.

## Scope

### SCOPE-01: Mention-gated revision

- [ ] Act only on human mention-gated feedback from detect JSON
- [ ] Apply revisions on the PR head (or stacked branch when landing is `open_pr`)
- [ ] Do not act on bot comments or mention-less comments
- **PASS** if edits match the human's requested revision scope

## Output

### OUT-01: Report shape

- [ ] Emit report per [common-output-format.md](common-output-format.md)
- [ ] Survey shape when `may_edit: false`; apply shape when `may_edit: true` and `write_target: fix`
- **PASS** if report matches automation envelope for the resolved `may_edit` / `write_target`

## Error handling

- Detect `status: error` → stop; do not mutate repository files
- Detect `skip: true` → report skip reason; do not push
- `may_edit: false` → survey only; do not edit files
- `write_target` not `fix` when edits requested → survey only; note mismatch
