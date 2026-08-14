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

- [ ] Create a new Issue comment via `scripts/issue_comment.sh create` on each FSM transition and on re-triage after a human reply
- [ ] Use `scripts/issue_comment.sh correct` only for minor corrections to the latest marked bot comment in the same FSM state
- [ ] Do not overwrite prior triage analysis or edit human comments
- **PASS** if the thread would retain prior bot analysis as separate comments

## Scope

### SCOPE-01: API-only side effects

- [ ] Labels and Issue comments only when `may_edit` is false
- [ ] Do not open PRs or start github-issue-autofix
- [ ] Do not fire `repository_dispatch`
- **PASS** if no repository file edits under L1 constraints

## Output

### OUT-01: Session report shape

- [ ] Emit report per [common-output-format.md](common-output-format.md)
- [ ] List each `gh` mutation under **Changes**
- [ ] Record skipped or deferred items when detect skipped or questions remain
- **PASS** if report matches automation or interactive shape

## Error handling

- Detect `status: error` → stop; do not mutate Issue
- `gh` failure → report in session output; avoid partial unlabeled state when possible
- Unknown label requested → do not apply; keep `needs-triage`
