## Implementation Details

Technical implementation and design decisions for the PR Body update system.

---

## Body Update Mechanism

### Section Replacement Strategy

The script uses **idempotent section replacement** without markers:

1. **Identifies sections** by regex: `/^## (Overview|Changes)$/`
2. **Replaces** entire section from header to next H2 section header
3. **Preserves** all other H2 sections (except `## Overview` and `## Changes`)
4. **Safe for re-runs**: Multiple runs produce identical results
5. **Template-tolerant**: Works regardless of section order in template

### Template Structure

**Before Update**:
```markdown
## Overview
[Manual content or auto-generated from previous run]

## Changes
[Manual content or auto-generated from previous run]

## Related Issues
- #456
- #789

## Testing
- Tested locally with `npm test`

## Type of Change
- [ ] Bug fix
- [x] New feature
```

**After Update**:
```markdown
## Overview
[New auto-generated content]

## Changes
[New auto-generated file list]

## Related Issues
- #456
- #789

## Testing
- Tested locally with `npm test`

## Type of Change
- [ ] Bug fix
- [x] New feature
```

**Key Point**: All H2 sections except `## Overview` and `## Changes` are preserved exactly, regardless of their position in PR Body.

---

## File Classification

### Supported Categories

Files are classified into one of 6 categories based on name patterns:

| Category | Pattern                                          | Examples                                   |
| -------- | ------------------------------------------------ | ------------------------------------------ |
| Config   | `*.yml`, `*.yaml`, `*.tf`, `Dockerfile`, `*.hcl` | `deployment.yaml`, `main.tf`, `Dockerfile` |
| Docs     | `*.md`, `*.rst`, `docs/`                         | `README.md`, `CHANGELOG.md`                |
| Feature  | Application code (not test/config/docs)          | `src/app.js`, `pkg/service.go`             |
| Test     | `_test.go`, `test_*.py`, `*.test.js`             | `handler_test.go`, `test_utils.py`         |
| Other    | Everything else                                  | `LICENSE`, `.gitignore`                    |

### Statistics Tracking

For each file:
- **Additions**: `+N` (number of added lines)
- **Deletions**: `-N` (number of removed lines)
- **Total change**: Addition and deletion counts

### Large PR Handling

For PRs with 100+ files:
- **Grouping**: Files grouped by category
- **Pagination**: All files fetched via paginated API calls
- **Summary**: Total count provided to keep body readable

---

## API Operations

### GitHub API Calls

| Operation      | Method      | Endpoint                                         | Purpose                                          |
| -------------- | ----------- | ------------------------------------------------ | ------------------------------------------------ |
| Fetch PR       | REST        | `GET /repos/{owner}/{repo}/pulls/{number}`       | Retrieve PR metadata (title/body/stats/branches) |
| Fetch PR Files | REST        | `GET /repos/{owner}/{repo}/pulls/{number}/files` | Retrieve full file list with pagination          |
| Update Body    | REST        | `PATCH /repos/{owner}/{repo}/pulls/{number}`     | Update PR description field                      |
| Parse Template | Local regex | N/A                                              | Extract sections from PULL_REQUEST_TEMPLATE.md   |

### Rate Limiting

- **Authenticated**: 5,000 requests/hour per user
- **Unauthenticated**: 60 requests/hour
- **Typical PR**: 2-3 API calls (fetch metadata, fetch files, update body)

### Error Handling

| Error                 | HTTP Status | Recovery                                          |
| --------------------- | ----------- | ------------------------------------------------- |
| PR not found          | 404         | Verify PR number and repository                   |
| Authentication failed | 401         | Re-authenticate with `gh auth login`              |
| Access denied         | 403         | Verify user has `repo:write` scope                |
| Body too large        | 422         | Reduce body size or split into multiple PRs       |
| Rate limit exceeded   | 429         | Wait 1 hour or use GitHub token with higher limit |

---

## Performance Characteristics

### Typical Execution Time

- **Small PR** (< 10 files): ~2-3 seconds
- **Medium PR** (10-50 files): ~3-5 seconds
- **Large PR** (50-100 files): ~5-10 seconds
- **Very large PR** (100+ files): ~10-20 seconds

### Bottlenecks

1. **Network latency**: GitHub API calls (~0.5-1s each)
2. **Parsing**: Regex extraction of file list (~0.2s)
3. **Generation**: Building markdown output (~0.1s)

### Optimization

- **Caching**: No caching (PR always fetched fresh)
- **Batch operations**: Single API call fetches PR + files together
- **Minimal processing**: Simple regex patterns, no heavy computation

---

## Idempotency Guarantee

### Why Multiple Runs Produce Identical Results

1. **Deterministic metadata**: GitHub PR info always the same for given PR# + commit SHA
2. **Deterministic classification**: File patterns always produce same category
3. **Deterministic formatting**: Output always follows same template format
4. **No markers needed**: Section replacement by header, not by comment markers

### Test Case

```bash
# Run 1
pr_body.sh 123 --repo owner/repo
# Result: Body updated with auto-generated sections

# Run 2 (same PR, same commits)
pr_body.sh 123 --repo owner/repo
# Result: Identical content (verified by checksum)
```

---

## Design Constraints

### Why Body Update (Not Comments)

**Alternatives Considered**:
1. PR Comments: Harder to maintain, requires markers, difficult to track multiple versions
2. Status Checks: Not suitable for human-readable information
3. Labels: Too limited for detailed change information

**Selected Approach (Body Update)**:
- PR Body is the primary documentation location
- Authors already customizing Body sections
- Idempotent without markers
- Easier for manual refinement post-generation

### Why No Third-Party Tools

**Constraints**:
- Must work in GitHub-only environments (no additional dependencies)
- Must use only `gh` CLI (standard GitHub tool)
- Must support Japanese and multi-language enhancements
- Must be deterministic and repeatable

---

## Limitations

1. **PR Template Required**: Expects `.github/PULL_REQUEST_TEMPLATE.md` for context
2. **GitHub API Dependency**: Requires internet access and GitHub authentication
3. **Body Size Limit**: GitHub enforces 65,536 character limit
4. **File Name Only**: Classification based on file name patterns, not content inspection
5. **No CI/CD State**: Does not integrate with CI/CD build status or test results

---

## Future Enhancements

Potential improvements (not currently implemented):

- **CI/CD Integration**: Include build status, test coverage, deployment info
- **Content-Based Classification**: Analyze file content for better categorization
- **Multi-Language Templates**: Support organization-specific PR template variations
- **Custom Categories**: Allow users to define custom file classification rules
- **Analytics**: Track PR metrics over time (files changed, review time, etc.)
