# Review Links (github-pr-review)

Link everything that can be linked in text that will be posted to GitHub. The platform renders the evidence, location, and file links itself from the report fields; follow these rules for any link you write in `summary`, `title`, or `impact`.

- Pin line links to a full commit SHA: `https://github.com/{owner}/{repo}/blob/{full-sha}/{path}#L{start}-L{end}`. Never link a branch name; later commits shift the lines
- Evidence (rule or criteria quote) links use the **base** SHA from detect `result.base_sha`
- Lines changed by the PR use the **head** SHA from detect `result.head_sha`
- Link a repository path only when the file exists at that SHA; otherwise write it as a backtick path
- Refer to pull requests and Issues as `#N`; link commits as `/commit/{sha}`
- Do not invent example `org/repo` URLs; templates use backtick placeholders such as `<owner>/<repo>`
- Percent-encode path segments with special characters
