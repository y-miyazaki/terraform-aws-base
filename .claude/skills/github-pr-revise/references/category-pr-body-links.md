# PR Body Links (github-pr-revise)

Link everything that can be linked in Overview, Summary, and Verification. A code span is not a link. Templates mark linkable items with `<linked path>`, `<linked sha>`, `<linked workflow>`, and `<linked job>`; replace each marker with a markdown link and never emit the marker itself.

## Repository and ref

- Resolve `{owner}/{repo}` from `GITHUB_REPOSITORY` when set; otherwise run `gh repo view --json nameWithOwner`.
- Use the full commit SHA of the PR head after your edits as `{ref}` for changed files; use the PR base SHA (`gh pr view <n> --json baseRefOid`) for paths you cite but did not change. Never link a branch name; later commits shift the lines.

## File paths

- Link a repository path as `[path](https://github.com/{owner}/{repo}/blob/{ref}/{path})`; add `#L{start}-L{end}` when you cite specific lines.
- Percent-encode path segments that contain spaces or special characters.
- Write a path as a code span only when the file does not exist at that ref (for example a deleted file).

## Commits, workflows, and jobs

- Link a commit as `[short-sha](https://github.com/{owner}/{repo}/commit/{full-sha})`.
- Link a workflow file as a path (see File paths); link a workflow run or job by its run or job URL from `gh run view`.

## Pull requests, Issues, and comments

- Write pull requests and Issues as `#N` in plain text (GitHub links them); never put `#N` in a code span.
- Link the review comment you addressed by its `html_url` when available.

## Not links

- Commands, mentions, and tokens stay as code spans.
- Do not invent example `org/repo` URLs; use `<owner>/<repo>` placeholders in prose.
