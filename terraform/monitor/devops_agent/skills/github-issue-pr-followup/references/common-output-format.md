# Output Format

## Run result

One line per handled item, then the errors if any tool failed. Use the full `html_url` returned by the tool (never only `#<number>`).

```text
<Issue or PR full URL> <action>
```

`<action>` is exactly one of: `answered`, `updated`, `committed`, `closed`, `asked a question`, `no unanswered comments`, `deferred`, `skipped (<failing tool>: <error text>)`.

Items recorded as `no unanswered comments` do **not** count toward the 20-item action limit per run.

When there are no targets, write `no targets`.

## Answer comment

Use [comment-template.md](../assets/comment-template.md). The last line is always `-- devops-agent`.
