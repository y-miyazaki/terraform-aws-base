# Troubleshooting

- If evidence is partial, mark affected checks as deferred with explicit reason.
- If PR context is unavailable, review file diffs only and defer PR-context-dependent checks.
- If changed files contain no `.tf` or `.tfvars`, return `status: skipped` with reason `no Terraform review target`.
- If a referenced category file is missing, defer affected checks and note the missing file path.
