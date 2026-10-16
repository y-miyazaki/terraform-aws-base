# Output Format

## Run result

One line per handled item, then the errors if any tool failed. Use the full URL returned by the tool (never only an identifier such as `ENG-123` or `#<number>`): the Linear `url` for an Issue, the GitHub `html_url` for a PR.

```text
<Issue or PR full URL> <action>
```

`<action>` is exactly one of: `answered`, `updated`, `committed`, `closed`, `asked a question`, `no unanswered comments`, `deferred`, `skipped (<failing tool>: <error text>)`.

Items recorded as `no unanswered comments` do **not** count toward the 20-item action limit per run.

When there are no targets, write `no targets`; when the Linear team is missing or not found, write `no targets (<reason>)`.

## Answer comment

Use [comment-template.md](../assets/comment-template.md). The last line is always `-- devops-agent`.
