# PR Body - Troubleshooting Guide

## ⚠️ Common Issues & Solutions

---

## GitHub CLI Issues

### Issue: `gh` command not found

**Symptom**: Error when running PR overview scripts

```
command not found: gh
```

**Solution**:

1. Verify GitHub CLI is installed: `gh --version`
2. Install if needed: [https://cli.github.com](https://cli.github.com)
3. Authenticate: `gh auth login`

---

### Issue: Authentication error

**Symptom**:

```
API error: 401 Unauthorized
gh: failed to run `api graphql`: GraphQL error:
```

**Solution**:

```bash
# Check authentication status
gh auth status

# Re-authenticate with required scopes
gh auth login --scopes repo:write,read:issue

# Verify repo:write scope is included
gh auth status --show-token
```

---

### Issue: Permission denied on repository

**Symptom**:

```
GraphQL error: Access Denied
```

**Solution**:

- Verify you have write access to the repository
- Ask repository maintainer for `push` or `admin` access
- If using personal access token: Add `repo:write` scope via `gh auth login`

---

## PR Size Issues

### Issue: PR too large (1000+ files)

**Symptom**: Script times out or produces an extremely long PR body

**Best Practice**:

1. For large refactoring PRs: Summarize by directory/module instead of per-file
2. Example changes section:

```markdown
### Refactoring (15 modules affected)

**cmd/** - Updated command-line argument parsing
**pkg/auth/** - Consolidated authentication logic into new package
**pkg/utils/** - Moved shared utilities from multiple files

[See PR diff for detailed file-by-file changes]
```

---

## Template Processing Issues

### Issue: Template not detected or incorrectly mapped

**Symptom**: Comment format doesn't match repository's PULL_REQUEST_TEMPLATE.md structure

**Debug steps**:

1. **Verify template location**:

   ```bash
   find . -name "PULL_REQUEST_TEMPLATE.md" -o -name "pull_request_template.md"
   ```

2. **Check template content**:

   ```bash
   cat .github/PULL_REQUEST_TEMPLATE.md
   ```

3. **Verify template is being parsed**:
   - Check script logs for template loading messages
   - Manually inspect PR description for template sections

---

## Rate Limiting

### Issue: GitHub API rate limit exceeded

**Symptom**:

```
GraphQL error: API rate limit exceeded
```

**Solution**:

1. Check rate limit status: `gh api rate_limit`
2. Wait for rate limit reset (usually 1 hour)
3. For scripts: Add delay between API calls
4. Increase limit by authenticating: `gh auth login`

**Rate Limit Info**:

- Authenticated requests: 5,000/hour
- Unauthenticated: 60/hour

---

## Performance Issues

### Issue: Script takes too long to analyze PR

**Symptoms**:

- Script runs for >30 seconds
- PR has many files (>200)

**Solutions**:

1. For initial PR: May be slow first time; subsequent updates faster
2. For large PRs: Focus on core modules; skip exhaustive analysis
3. Check network: Verify responsive GitHub API
4. Use scoped analysis: Run on specific file changes only

---

## Reference

**When scripts reference helper functions**:

- [category-command-reference.md](category-command-reference.md) - `pr_fetch.sh` / `pr_body.sh` options, parameters, exit codes, and debugging steps
- [category-template-mapping.md](category-template-mapping.md) - Template structure mapping
- [category-change-classification.md](category-change-classification.md) - Change type classification

---

## pr_body.sh Script - Specific Errors

### Error: "PR #XXX not found in OWNER/REPO"

**Symptom**:

```
ERROR: PR #123 not found in owner/repo
```

**Causes**:

- PR number is incorrect
- Repository name or owner is wrong
- PR has been deleted
- You don't have access to the repository

**Solutions**:

1. Verify PR number: `gh pr view <NUMBER> --repo <OWNER>/<REPO>`
2. Check repository name: `git remote -v`
3. Verify access: `gh repo view <OWNER>/<REPO>`
4. Explicitly specify repository: `./pr_body.sh 123 --repo owner/repo`

---

### Error: "Could not determine repository. Use --repo OWNER/REPO"

**Symptom**:

```
ERROR: Could not determine repository. Use --repo OWNER/REPO
```

**Causes**:

- No git remote origin configured
- Git remote URL has non-standard format
- Not running from repository directory

**Solutions**:

1. Check git remote setup:

   ```bash
   git remote -v
   # Should output: origin  https://github.com/owner/repo.git (fetch)
   ```

2. Manually specify repository:

   ```bash
   ./pr_body.sh 123 --repo owner/repo
   ```

3. Fix git remote if needed:
   ```bash
   git remote set-url origin https://github.com/owner/repo.git
   ```

---

### Error: "Invalid argument: XXX"

**Symptom**:

```
ERROR: Invalid argument: invalid-arg
```

**Cause**: Invalid option or argument passed to script

**Solutions**:

1. Check allowed options: `./pr_body.sh -h`
2. PR_NUMBER must be numeric: `./pr_body.sh 123` (not `PR-123`)
3. Repository format: `--repo owner/repo` (with forward slash)
4. Valid flags: `--verbose`, `--dry-run`, `--repo`

---

### Error: "PR_NUMBER is required"

**Symptom**:

```
ERROR: PR_NUMBER is required
```

**Solution**:
Specify PR number as first argument:

```bash
./pr_body.sh 123                    # Correct
./pr_body.sh                        # Error: missing PR number
```

---

### Other common execution issues

| Issue                    | Symptoms                | Solution                        |
| ------------------------ | ----------------------- | ------------------------------- |
| Missing `gh` CLI         | `command not found: gh` | Install: https://cli.github.com |
| Missing `jq`             | `command not found: jq` | Install: `apt install jq`       |
| No GitHub authentication | Authentication errors   | Run: `gh auth login`            |
| Dry-run mode active      | Changes not applied     | Remove `--dry-run` flag         |
| Insufficient permissions | "Access Denied" errors  | Request repository write access |
