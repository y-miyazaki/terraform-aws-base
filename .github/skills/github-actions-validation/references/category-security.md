## GitHub Actions Validation - Security Remediation Guide

Use this guide when `ghalint` or `zizmor` reports security findings.

## Common Findings and Fixes

### Overly Broad Permissions

**Typical finding**:
- Missing `permissions` block
- Write permissions granted globally without need

**Fix**:

```yaml
permissions:
  contents: read

jobs:
  release:
    permissions:
      contents: write
      packages: write
```

Set minimal workflow-level permissions, then elevate per job only when required.

### Unpinned Third-Party Actions

**Typical finding**:
- `uses: org/action@vX` without SHA pinning

**Fix**:

```yaml
- uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2
```

Pin third-party actions to full commit SHA and optionally keep the version comment for readability.

### Unsafe pull_request_target Usage

**Typical finding**:
- `pull_request_target` workflow runs untrusted fork code with privileged token or secrets

**Fix**:

```yaml
on:
  pull_request_target:
    types: [opened, synchronize, reopened]

jobs:
  safe-metadata-check:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: read
    steps:
      - name: Validate metadata only
        run: echo "No checkout of fork code in privileged context"
```

Avoid checking out and executing fork code in privileged `pull_request_target` jobs.

### Secret Exposure in Logs

**Typical finding**:
- Secret-like values echoed in `run` steps
- Tokens passed via command-line arguments and printed

**Fix**:

```yaml
env:
  API_TOKEN: ${{ secrets.API_TOKEN }}

steps:
  - name: Call API safely
    run: |
      curl -sSf -H "Authorization: Bearer $API_TOKEN" https://example.invalid/api
```

Never print secrets and avoid debugging flags that dump full environment values.

### Missing Timeouts

**Typical finding**:
- Job or step can hang indefinitely

**Fix**:

```yaml
jobs:
  build:
    timeout-minutes: 30
    steps:
      - name: Test
        timeout-minutes: 10
        run: npm test
```

## Revalidation Commands

After applying fixes, rerun the standard validation script:

```bash
bash github-actions-validation/scripts/validate.sh
```

For targeted checks:

```bash
bash github-actions-validation/scripts/validate.sh ./.github/workflows/
```

## Escalation Rule

- Do not merge workflows with unresolved high-risk `zizmor` findings.
- If an exception is required, document justification and compensating controls in PR review.
