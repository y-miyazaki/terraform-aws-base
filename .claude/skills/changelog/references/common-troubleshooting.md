# Troubleshooting

- **`skip` true or empty `commits` and `releases`:** Emit report with Summary `No unreleased changelog commits`; do not edit `changelog_file`.
- **`changelog_exists` false and `agent_edit_allowed` is `true`:** Create Keep a Changelog template before adding bullets (see `common-checklist.md`).
- **`changelog_exists` false and `agent_edit_allowed` is `false`:** Survey only — note that template creation requires an explicit fix request or `agent_edit_allowed: true`.
- **Malformed existing changelog:** Preserve released sections; fix only `## [Unreleased]` and new detect `releases[]` sections when edits are allowed.
- **Missing `repository_url` or `compare_url`:** Omit commit links and compare line; use subject-only bullets.
