# Anti-Patterns (AP)

When an AP item cites a base ItemID in parentheses, report the finding once under the base ItemID (the first one listed when several are cited); the AP item is a lookup pointer, not a second finding.

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
Note: `zizmor` reports unpinned `uses:` references. When validation output is supplied, take this ItemID's status from zizmor and cite it; still evaluate whether a documented exception comment justifies a tag pin.

**AP-04 (SHOULD): Overly broad workflow permissions**

Check: Is `permissions` missing (so the repository default token scope applies), or does it grant `write-all` or unnecessary `write` scopes at workflow level?
Why: Excess permissions amplify impact when a step or action is compromised
Fix: Set least-privilege `permissions` per job; add writes only where required
Note: `ghalint` and `zizmor` report missing or overly broad `permissions` declarations (for example `write-all`). When validation output is supplied, take the status of those findings from the tools and cite them; still evaluate whether each granted `write` scope is needed by the job, which the tools cannot judge.

**AP-05 (SHOULD): Passing untrusted PR input directly to shell**

Check: Are PR titles, bodies, branch names, or `workflow_dispatch` inputs interpolated into shell without sanitization (SEC-04)?
Why: Untrusted input in `run:` scripts enables injection and exfiltration
Fix: Pass through environment variables with validation, or use structured `with:` inputs — not raw shell expansion
Note: `zizmor` reports template injection of `${{ }}` expressions into `run:`. When validation output is supplied, take the status of those findings from zizmor and cite it; still evaluate untrusted values that reach the shell through other paths (for example unvalidated `env` values or script arguments).
