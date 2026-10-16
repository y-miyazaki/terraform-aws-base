# Output Format

## Link format

Write links in exactly these forms in the Notion page, the PR body, the investigation result, and Slack.

| Field        | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Incident     | The URL of this investigation in the AWS DevOps Agent web app, when you can read it from your own context. Otherwise `incidentId=<id>` taken from the incident (never invent an ID or a URL); when neither is available, `unknown`. When the value would be `unknown`, omit the Incident field entirely (the whole line or row), do not write it.                                                                                                                                                                                                                                                                          |
| Issue        | The full URL of the Notion page returned by the tool (the field is named `Issue` in Slack as well)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| PR           | The full `html_url` returned by the tool, for example `https://github.com/<owner>/<repo>/pull/<number>`, followed by its state: `Draft`, `open`, `merged`, or `closed`                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Repository   | `<owner>/<repo>` full name as returned by the tool. In the page body, the PR body, and the investigation result write it as a Markdown link `[<owner>/<repo>](https://github.com/<owner>/<repo>)`, in Slack as described below the table                                                                                                                                                                                                                                                                                                                                                                                   |
| File         | The label is `<owner>/<repo>:<path>`, never a bare file name or a relative path, and the label is never wrapped in backticks (except inside verbatim log excerpts and code blocks). In the page body, the PR body, and the investigation result write a Markdown link `[<owner>/<repo>:<path>](https://github.com/<owner>/<repo>/blob/<branch>/<path>)`, in Slack as described below the table. `<branch>` is the branch that actually holds the file: the working branch for a file the PR changes, otherwise the base branch (also for a file the PR deletes). Add `#L<line>` (or `#L<start>-L<end>`) to point at a line |
| Missing item | `none (<reason>)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

Never write a URL you built or guessed, with one exception: a Repository or File link may be assembled from `<owner>/<repo>`, a branch, and a path that you verified on that branch (`get_file_contents` with `ref`, or the file you just wrote; `search_code` proves the path only on the default branch). When the path is not verified, or the file is not in a GitHub repository, write the plain label without a link (still no backticks); name a file outside any GitHub repository by its source (host/group/repo or the AWS resource ARN). Put each Incident, Issue, and PR URL on its own line; Repository and File links may sit inside a sentence or list item.

In Slack replies, write the Repository and File links in Slack link syntax `<URL|label>`: the angle brackets are literal and nothing is wrapped in backticks. Examples: `<https://github.com/acme/infra|acme/infra>` and `<https://github.com/acme/infra/blob/develop/terraform/alarm.tf|acme/infra:terraform/alarm.tf>`. The "plain text" rule for replies means no code blocks or Markdown formatting; these links are allowed. Do not use a Markdown link in Slack: it is not rendered.

## Slack reply

The incident `description` may end with a line in this exact format:

```text
slack_reply_target: channel_id=<channel id> thread_ts=<timestamp>
```

- If the line is absent or malformed, send no Slack reply and do not guess a channel or a timestamp.
- If the line is present, call `slack_reply_to_thread` with that `channel_id` and `thread_ts` for reply A and reply B (once each per investigation), and at most once more for reply C (human escalation), all to the same thread.
- Do not use `@channel`, `@here`, or `@everyone`. Do not include secrets, tokens, or customer data.

### Reply A (right after the investigation starts, always)

Reply A has no `Repository:` line: the repository is not resolved at the start.

```text
[devops-agent] Investigation started
Incident: <Incident value>
```

### Reply B (at the end, always)

If the Incident value would be `unknown`, omit the `Incident:` line from replies A, B, and C. Send B after the Notion page (and the PR, when one is created) exist, and also when none is created. Plain text, 10 lines or fewer. Write `Repository:` as `none (<reason>)` when the repository is ambiguous or no associated repository holds the target (same wording as the `repository:` key of the Meta block). Keep the labels and the Outcome value in English; write the text after `Root cause (...)` and `Next` in the response language (CHK-01).

```text
[devops-agent] <Outcome>
Incident: <Incident value>
Repository: <Repository value>
Issue: <Issue value>
PR: <PR value>
Root cause (<confirmed|suspected>): <one or two sentences>
Next: <the next step for a human>
```

`<Outcome>` is exactly one of:

| Outcome           | Use when                                                                                                         |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| `New`             | A Notion page was created                                                                                        |
| `Already tracked` | An existing page/PR was reused (link the existing ones)                                                          |
| `No action`       | Root cause unconfirmed, no action needed, or the alarm recovered (add the evidence in one line under Root cause) |
| `Failed`          | A tool failed and nothing could be created (put the failing tool and the error text under Next)                  |

Reply in every outcome; do not reply only when a new problem is found.

### Reply C (human escalation, only when a human decision is needed)

Send at most once per investigation, after A, to the same thread, only when a person must decide or act and reply B alone would not reach them (for example the cause cannot be confirmed without access you do not have). Plain text, 5 lines or fewer, no mention (`@`). It has no `Repository:` line.

```text
[devops-agent] Human decision needed
Incident: <Incident value>
Needed: <what the person must decide or do>
Why: <one sentence>
```

## Investigation result

The same fields as reply B (Outcome, Incident, Repository, Issue, PR, Root cause, Next), without the 10-line limit, plus any error text from failed tools. Omit the Incident field when its value would be `unknown`.
