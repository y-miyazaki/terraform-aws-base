## Change Classification Guide

## Overview

This document provides the decision matrix for classifying code changes by type (Feature, Fix, Refactor, Test, Docs, Config, Perf, Security) and determining their placement in the Changes section.

---

## Classification Matrix

### Decision Tree

```
For each changed file or function:

1. Is it a new file or function?
   ├─ YES → Likely Feature
   │        ├─ Adds user-facing capability? → FEATURE
   │        ├─ Adds internal utility? → FEATURE (internal)
   │        └─ Is it only for tests? → TEST
   │
   └─ NO (existing functionality modified)
      │
      ├─ Does it fix a bug or issue?
      │  ├─ YES → FIX
      │  └─ NO → Continue below
      │
      ├─ Is it a test file (ends with _test.* or test_*)?
      │  ├─ YES → TEST
      │  └─ NO → Continue below
      │
      ├─ Is it documentation (.md, .rst, docs/)?
      │  ├─ YES → DOCS
      │  └─ NO → Continue below
      │
      ├─ Is it configuration (Dockerfile, .yml, .yaml, .tf)?
      │  ├─ YES → CONFIG
      │  └─ NO → Continue below
      │
      ├─ Did it change for performance improvement?
      │  ├─ YES → PERF
      │  └─ NO → Continue below
      │
      ├─ Is it a security-related change?
      │  ├─ YES → SECURITY
      │  └─ NO → REFACTOR

2. Mark breaking changes with ⚠️
```

---

## Change Type Definitions

### Feature
**Definition**: Adds new user-facing or internal functionality.

**Indicators**:
- New function/method definition
- New class or struct definition
- New exported API or public interface
- New configuration option
- Extends existing functionality with new capability

**Examples**:
- ✅ Add `getUserProfile()` API method
- ✅ Create new `AuthGateway` class for authentication
- ✅ Add optional `timeout` parameter to existing function
- ✅ New `terraform/modules/vpc-enhanced/` module

**In Comment**:
```markdown
### Features
- **AuthGateway class**: Request validation and JWT extraction
- **New API endpoint**: `GET /api/v1/users/{id}/profile`
```

---

### Fix
**Definition**: Resolves a bug or reported issue.

**Indicators**:
- Changes logic to correct incorrect behavior
- Removes code that caused a bug
- Updates error handling
- Closes an issue (see PR description or issue tracker)
- Reverts a previous commit that introduced regression

**Examples**:
- ✅ Fix: Handle null pointer in authorization check
- ✅ Fix: Correct date parsing timezone bug
- ✅ Fix: Update IAM policy to grant required permission

**In Comment**:
```markdown
### Fixes
- **Authorization error**: Handle missing auth header gracefully (Closes #456)
- **Date timezone issue**: Parse UTC timestamps correctly in UploadSchedule
```

---

### Refactor
**Definition**: Improves code structure, readability, or organization without changing behavior.

**Indicators**:
- Rename functions, variables, or modules
- Move code to different file/module
- Split large function into smaller functions
- Reorganize conditional logic
- Extract common code into helper function
- Replace deprecated API with newer equivalent

**Examples**:
- ✅ Rename `getUser()` → `fetchUserProfile()`
- ✅ Split `validateAndCreate()` into `validate()` and `create()`
- ✅ Move authentication logic to separate module
- ✅ Update deprecated `ioutil` usage (Go)

**In Comment**:
```markdown
### Refactoring
- **Authentication module**: Extracted from main service into separate package
- **Validation logic**: Split `validateAndCreate()` into 2 functions for clarity
```

---

### Test
**Definition**: Adds or modifies test cases, test utilities, or test configuration.

**Indicators**:
- Files matching `*_test.*`, `test_*.py`, `*.test.ts`, `spec/`, `tests/`
- Test fixtures or mock data files
- Test configuration (.github/workflows/test.yml)
- Coverage improvements without code changes

**Examples**:
- ✅ Add unit tests for `AuthGateway` class
- ✅ Update mocking framework setup
- ✅ Add integration test for Cognito flow

**In Comment**:
```markdown
### Tests
- **AuthGateway**: 15 new unit tests covering edge cases
- **Integration tests**: Added Cognito OAuth flow validation
```

**Note**: If a PR adds both feature and tests, classify separately:
- Feature → Features section (AuthGateway class)
- Tests → Tests section (15 new tests)

---

### Docs
**Definition**: Documentation updates, generated docs, or reference materials.

**Indicators**:
- `.md`, `.rst`, `.txt` files in docs/ or wiki/
- README or API documentation
- Inline code comments or docstrings
- Architecture documentation (ADR)
- Generated documentation from code

**Examples**:
- ✅ Update README with setup instructions
- ✅ Add JSDoc comments to exported functions
- ✅ Create troubleshooting guide

**In Comment**:
```markdown
### Documentation
- **README**: Added authentication setup section
- **API docs**: Updated endpoint specifications
```

---

### Config
**Definition**: Configuration files, build systems, deployment configuration, or infrastructure-as-code changes.

**Indicators**:
- Dockerfile, docker-compose.yml
- .github/workflows/, .github/dependabot.yml
- .terraform, terraform/base/, terraform/application/
- GitHub Actions workflows
- Build scripts or CI/CD configuration
- Dependencies (go.mod, package.json, requirements.txt)

**Examples**:
- ✅ Update Dockerfile base image version
- ✅ Add GitHub Actions workflow for security scanning
- ✅ Update Terraform provider versions
- ✅ Add npm dependency

**In Comment**:
```markdown
### Configuration
- **Dockerfile**: Update base image to Alpine 3.20
- **.github/workflows**: Add security scanning to CI pipeline
- **go.mod**: Update aws-sdk-go to v2.50.0
```

---

### Perf
**Definition**: Improves performance, reduces resource usage, or optimizes algorithms.

**Indicators**:
- Algorithm optimization (O(n²) → O(n))
- Memory usage reduction
- Cache implementation
- Query optimization
- Parallel processing improvements
- Connection pooling
- Response time metrics

**Examples**:
- ✅ Implement result caching to reduce DB queries
- ✅ Switch to more efficient data structure
- ✅ Enable connection pooling in database client

**In Comment**:
```markdown
### Performance
- **Database queries**: Implemented caching layer; 70% reduction in calls
- **List endpoint**: Optimized filter logic from O(n²) to O(n log n)
```

---

### Security
**Definition**: Security-related changes, vulnerability fixes, or security hardening.

**Indicators**:
- Vulnerability patches or CVE fixes
- Access control updates
- Encryption or authentication improvements
- IAM policy restrictions
- Dependency security updates
- Input validation hardening
- Secret rotation or secure credential handling

**Examples**:
- ✅ Update vulnerable dependency (CVE-2024-1234)
- ✅ Add input validation to prevent SQL injection
- ✅ Restrict IAM role permissions to least privilege
- ✅ Encrypt sensitive data at rest

**In Comment**:
```markdown
### Security
- ⚠️ **Dependency update**: Patched CVE-2024-1234 in log4j
- **IAM hardening**: Restrict Lambda execution role to minimal permissions
- **Input validation**: Add request body sanitization
```

---

## Special Cases

### Multi-Type Changes

**Issue**: A PR that adds both a new feature and fixes a bug

**Solution**: Classify separately under respective sections

```markdown
### Features
- **New AuthGateway**: Request validation framework

### Fixes
- **Authorization error**: Handle missing auth header

### Tests
- **AuthGateway tests**: 15 new unit tests
```

### Dependency Updates

**Classification Priority**:
1. **Security**: If fixing a CVE → Security
2. **Config**: If routine version bump → Config / Dependencies
3. **Perf**: If includes optimization → Perf

```markdown
### Security
- ⚠️ Update log4j 2.14.0 → 2.15.0 (CVE-2021-44228)

### Configuration
- Update aws-sdk-go v2.40 → v2.50 (routine updates)
```

### Refactor with Behavioral Impact

**Challenge**: Code reorganization that also fixes bugs or adds features

**Approach**:
1. Classify by primary intent from PR description
2. If unclear, check for behavior changes:
   - Behavior changed → Fix or Feature
   - Behavior same → Refactor

```markdown
### Fixes
- **AuthFlow**: Refactored token validation logic (fixes race condition)
```

### Breaking Changes

**Always Mark with ⚠️**

```markdown
### Features
- ⚠️ **API v2**: New request format (v1 deprecated, migration guide in docs)

### Configuration
- ⚠️ **Terraform**: VPC module output structure changed (see migration guide)
```

---

## Large PR Heuristic (>100 files)

For very large PRs, sample 20-30 representative changes across directories:

```
Changes across:
- cmd/ → [classify]
- pkg/ → [classify]
- terraform/ → [classify]
- test/ → [classify]
- docs/ → [classify]

Group by category and note: "Comprehensive refactoring affecting 15 modules"
```

---

## Classification Checklist

Before including a change in the comment:

- [ ] **Type assigned**: Feature / Fix / Refactor / Test / Docs / Config / Perf / Security?
- [ ] **Breaking change?**: Marked with ⚠️ if yes
- [ ] **Related issue**: Noted if closes/relates to GitHub issue
- [ ] **Specificity**: Lists actual files/functions, not generic summaries
- [ ] **Grouping**: Logical categorization by module, file type, or feature
- [ ] **Impact clarity**: Reader understands what changed and why

---

## Reference

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Versioning](https://semver.org/)
- GitHub PR best practices
