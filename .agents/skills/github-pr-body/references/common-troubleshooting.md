## PR Overview - Troubleshooting Guide

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

## PR and Comment Issues

### Issue: Comment not created or updated

**Symptom**: Script runs but comment doesn't appear on PR

**Troubleshooting steps**:

1. **Verify PR exists**:
   ```bash
   gh pr view <PR_NUMBER> --repo <OWNER>/<REPO>
   ```

2. **Check if creating vs updating**:
   ```bash
   # Look for existing comment with marker
   gh pr view <PR_NUMBER> \
     --repo <OWNER>/<REPO> \
     --json comments \
     --jq '.comments[] | select(.body | contains("<!-- github-pr-body:v1 -->"))'
   ```

3. **For creation failure**: Verify comment file exists and contains valid markdown
   ```bash
   cat /tmp/pr_overview_comment.md
   ```

4. **For update failure**: Verify comment ID format is correct
   ```bash
   # Should start with IC_kwDO
   echo "$COMMENT_ID"
   ```

---

### Issue: GraphQL API returns "Could not resolve to a node"

**Symptom**:
```
GraphQL error: Could not resolve to a node with global ID of type 'IssueComment': IC_...
```

**Cause**: ID format mismatch or incorrect ID extraction

**Solution**:

| Scenario            | Check                       | Fix                                              |
| ------------------- | --------------------------- | ------------------------------------------------ |
| Updating comment    | ID format is `IC_kwDO...`   | Re-extract ID using `gh pr view --json comments` |
| Updating PR body    | ID format is `PR_kwDO...`   | Re-extract ID using `gh pr view --json id`       |
| Old/deleted comment | Comment ID no longer exists | Create new comment instead of updating           |

**Verification**:
```bash
# Extract and verify comment ID
COMMENT_ID=$(gh pr view 123 --repo owner/repo --json comments \
  --jq '.comments[] | select(.body | contains("<!-- github-pr-body:v1 -->")) | .id')

# Must start with IC_
echo "$COMMENT_ID"
# Expected: IC_kwDO...

# Extract and verify PR ID
PR_ID=$(gh pr view 123 --repo owner/repo --json id --jq '.id')

# Must start with PR_
echo "$PR_ID"
# Expected: PR_kwDO...
```

---

### Issue: Comment created but with old content

**Symptom**: Comment appears but shows outdated summary of changes

**Cause**: Comment was created with stale PR diff

**Solution**:
1. Wait for GitHub to update PR commit info (usually 1-2 seconds)
2. Manually trigger script re-run: `bash scripts/pr-overview-update.sh <PR_NUMBER>`
3. Verify new changes were committed to PR before running

---

## Token & Escaping Issues

### Issue: Special characters breaking GraphQL mutation

**Symptom**:
```
GraphQL parse error: Syntax Error in ""
```

**Cause**: Unescaped quotes, newlines, or special characters in comment body

**Solution**: Use proper bash escaping in helper functions

```bash
# ❌ WRONG - Raw variable interpolation
body_text="This is a "quoted" value"

# ✅ CORRECT - Use @ prefix for file-based input
BODY=$(cat /tmp/comment.md)  # Load from file, properly escaped
gh api graphql -f body="$BODY" ...

# Or use printf for variable escaping
body_text=$(printf '%s\n' 'This is a "quoted" value')
```

---

### Issue: Marker not preserved in comment

**Symptom**: `<!-- github-pr-body:v1 -->` marker disappears after manual edit or update

**Cause**: Manual editing removed marker or update operation didn't preserve it

**Solution**:
- **For updates**: Always ensure marker is first line of new comment body
- **For manual edits**: Keep marker at top of comment
- **For recovery**: If marker lost, search PR comments for agent-generated content by date/time

---

## PR Size Issues

### Issue: PR too large (1000+ files)

**Symptom**: Script times out or produces extremely long comment

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
- [category-command-reference.md](category-command-reference.md) - GraphQL mutation reference
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

### Error: "Failed to create comment" or "Failed to update comment"

**Symptom**:
```
ERROR: Failed to create comment
ERROR: Failed to update comment
```

**Possible causes**:
- GitHub API failure
- Missing or invalid comment file
- GraphQL mutation error
- Network connectivity issue

**Troubleshooting**:
1. Check GitHub status: `gh status`
2. Verify authentication: `gh auth status`
3. Run with verbose output: `./pr_body.sh 123 -v --dry-run`
4. Check temporary file:
   ```bash
   ls -la /tmp/pr_overview_comment_*.md
   ```
5. Inspect GraphQL response for error details (enable verbose)

---

### Other common execution issues

| Issue                    | Symptoms                | Solution                        |
| ------------------------ | ----------------------- | ------------------------------- |
| Missing `gh` CLI         | `command not found: gh` | Install: https://cli.github.com |
| Missing `jq`             | `command not found: jq` | Install: `apt install jq`       |
| No GitHub authentication | Authentication errors   | Run: `gh auth login`            |
| Dry-run mode active      | Changes not applied     | Remove `--dry-run` flag         |
| Insufficient permissions | "Access Denied" errors  | Request repository write access |
