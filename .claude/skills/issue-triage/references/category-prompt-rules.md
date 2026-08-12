# Issue triage prompt rules

## Classification confidence

- Apply a type label (`bug`, `feature`, `question`, `documentation`) only when confident.
- Otherwise keep or apply `needs-triage` only and ask for the missing facts.

## Questions (no self-censorship)

- Put clarifying questions in **Issue comments**.
- Do **not** suppress, soften, or skip questions because they seem basic, repetitive, or “obvious.”
- Do **not** rely on AskUserQuestion or chat-only prompts for automation runs.
- Prefer a short numbered list of concrete questions over vague “please provide more info.”

## Ready guidance

When applying `triage:ready`, tell the human how to request a draft autofix PR later (`autofix` label or future assign-command). Do not start issue-autofix yourself.

## Side effects

- Use `gh` for labels and comments.
- Only allowlisted labels from `scripts/labels.json`.
- No repository file edits when Constraints say `may_edit: false`.
- Mentions / `@` triggers are out of scope.
