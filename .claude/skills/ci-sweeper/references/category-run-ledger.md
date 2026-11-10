# Previously processed runs

Detect may place skipped runs in `ignored[]` when a caller-configured ledger marks them done. The skill:

- Notes non-empty `ignored[]` in Overview
- Does **not** re-apply ledger skip or REJECT-retry policy
- Does **not** require a product-specific ledger path

Ledger path, retry policy, and persistence are caller concerns. The bundled scripts read them from `CI_SWEEPER_LEDGER_FILE`, `CI_SWEEPER_REJECT_RETRY_POLICY`, and `CI_SWEEPER_REJECT_MAX_RETRIES`; each has a script default, and callers override it as needed. Do not assume a fixed ledger location.
