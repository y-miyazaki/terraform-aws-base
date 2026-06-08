# Overview

<!--
REQUIRED: Why this PR exists and what it achieves. Most important section for reviewers.
Exclude: branch names, file counts, line statistics (visible in GitHub UI).
Do NOT duplicate the file-level detail from ## Changes here.

Format:
[2-4 sentence summary explaining the problem and solution]

- **What**: high-level description of modifications (not file names)
- **Why**: motivation or problem being solved
- **Impact**: deployment risk, breaking changes, or compatibility notes
-->

## Related Issues

<!--
Optional: Link related issues.

Format:
Closes #123, Related to #456
-->

## Changes

<!--
REQUIRED: Technical changes grouped by area.
Include ALL changed files — do not omit files based on perceived importance.

Format:
### [Area Name]
- **[File/Resource]**: description
  - ⚠️ prefix for breaking changes

Example:
### src/auth
- **middleware.ts**: Added JWT validation middleware
  - Validates token expiry and issuer claims
- **types.ts**: New `AuthContext` interface

### .github/workflows
- **ci.yaml**: ⚠️ Renamed `deploy` job to `release`
  - Breaking: Update branch protection rules
-->

## Testing

<!--
Optional: How changes were tested.

Format:
- Local: [steps taken]
- Coverage: [test types run]
- Edge cases: [specific scenarios verified]

Example:
- Local: `make test` — 45 tests pass
- Coverage: Added 2 integration tests for auth flow
- Edge cases: Verified token expiry handling
-->

## Type of Change

<!--
Optional: Check applicable types.

Format:
- [ ] ✨ Feature: New functionality
- [ ] 🐛 Bug Fix: Issue resolution
- [ ] ♻️ Refactor: Code structure improvement
- [ ] 📝 Documentation: Docs/comments update
- [ ] ⚙️ Configuration: Config/build change
- [ ] 🧪 Test: New/updated tests
- [ ] 🚀 Performance: Optimization
- [ ] 🔒 Security: Security-related change
-->

## Checklist

<!--
Optional: Quality checks.

Format:
- [ ] Follows project conventions
- [ ] Tests pass locally
- [ ] Documentation updated (if applicable)
- [ ] Breaking changes documented
-->

## Additional Notes

<!--
Optional: Extra context for reviewers.

Format:
- Dependencies: [added/removed packages]
- Migration: [steps if applicable]
- Deployment: [considerations or prerequisites]
-->
