<!--
Draft PR template for github-issue-draft-pr.
Based on .github/PULL_REQUEST_TEMPLATE.md (same sections and order), so PRs look the same in every repository.
Load ONLY when opening the PR. Keep the section headings in English as written; write the prose in the response language (CHK-01).
Title: fix: <summary> (#<issue>)
Include ALL changed files under Changes. Link a changed file on the working branch and a deleted file on the base branch (File row in references/common-output-format.md).
-->

## Overview

<2-4 sentences: the problem and the fix>

- **Repository**: [<owner>/<repo>](https://github.com/<owner>/<repo>) (base branch: `<base branch>`); when the change also refers to another repository, name it too
- **What**: <high-level change, not file names>
- **Why**: <root cause, with the Incident value; omit the Incident value when it would be `unknown`>
- **Impact**: <deployment risk, breaking changes, compatibility, rollback>

## Related Issues

<!-- When the Issue is in a different repository than the PR, write `Closes <owner>/<repo>#<issue>`. -->

Closes #<issue>

## Changes

### <Area, for example the directory or module>

- **[<owner>/<repo>:<path>](https://github.com/<owner>/<repo>/blob/<working branch>/<path>)**: <what changed and why>

## Testing

- Local: <what was run or checked, or `not run (<reason>)`>
- Coverage: <test types, or `none`>
- Edge cases: <scenarios verified, or `none`>

## Type of Change

<!-- Check only what applies; leave the rest unchecked. -->

- [ ] ✨ Feature
- [ ] 🐛 Bug Fix
- [ ] ⚙️ Configuration
- [ ] 📝 Documentation
- [ ] 🧪 Test
- [ ] 🔒 Security

## Checklist

<!-- Check only what you actually did. Never check an item you did not verify. -->

- [ ] Follows project conventions (`AGENTS.md` / `CLAUDE.md`)
- [ ] Documentation updated (if applicable)
- [ ] Breaking changes documented

## Additional Notes

- Incident: <Incident value from the link format; omit this whole line when the value would be `unknown`>
- Rollback: <how to roll back>
- Requires human review before merge.

---

<details>
<summary>Auto-close rules for this PR</summary>

The DevOps Agent follow-up bot applies these rules on every scheduled run.

**This PR is closed automatically when any of the following holds:**

| Condition                            | Trigger                                                                                                                                     |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| AUTO-C1: Linked Issue is closed      | The linked Issue (`Closes #N`) is already closed — closed as `not_planned`                                                                  |
| AUTO-C2: Fix applied outside this PR | A comment or review states the fix was committed or merged elsewhere (e.g. "already fixed in #N", "別途対処済み") — closed as `not_planned` |
| AUTO-C3: No fix needed               | A comment or review states no change is required (e.g. "won't fix", "false positive", "修正不要") — closed as `not_planned`                 |
| AUTO-C4: Explicit close instruction  | A comment explicitly says to close this PR — closed as `not_planned` (or `completed` when the problem is resolved)                          |

**Conflict rule:** when instructions conflict (e.g. one comment says keep open, another says close), **close takes precedence**. The bot posts a comment explaining the conflict before closing.

</details>

<details>
<summary>Meta</summary>

<!--
Fixed keys stay in English. One `key: value` per line; keep this block last.
response_language: the language code of your response (ja, en, ...); the follow-up bot writes its comments in this language.
incident: the Incident value from the link format; omit this line when it would be `unknown`.
repository: the <owner>/<repo> full name (plain text, no link inside this block); write `none (<reason>)` (candidates in the reason when ambiguous) when the repository is ambiguous or none holds the target.
last_followup: the follow-up bot sets this to the UTC time of its latest run; write `none` when creating this PR.
-->

```text
response_language: <language code, e.g. ja>
incident: <Incident value>
environment: <dev | qa | stg | prd>
repository: <owner>/<repo>
root_cause_status: <confirmed | suspected>
created_by: devops-agent (<agent name>) at <YYYY-MM-DDTHH:MM:SSZ>
last_followup: none
```

</details>
