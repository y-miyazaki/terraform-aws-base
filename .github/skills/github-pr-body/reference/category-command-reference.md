## Command Reference

Complete reference for scripts in the github-pr-body skill.

---

## Script Overview

| Script        | Purpose                                     | When to Use                                 |
| ------------- | ------------------------------------------- | ------------------------------------------- |
| `pr_fetch.sh` | Fetch and analyze PR data                   | Always first - consolidates data collection |
| `pr_body.sh`  | Update PR Body with auto-generated sections | After analysis, for automatic Body updates  |

---

## pr_fetch.sh - PR Data Analysis

### Basic Command

```bash
# Fetch PR metadata, file classifications, and template sections
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR#> --repo owner/repo
```

### Options

```bash
# Output in JSON format (default)
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR#> --repo owner/repo --format json

# Output in YAML format
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR#> --repo owner/repo --format yaml

# Auto-detect repo from git remote (no --repo needed)
.github/skills/github-pr-body/scripts/pr_fetch.sh <PR#>

# Help message
.github/skills/github-pr-body/scripts/pr_fetch.sh --help
```

### Parameters

| Parameter  | Required | Format       | Description                                                            |
| ---------- | -------- | ------------ | ---------------------------------------------------------------------- |
| `<PR#>`    | Yes      | Numeric      | GitHub PR number (e.g., `123`)                                         |
| `--repo`   | No*      | `owner/repo` | Repository in GitHub format. Auto-detected from git remote if omitted. |
| `--format` | No       | `json\|yaml` | Output format (default: `json`). Recommended: `json` for parsing       |

*Auto-detected from git remote if not provided.

### Output Structure

```json
{
  "metadata": {
    "title": "PR title",
    "body": "PR body content",
    "additions": 100,
    "deletions": 50,
    "files": [...],
    "state": "OPEN",
    "baseRefName": "main",
    "headRefName": "feature-branch"
  },
  "template": {
    "overview": "Existing or empty",
    "changes": "Existing or empty",
    "type_of_change": "Existing or empty"
  },
  "classified_files": [
    {
      "type": "Config",
      "files": [
        {"path": "terraform/main.tf", "additions": 50, "deletions": 10},
        {"path": ".github/workflows/deploy.yaml", "additions": 20, "deletions": 5}
      ]
    },
    {
      "type": "Docs",
      "files": [
        {"path": "README.md", "additions": 30, "deletions": 5}
      ]
    }
  ]
}
```

### Usage Examples

**Example 1: Analyze PR and print summary**
```bash
.github/skills/github-pr-body/scripts/pr_fetch.sh 311 --repo owner/repo \\
  | jq '.classified_files | map({type, count: (.files | length), additions: (.files | map(.additions) | add)})'

# Output:
# [
#   {"type": "Config", "count": 20, "additions": 1282},
#   {"type": "Docs", "count": 63, "additions": 3151}
# ]
```

**Example 2: Extract Terraform changes**
```bash
.github/skills/github-pr-body/scripts/pr_fetch.sh 311 --repo owner/repo \\
  | jq '.classified_files[] | select(.type == "Config") | .files[] | select(.path | contains("terraform"))'
```

**Example 3: Save analysis for later processing**
```bash
.github/skills/github-pr-body/scripts/pr_fetch.sh 311 --repo owner/repo > pr_analysis.json
# Use pr_analysis.json for downstream processing or manual refinement
```

### Exit Codes

| Code | Meaning          | Action                                  |
| ---- | ---------------- | --------------------------------------- |
| `0`  | Success          | Data fetched and output to stdout       |
| `1`  | Validation Error | PR not found, missing deps, auth issues |

---

## pr_body.sh - PR Body Update

### Basic Command

```bash
# Update PR Body with auto-generated sections
.github/skills/github-pr-body/scripts/pr_body.sh <PR#> --repo owner/repo
```

### Options

```bash
# Preview changes before applying (dry-run mode)
.github/skills/github-pr-body/scripts/pr_body.sh <PR#> --repo owner/repo --dry-run

# Verbose output for debugging
.github/skills/github-pr-body/scripts/pr_body.sh <PR#> --repo owner/repo --verbose

# Auto-detect repo from git remote (no --repo needed)
.github/skills/github-pr-body/scripts/pr_body.sh <PR#>
```

### Parameters for pr_body.sh

| Parameter         | Required | Format       | Description                                                                 |
| ----------------- | -------- | ------------ | --------------------------------------------------------------------------- |
| `<PR#>`           | Yes      | Numeric      | GitHub PR number (e.g., `123`)                                              |
| `--repo`          | No*      | `owner/repo` | Repository in GitHub format. Auto-detected from git remote if omitted.      |
| `--overview-file` | No       | File path    | Path to AI-generated Overview content file. If omitted, generates baseline. |
| `--dry-run`       | No       | Flag         | Preview changes without applying. Useful for verification before execution. |
| `--verbose`       | No       | Flag         | Enable SCRIPT_VERBOSE=1 for debugging output.                               |

*Auto-detected from git remote if not provided.

### Exit Codes for pr_body.sh

| Code | Meaning          | Action                                                                  |
| ---- | ---------------- | ----------------------------------------------------------------------- |
| `0`  | Success          | Body updated successfully OR --dry-run preview shown                    |
| `1`  | Validation Error | PR not found, missing deps, auth issues, etc. Check output for details. |

### Error: `PR #XXX not found`

**Cause**: PR number doesn't exist in repository or wrong repository specified

**Recovery**:
1. Verify PR number is correct: `gh pr list --repo owner/repo`
2. Verify repository format: Use `owner/repo` (not `owner-repo`, not full URL)
3. Verify repository access: `gh repo view owner/repo`

### Error: `auth required` or `authentication failed`

**Cause**: `gh` CLI not authenticated or missing `repo:write` scope

**Recovery**:
1. Authenticate: `gh auth login`
2. Select "GitHub.com" for hostname
3. Select "HTTPS" for protocol
4. Select "Y" for git operations via HTTPS
5. Authorize with `repo:write` scope when prompted

### Error: `jq: command not found`

**Cause**: Missing `jq` JSON processor dependency

**Recovery**
```bash
# Debian/Ubuntu
sudo apt-get install -y jq

# macOS
brew install jq

# Verify installation
jq --version
```

### Error: `PULL_REQUEST_TEMPLATE.md not found`

**Cause**: Repository doesn't have PR template

**Recovery**:
1. Create template at `.github/PULL_REQUEST_TEMPLATE.md`
2. Or run script in location with existing template
3. Or provide template structure before running

### Error: `could not write to PR: 422`

**Cause**: PR Body content too large or malformed (GitHub API limit)

**Recovery**:
1. Check body size: Should be < 65,536 characters
2. Run with `--verbose` to see generated content size
3. Split large changes into separate PRs if needed

---

## Debugging Workflow

### Enable Verbose Output

```bash
# See detailed execution steps
.github/skills/github-pr-body/scripts/pr_body.sh 123 --repo owner/repo --verbose 2>&1 | tee debug.log
```

### Dry-Run First

```bash
# Preview exactly what will be changed
.github/skills/github-pr-body/scripts/pr_body.sh 123 --repo owner/repo --dry-run
```

### Check Current PR State

```bash
# View current PR Body
gh pr view 123 --repo owner/repo --json body --jq '.body'

# Count current body size
gh pr view 123 --repo owner/repo --json body --jq '.body' | wc -c
```

### Manual PR Body Edit

```bash
# Edit body in local editor
gh pr edit 123 --repo owner/repo --body-file /path/to/body.md
```

---

## Environment Variables

### Script-Internal Variables

These are set automatically; do not need manual configuration:

```bash
SCRIPT_VERBOSE=1          # Enable debug output (use --verbose flag)
SCRIPT_DIR                # Directory of script (auto-set)
PR_NUMBER                 # PR number parsed from arguments
REPOSITORY                # Repository in owner/repo format
DRY_RUN                   # Set to "true" if --dry-run used
TMP_FILES                 # Array of temp files for cleanup
```

### System Requirements

- `bash` >= 4.0
- `gh` CLI >= 2.0 (with `repo:write` scope)
- `jq` >= 1.6
- `git` (for auto-detecting repository)
- Internet access (GitHub API)
