# Troubleshooting

On failure, apply the matching row in SKILL.md **Error Handling**. Common cases:

- Detect `status: "error"` or non-zero exit → stop; do not treat as success-path JSON
- Empty/`skip` hints or zero candidates → no-op report
- Gate failure for one candidate → revert that edit; **Deferred**; continue remaining candidates
- Architecture without `approved_slice` → proposal only; stop before Phase B
