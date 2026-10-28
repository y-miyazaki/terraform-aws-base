# PR body links (changelog)

Apply at synthesis when emitting Summary tables and Overview.

- Link commit SHAs to `https://github.com/{owner}/{repo}/commit/{sha}` when `repository_url` is available.
- Link commit ranges in Overview when detect supplies `compare_url`.

## Template placeholders

- Templates mark SHAs with `<linked sha>`; never put example `https://github.com/org/repo/...` markdown links in templates.
