## Security (SEC)

**SEC-01 (SHOULD): Safe Secret References**

Check: Are secrets referenced only via `${{ secrets.NAME }}` and not directly output?
Why: Improper secret handling (direct output, etc.) causes leaks via logs/artifacts
Fix: Use only `${{ secrets.NAME }}`, prohibit log output, mask when necessary

**SEC-02 (SHOULD): Careful Use of pull_request_target**

Check: Are fork PR restrictions in place when using `pull_request_target`?
Why: `pull_request_target` runs with write permissions and access to secrets in the context of the base repository, allowing malicious fork PRs to exfiltrate secrets or modify repository contents
Fix: Use `pull_request` for fork PRs, or implement conditional access restrictions

**SEC-03 (SHOULD): Log Masking for Sensitive Information**

Check: Are sensitive values masked with `::add-mask::` or `core.setSecret()`?
Why: Sensitive value log exposure risks information leaks
Fix: Mask logs with `core.setSecret()`/`::add-mask::`

**SEC-04 (SHOULD): Sanitize Environment Variables**

Check: Are environment variable inputs validated and sanitized?
Why: Unvalidated environment variable inputs risk injection, information leaks
Fix: Validate and sanitize inputs, prohibit direct shell passing of PR values
Note: Apply only to untrusted (external) inputs — values from PR titles/bodies, issue comments, branch names, or user-controlled workflow_dispatch inputs. Internally generated values (step outputs from prior controlled steps in the same workflow) are trusted and do not require sanitization.

**SEC-05 (SHOULD): Guardrails for Public Repositories**

Check: Do public repositories have conditional branches like `github.event.repository.private`?
Why: Public repositories allow anyone to fork and submit PRs, potentially exposing secrets or triggering unintended workflows without proper access controls
Fix: Add conditional branches with `github.event.repository.private`, restrict usage
