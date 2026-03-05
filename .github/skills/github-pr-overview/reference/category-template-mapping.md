## PR Template Mapping & Decision Logic

## Overview

This document defines how the agent maps PR templates to the agent-generated overview comment format and provides decision logic for template detection and field mapping.

---

## Template Detection

### Decision Tree

```
1. Does PULL_REQUEST_TEMPLATE.md exist in repo?
   ├─ YES → Load template and extract structure
   │        ├─ Extract section headers and field names
   │        ├─ Map template sections to Output Format
   │        └─ Use mapped structure for comment
   │
   └─ NO → Use Default Format (Overview + Changes)
           ├─ Create standalone comment with standard sections
           └─ No template alignment needed
```

### Template Loading

```bash
# Check for template at multiple standard locations
if [ -f ".github/PULL_REQUEST_TEMPLATE.md" ]; then
  TEMPLATE_PATH=".github/PULL_REQUEST_TEMPLATE.md"
elif [ -f ".github/pull_request_template.md" ]; then
  TEMPLATE_PATH=".github/pull_request_template.md"
elif [ -f "PULL_REQUEST_TEMPLATE.md" ]; then
  TEMPLATE_PATH="PULL_REQUEST_TEMPLATE.md"
else
  # No template found - use default format
  USE_DEFAULT_FORMAT=true
fi
```

---

## Standard Template Sections to Agent Comment Mapping

### Repository-Specific Template Structure

This repository uses `.github/PULL_REQUEST_TEMPLATE.md` with the following structure:

| Template Section             | Required? | Purpose                       | Agent Comment Mapping                                         | Empty Behavior                            |
| ---------------------------- | --------- | ----------------------------- | ------------------------------------------------------------- | ----------------------------------------- |
| **Overview**                 | ✅ YES     | High-level change summary     | → **Overview** section (Objective + Background + Key Changes) | Generates placeholder with PR title only  |
| **Related Issues**           | No        | Links to GitHub issues        | → **Scope** subsection (if breaking changes mentioned)        | Ignored                                   |
| **Changes**                  | ✅ YES     | Technical modifications       | → **Changes** section (semantic descriptions)                 | Generates file list with line counts only |
| **Testing**                  | No        | Test coverage and methods     | NOT included (context for reviewers only)                     | Ignored                                   |
| **Type of Change** (8 types) | No        | Change categorization         | → Influences file classification in Changes section           | Default pattern-based classification used |
| **Checklist**                | No        | Quality/convention compliance | NOT included (for PR review process only)                     | Ignored                                   |
| **Additional Notes**         | No        | Extra context                 | NOT included (context for reviewers only)                     | Ignored                                   |

### Type of Change Mapping (8 Types)

The template defines 8 change types that influence file classification:

| Template Checkbox                       | Classification Used | Typically Applied To                            |
| --------------------------------------- | ------------------- | ----------------------------------------------- |
| ✨ Feature: New functionality added      | Feature             | New classes, functions, modules                 |
| 🐛 Bug Fix: Issue resolution             | Fix                 | Bug fix commits                                 |
| ♻️ Refactor: Code structure improvements | Refactor            | Code reorganization without behavior change     |
| 📝 Documentation: Docs/comments updates  | Docs                | `.md`, `.txt`, `.rst` files                     |
| ⚙️ Configuration: Config/build system    | Config              | Workflow files, Dockerfile, terraform, Makefile |
| 🧪 Test: New/updated tests               | Test                | `*_test.go`, `*.spec.ts`, test files            |
| 🚀 Performance: Performance improvement  | Perf                | Performance optimization commits                |
| 🔒 Security: Security-related change     | Security            | Security patches, vulnerability fixes           |

**Fallback**: If no checkboxes selected, agent uses pattern-based classification (file extension and path).

### Template Section Detail

#### 1. Overview (REQUIRED)

**Template guidance**:
```markdown
# Overview
<!--
REQUIRED: Provide a concise summary of the PR's purpose and scope.

Include:
- What problem does this PR solve or what feature does it add?
- Why is this change necessary?
- High-level summary of changes
-->
```

**Agent extraction logic**:
```bash
# Extract Overview section content (excluding comments)
overview=$(echo "$pr_body" | \
    sed -n '/^#\+ Overview/,/^#\+ [^#]/p' | \
    sed '1d;$d' | grep -v '^<!--' | sed '/^$/d')
```

**Agent comment mapping**:
- First 3 lines → `### Objective`
- Remaining lines → `### Background`
- Summary → `### Key Changes` (transformed)

**If empty**:
```markdown
### Objective
**Title**: [PR title]

_Note: This overview was auto-generated from PR title only._
_For detailed analysis, please update PR description or use AI Agent analysis._

### Background
_No background information provided in PR template._
_Please update the Overview section in PR description with context and rationale._
```

#### 2. Changes (REQUIRED)

**Template guidance**:
```markdown
## Changes
<!--
REQUIRED: Describe the specific technical changes made.

Format (one per section):
### [File/Module Name]
- **[Function/Class]**: Description of change
- **[Function/Class]**: Description of change
  - Details if needed
  - Breaking change marked with ⚠️

Example:
### terraform/modules/lambda
- **lambda_handler.py**: Added error retry logic with exponential backoff
### .github/skills
- **github-pr-overview/SKILL.md**: New Agent Skill for PR documentation
-->
```

**Agent extraction logic**:
```bash
# Extract Changes section content
changes=$(echo "$pr_body" | \
    sed -n '/^#\+ Changes/,/^#\+ [^#]/p' | \
    sed '1d;$d' | grep -v '^<!--' | sed '/^$/d')
```

**Agent comment mapping**:
- Direct inclusion in `## 📝 Changes` section
- Preserves hierarchical structure (###, bullets, sub-bullets)
- Breaking changes (⚠️) preserved

**If empty**:
```markdown
## 📝 Changes

### Config
- **.github/workflows/ci.yaml**: +50 / -10 lines
### Docs
- **README.md**: +100 / -20 lines

_Note: Detailed change descriptions not provided in PR template._
_See file-level statistics above. For semantic analysis, use AI Agent._
```

#### 3. Related Issues (Optional)

**Template guidance**:
```markdown
## Related Issues
<!--
Link related GitHub issues using #issue_number
Example: Closes #123, Related to #456
-->
```

**Agent comment mapping**:
- If "Closes" or "Fixes" keywords found → Referenced in Scope subsection
- Example: `Closes #456` in template → "Related to Issue #456" in Scope
- Otherwise ignored

#### 4-7. Other Sections (Optional, NOT Included)

These sections are for reviewers and PR process only:

- **Testing**: Test coverage details (not in agent comment)
- **Type of Change**: Influences classification (not directly included)
- **Checklist**: PR quality checks (not in agent comment)
- **Additional Notes**: Extra context (not in agent comment)

### Example Mapping

**Template section**:
```markdown
## Description
Implement user authentication API gateway integration

## Type of Change
- [x] New feature
- [ ] Bug fix

## Related Issues
Closes #456

## Changes Made
- Added AuthGateway class
- Integrated with Cognito service
- Updated IAM role policies

## Testing
- Added 15 unit tests
- Manual testing of OAuth flow completed
```

**Agent comment (mapped)**:
```markdown
## 📋 PR Overview

### Objective
Implement user authentication API gateway integration

### Background
Provides centralized authentication for API services via AWS Cognito.

### Key Changes
- New AuthGateway class for request validation
- AWS Cognito service integration
- Updated IAM policies for authentication role

### Scope
API authentication layer; backward-compatible

---

## 📝 Changes

### Features
- **AuthGateway class**: Request validation and JWT extraction
- **Cognito integration**: OAuth token validation pipeline

### Configuration
- **IAM roles**: Updated to include authentication permissions
```

---

## Default Format (No Template)

When no `PULL_REQUEST_TEMPLATE.md` exists, use:

```markdown
<!-- github-pr-overview:v1 -->

## 📋 PR Overview

### Objective
[What problem does this PR solve or what feature does it add?]

### Background
[Why is this change necessary? Context and rationale]

### Key Changes
[2–3 sentence high-level summary of main modifications]

### Scope
[Impact area, affected modules, backward compatibility]

---

## 📝 Changes

### [File/Module Category 1]
- **[File]**: [Specific change description]

### [File/Module Category 2]
- **[File]**: [Specific change description]

### Summary by Type
- **Features**: [List of feature additions]
- **Fixes**: [List of bug fixes]
- **Docs**: [Documentation updates]
```

---

## Template-Specific Best Practices

### When Template Sections Are Empty

**Issue**: Template has many sections but PR description leaves most blank

**Solution**:
1. Extract non-empty sections from template as hints
2. Fill missing context from actual code changes
3. Prioritize code analysis over template structure
4. Note assumptions if template sections relate to actual changes

**Example**:
- Template has "Testing" section but it's empty
- Code shows 10 new unit tests were added
- Include in Changes section: `**Tests**: 10 new unit tests added for AuthGateway`

### Custom/Non-Standard Templates

**Issue**: Repository uses unconventional template structure

**Best Effort Approach**:
1. Attempt to map sections by name similarity (e.g., "Summary" → "Objective")
2. If unclear, fall back to Default Format
3. Prioritize actual PR description content over strict template alignment
4. Document any assumptions in the overview

---

## Change Categorization by File Type

Use this matrix with template "Type of Change" section to build Changes groups:

| File Pattern                                 | Classification        | Template Indicator                 |
| -------------------------------------------- | --------------------- | ---------------------------------- |
| `.go`, `.ts`, `.py`, `.java`                 | **Feature** / **Fix** | "Feature" / "Bug fix" checkbox     |
| `*_test.go`, `*.test.ts`, `test_*.py`        | **Test**              | "Testing" section                  |
| `*.md`, `docs/`                              | **Docs**              | "Documentation" checkbox           |
| `go.mod`, `package.json`, `requirements.txt` | **Dependencies**      | "Dependencies" section             |
| `Dockerfile`, `.github/workflows/`           | **Config**            | "Infrastructure" / "CI/CD" section |
| `*.tf`, `terraform/`                         | **Infrastructure**    | "Infrastructure/Terraform" section |

---

## Decision Logic Summary

```
IF template exists:
  ├─ Extract template structure
  ├─ Map sections to Output Format
  └─ Align comment to template
ELSE:
  ├─ Use Default Format
  └─ Generate standalone comment structure

FOR each detected change:
  ├─ Classify by file type and content
  ├─ Group by module/directory
  └─ Add to appropriate Changes subsection

FOR template "Type of Change":
  ├─ If multiple types checked, prioritize in order:
  │  • Feature > Fix > Refactor > Test > Docs
  └─ Highlight primary change type in comment
```

---

## Example: Terraform-Heavy Repository

**Template Structure**:
```markdown
## Type of Change
- [x] Terraform Module Update
- [ ] Bug Fix
- [ ] Documentation

## Modules Changed
- vpc
- security-groups

## Breaking Changes
None
```

**Agent Mapping**:
```markdown
### Objective
Update VPC module with enhanced security group management

### Key Changes
- Added dynamic security group creation in VPC module
- Refactored ingress/egress rule handling

### Scope
VPC and Security Groups modules; backward-compatible; safe to deploy
```

---

## Reference

- [GitHub Creating PR Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
- [Best Practices for PR Templates](https://github.blog/2021-04-20-github-now-supports-pull-request-templates/)
