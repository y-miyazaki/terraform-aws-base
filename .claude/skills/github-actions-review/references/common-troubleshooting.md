# Troubleshooting

- If evidence is partial, mark affected checks as deferred with explicit reason.
- If PR contains no workflow YAML files, set `Status: skipped` in `## Checks Summary` with reason `no reviewable workflows`.
- If workflow YAML is malformed, report syntax-related review checks as deferred and keep policy/design findings separate.
