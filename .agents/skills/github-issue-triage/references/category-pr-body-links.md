# Comment Links (github-issue-triage)

Link everything that can be linked in an Issue comment. Apply when writing the text for `scripts/issue_comment.sh` (`create` and `correct`) or `message.md` in a message run.

## References

- Write Issues and pull requests as `#N` in plain text (GitHub links them); use `<owner>/<repo>#N` for another repository. Never put `#N` in a code span.
- Link a commit as `[short-sha](https://github.com/{owner}/{repo}/commit/{full-sha})`.
- Keep URLs from the Issue (runs, logs, docs) as links; do not wrap them in code spans.

## File paths

- Link a repository path you cite as `[path](https://github.com/{owner}/{repo}/blob/{ref}/{path})`; add `#L{start}-L{end}` when you cite specific lines.
- Resolve `{owner}/{repo}` from `GITHUB_REPOSITORY` when set; otherwise run `gh repo view --json nameWithOwner`.
- Use the default branch as `{ref}` unless the Issue or detect JSON names a commit; then pin to that full commit SHA.
- Link a path only when the file exists at that ref; otherwise write it as a code span.

## Not links

- Labels, commands, and tokens (`triage:ready`, `autofix`, `@loop`) stay as code spans.
- Do not invent example `org/repo` URLs; use `<owner>/<repo>` placeholders in prose.
