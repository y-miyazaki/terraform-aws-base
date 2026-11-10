# PR Review Checklist

Gate IDs are for agent self-check and Deferred reasons. PR identity in reports remains PR number — not these IDs.

## Scope

### SCOPE-01: Read-only first review

- [ ] Write only the report file (automation: `result.report_path`; interactive: the path the user names), and only when `agent_edit_allowed: true` and `agent_edit_target: report`
- [ ] Never post, approve, request changes, or edit source files
- [ ] Use `gh` for read-only calls only
- **PASS** if the report file is the only file changed and nothing was posted

## Evidence

### EVID-01: Every finding has evidence

- [ ] Each finding has `evidence.kind` of `rule`, `criteria`, or `bug`
- [ ] `rule` / `criteria`: `evidence.path` exists at the base commit and `evidence.quote` is a verbatim substring of it
- [ ] `bug`: the diff line and a concrete failing input or state are in `evidence.quote`
- **PASS** if no finding rests on preference, paraphrase, or a file read from the PR head

### EVID-02: Premises recorded

- [ ] PR body, linked Issues, and related specs were read before drafting findings
- [ ] `premises` records the result (`none` when absent)
- **PASS** if `premises.pr_body` and `premises.linked` are present

## Exclusions

### EXCL-01: Nothing excluded is reported

- [ ] No pre-existing problems, generated or lock files, lint/format/secret items, preferences, or unrealistic risks
- **PASS** if every finding is caused by a line in the PR diff

## Output

### OUT-01: Report shape

- [ ] Report matches [common-output-format.md](common-output-format.md) and `assets/report-template.json`
- [ ] `head_sha` / `base_sha` copied from detect `result.head_sha` / `result.base_sha` (interactive: `headRefOid` / `baseRefOid` from `gh pr view`)
- **PASS** if the JSON parses and `pr_number` equals detect `result.pr_number` (interactive: the PR number the user gave)

## Error handling

Follow the Error Handling table in `SKILL.md` (`### Error Handling`); it is the single source for error conditions and actions.
