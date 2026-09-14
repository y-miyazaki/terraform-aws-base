# Anti-Patterns (AP)

**AP-01 (MUST): Echoing or logging secrets**

Check: Are `${{ secrets.* }}` values printed to logs, artifacts, or step outputs (SEC-01)?
Why: Workflow logs and artifacts are widely visible; secret echo causes credential leaks
Fix: Reference secrets only in `env`/`with` inputs; never `echo` or upload secret values

**AP-02 (MUST): pull_request_target on untrusted fork PRs without guards**

Check: Does `pull_request_target` run privileged steps on fork PRs without access restrictions (SEC-02)?
Why: Base-repo secrets and write permissions are exposed to untrusted fork code
Fix: Use `pull_request` for forks, or gate privileged steps on trusted actor/repo context

**AP-03 (SHOULD): Floating third-party action tags**

Check: Are third-party actions pinned only to a moving tag (for example `@v4`) without SHA pinning?
Why: Tags can be retargeted; compromised actions run with workflow permissions
Fix: Pin actions to full commit SHA; document exceptions in a comment

**AP-04 (SHOULD): Overly broad workflow permissions**

Check: Does `permissions` grant `write-all` or unnecessary `write` scopes at workflow level?
Why: Excess permissions amplify impact when a step or action is compromised
Fix: Set least-privilege `permissions` per job; add writes only where required

**AP-05 (SHOULD): Passing untrusted PR input directly to shell**

Check: Are PR titles, bodies, branch names, or `workflow_dispatch` inputs interpolated into shell without sanitization (SEC-04)?
Why: Untrusted input in `run:` scripts enables injection and exfiltration
Fix: Pass through environment variables with validation, or use structured `with:` inputs — not raw shell expansion
