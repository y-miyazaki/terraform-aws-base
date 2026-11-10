# Issue Triage Checklist

Gate IDs are for agent self-check and Deferred reasons. Issue identity in reports remains issue number and event — not these IDs.

## Classification

### CLASS-01: Type labels

- [ ] Apply `bug`, `feature`, `question`, or `documentation` only when confidence is high
- [ ] When confidence is low, keep `needs-triage` and ask clarifying questions on the Issue
- [ ] Do not invent labels outside `scripts/labels.json`
- **PASS** if every applied type label matches classification confidence

## Label FSM

### FSM-01: Allowlisted triage labels

- [ ] Drive transitions per [category-fsm.md](category-fsm.md) (`opened`, `mark_needs_info`, `mark_ready`, `human_retriage`)
- [ ] Apply only labels from `scripts/labels.json`
- [ ] On unsafe partial failure, apply `triage:failed` when catalog allows
- **PASS** if FSM state matches event and allowlist

## Comments

### COMM-01: Thread history

- [ ] Create a new Issue comment via `scripts/issue_comment.sh create` on each FSM transition and on re-triage after a human reply (interactive; in a message run `message.md` plays the same role)
- [ ] Use `scripts/issue_comment.sh correct` only for minor corrections to the latest marked bot comment in the same FSM state (interactive only)
- [ ] Do not overwrite prior triage analysis or edit human comments
- **PASS** if the thread would retain prior bot analysis as separate comments

## Scope

### SCOPE-01: API-only side effects

- [ ] Side effects are Issue labels and comments only (or message-run files); never edit repository files, regardless of `agent_edit_allowed`
- [ ] Do not open PRs or start github-issue-autofix
- [ ] Do not fire `repository_dispatch`
- **PASS** if no repository file edits

## Output

### OUT-01: Session report shape

- [ ] Emit report per [common-output-format.md](common-output-format.md)
- [ ] List each `gh` mutation (Interactive) or each file written to the message directory (message run) under **Changes**
- [ ] Record skipped or deferred items when detect skipped or questions remain
- **PASS** if report matches automation or interactive shape

## Error handling

Follow the Error Handling table in `SKILL.md` (`### Error Handling`); it is the single source for error conditions and actions.
