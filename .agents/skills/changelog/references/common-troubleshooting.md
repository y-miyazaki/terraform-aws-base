## Troubleshooting

- **`skip` true or empty `commits` and `releases`:** Emit report with Summary `No unreleased changelog commits`; do not edit `changelog_file`.
- **`changelog_exists` false:** Create Keep a Changelog template before adding bullets (see `common-checklist.md`).
- **Malformed existing changelog:** Preserve released sections; fix only `## [Unreleased]` and new detect `releases[]` sections.
- **Missing `repository_url` or `compare_url`:** Omit commit links and compare line; use subject-only bullets.
