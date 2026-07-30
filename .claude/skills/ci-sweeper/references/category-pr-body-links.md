## PR body links (file paths)

Apply at synthesis when emitting Summary tables in automation PR bodies.

### File paths

- Link repository paths as `[path](https://github.com/{owner}/{repo}/blob/{branch}/{path})`.
- Use the **current git branch** (fix branch with your edits), not the default branch.
- Resolve `owner/repo` from `GITHUB_REPOSITORY` when set; otherwise parse `git remote get-url origin`.

### Template placeholders (skill assets)

- Use backtick placeholders in `assets/pr-body-template*.md` and `references/common-output-format*.md` (for example `` `docs/foo.md` ``).
- **Do not** embed example markdown links such as `https://github.com/org/repo/...` — they fail markdown-link-check with 404.

## PR body links (ci-sweeper)

Apply at synthesis. Also follow file-path rules in this file's **File paths** section above.

### Workflow / job rows

When detect `failures[]` is present:

| Field                | Link target                                                      |
| -------------------- | ---------------------------------------------------------------- |
| `workflow_path`      | `https://github.com/{owner}/{repo}/actions/workflows/{basename}` |
| `job_url`            | use as-is when set                                               |
| `job_id` + `run_url` | `{run_url}/job/{job_id}` when `job_url` is absent                |
| fallback             | `run_url` for workflow or job label                              |

Do not duplicate `## Failure context` run URLs in Overview when the caller already supplies that section.
