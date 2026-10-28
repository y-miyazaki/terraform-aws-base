# PR Review Report Format

The agent writes a JSON report. The platform validates it, verifies quotes at the base commit, renders a single COMMENT review, and posts it. See `assets/review-body-template.md` and `assets/inline-comment-template.md` for the rendered result.

## Survey result (`agent_edit_allowed: false`)

No file edits. Summarize in chat or in the session report; **do not write the report file**.

```markdown
# PR Review Result

## Overview

<PR #N → intent confirmed → findings count → no report file written>

## Summary

### Candidates

| Severity                          | Location    | Evidence kind           | Summary |
| --------------------------------- | ----------- | ----------------------- | ------- |
| Critical \| Warning \| Suggestion | `path:line` | rule \| criteria \| bug | …       |
```

Zero findings — Overview says so explicitly; omit `### Candidates`.

## Report file (`agent_edit_allowed: true`, `agent_edit_target: report`)

Write JSON to `result.report_path` (for example `.loop-review/pr-<n>.json`). Start from `assets/report-template.json`.

| Field                 | Type   | Rule                                                                                                  |
| --------------------- | ------ | ----------------------------------------------------------------------------------------------------- |
| `pr_number`           | number | Required. Must equal detect `result.pr_number`                                                        |
| `head_sha`            | string | Required. Copy detect `result.head_sha`; a missing or stale value makes the platform refuse to post   |
| `base_sha`            | string | Copy detect `result.base_sha`                                                                         |
| `response_language`   | string | Language code used for agent-written prose (`en`, `ja`, ...)                                          |
| `premises`            | object | `pr_body`: what you read from the PR body or `none`; `linked`: array of `#N` / paths, or `none`       |
| `summary`             | string | What the PR does and the overall assessment; say explicitly when there are no findings                |
| `findings`            | array  | May be empty. Order by severity, then by importance                                                   |
| `findings[].id`       | number | Optional sequence hint; the platform numbers findings itself                                          |
| `findings[].severity` | string | `Critical`, `Warning`, or `Suggestion`                                                                |
| `findings[].title`    | string | One-line summary                                                                                      |
| `findings[].evidence` | object | `kind` (`rule` \| `criteria` \| `bug`); `rule` / `criteria` require `path` and verbatim `quote`       |
| `findings[].location` | object | `path`, `line`, optional `start_line` (less than `line`), `side` (`RIGHT` default, `LEFT`), `in_diff` |
| `findings[].impact`   | string | What happens if left as is                                                                            |

Rules:

- Keep `severity`, `evidence.kind`, and field names exactly as listed (English)
- `evidence.quote` for `rule` / `criteria` is copied verbatim from the base file; multi-line quotes keep their line breaks
- `evidence.quote` for `bug` states the diff line and the concrete input or state that fails
- Set `location.in_diff: true` only when the line is inside a hunk of the PR diff; otherwise `false` (the finding is then placed in the review body)
- Write `summary`, `title`, `impact`, and premise text in the response language; keep quotes, code, and paths verbatim
- Zero findings: write `"findings": []` and still fill `premises` and `summary`
