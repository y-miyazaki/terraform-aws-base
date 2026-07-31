# PR body links (file paths)

Apply at synthesis when emitting Summary tables in automation PR bodies.

## File paths

- Link repository paths as `[path](https://github.com/{owner}/{repo}/blob/{branch}/{path})`.
- Use the **current git branch** (fix branch with your edits), not the default branch.
- Resolve `owner/repo` from `GITHUB_REPOSITORY` when set; otherwise parse `git remote get-url origin`.

## Template placeholders (skill assets)

- Use backtick placeholders in `assets/pr-body-template*.md` and `references/common-output-format*.md` (for example `` `docs/foo.md` ``).
- **Do not** embed example markdown links such as `https://github.com/org/repo/...` — they fail markdown-link-check with 404.
