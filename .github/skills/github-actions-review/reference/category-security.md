## 4. Security (SEC)

**SEC-01: Explicit Top-Level Permissions**

Check: Are top-level permissions explicitly set?
Why: Missing or excessive permissions grant unnecessary access to GITHUB_TOKEN, increasing potential damage during security breaches (unauthorized repository modifications, secret exposure, etc.)
Fix: Explicitly set minimal permissions at top level (e.g., `contents: read`)

**SEC-02: Safe Secret References**

Check: Are secrets referenced only via `${{ secrets.NAME }}` and not directly output?
Why: Improper secret handling (direct output, etc.) causes leaks via logs/artifacts
Fix: Use only `${{ secrets.NAME }}`, prohibit log output, mask when necessary

**SEC-03: Careful Use of pull_request_target**

Check: Are fork PR restrictions in place when using `pull_request_target`?
Why: `pull_request_target` runs with write permissions and access to secrets in the context of the base repository, allowing malicious fork PRs to exfiltrate secrets or modify repository contents
Fix: Use `pull_request` for fork PRs, or implement conditional access restrictions

**SEC-04: Log Masking for Sensitive Information**

Check: Are sensitive values masked with `::add-mask::` or `core.setSecret()`?
Why: Sensitive value log exposure risks information leaks
Fix: Mask logs with `core.setSecret()`/`::add-mask::`

**SEC-05: Pin Third-Party Actions**

Check: Are critical actions pinned to SHA?
Why: Using mutable tags (e.g., `@v1`, `@main`) for third-party actions creates supply chain attack vectors where compromised action repositories can inject malicious code into workflows
Fix: Pin critical actions to full SHA (e.g., `actions/checkout@a81bbbf8298c0fa03ea29cdc473d45769f953675`), monitor with Dependabot

**SEC-06: Sanitize Environment Variables**

Check: Are environment variable inputs validated and sanitized?
Why: Unvalidated environment variable inputs risk injection, information leaks
Fix: Validate and sanitize inputs, prohibit direct shell passing of PR values

**SEC-07: Guardrails for Public Repositories**

Check: Do public repositories have conditional branches like `github.event.repository.private`?
Why: Public repositories allow anyone to fork and submit PRs, potentially exposing secrets or triggering unintended workflows without proper access controls
Fix: Add conditional branches with `github.event.repository.private`, restrict usage
