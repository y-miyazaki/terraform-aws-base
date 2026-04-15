## PR Template Mapping & Decision Logic

## Overview

**Important**: This document originally described hypothetical agent-based template mapping logic. The current `pr_body.sh` script does NOT implement intelligent template parsing or semantic mapping.

**Actual script behavior**:
- Generates metadata-only baseline for `## Overview` section (Title, Branch, Stats) unless caller provides `--overview-file`
- Generates file list for `## Changes` section (grouped by deterministic pattern-based classification)
- Rebuilds other sections in template order and preserves template comments for AI completion
- Does not interpret chapter meaning or generate section prose beyond deterministic baseline output

**This document is retained for**:
- Understanding historical design intent
- Reference for potential future agent enhancement
- Clarifying what the script does NOT do

---

## Template Detection

**Note**: The following describes conceptual template detection logic that is NOT implemented by the current script.

Current script behavior: Always generates the same baseline output structure regardless of template presence or format.

### Decision Tree (Conceptual - AI Completion Layer)

The following decision tree describes the AI completion layer that runs after the deterministic shell scripts:

```
1. Does PULL_REQUEST_TEMPLATE.md exist in repo?
   ├─ YES → Load template and extract structure
   │        ├─ Script: rebuild deterministic baseline in template order
   │        ├─ AI: read section comments and Example / checkbox guidance
   │        └─ AI: generate chapter content using that guidance
   │
   └─ NO → Use deterministic baseline only
           ├─ Script: generate Overview + Changes
           └─ AI: avoid inventing unsupported structure
```

**Actual script behavior**: Template presence affects section order and comment preservation, but not semantic prose generation.

### Template Loading (Conceptual - Not Implemented)

The following template detection logic is NOT used by the current `pr_body.sh` script:

```bash
# This code is NOT in the actual script - reference only
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

**Actual script behavior**: Always generates same baseline output, template-agnostic.

---

## Standard Template Sections to PR Body Update Mapping

### Repository-Specific Template Structure

This repository uses `.github/PULL_REQUEST_TEMPLATE.md` with the following structure:

| Template Section             | Required? | Purpose                       | Script Behavior                                     | AI Completion Behavior                                  |
| ---------------------------- | --------- | ----------------------------- | --------------------------------------------------- | ------------------------------------------------------- |
| **Overview**                 | ✅ YES     | High-level change summary     | Deterministic baseline or `--overview-file` content | Refine or replace using comment guidance                |
| **Related Issues**           | No        | Links to GitHub issues        | Preserve template section structure                 | Generate visible content if guidance indicates it       |
| **Changes**                  | ✅ YES     | Technical modifications       | File list with classification                       | Optionally refine prose around generated structure      |
| **Testing**                  | No        | Test coverage and methods     | Preserve template section structure                 | Generate visible content using Example or checklist     |
| **Type of Change** (8 types) | No        | Change categorization         | Preserve template section structure                 | Select checkboxes based on PR meaning                   |
| **Checklist**                | No        | Quality/convention compliance | Preserve template section structure                 | Update checkboxes based on validation and reviewer data |
| **Additional Notes**         | No        | Extra context                 | Preserve template section structure                 | Generate content when example or PR context warrants it |

### Type of Change (Informational Only)

The template defines 8 change types for reviewer/author reference:

| Template Checkbox                       | Purpose                                            |
| --------------------------------------- | -------------------------------------------------- |
| ✨ Feature: New functionality added      | Indicates new feature addition (informational)     |
| 🐛 Bug Fix: Issue resolution             | Indicates bug fix (informational)                  |
| ♻️ Refactor: Code structure improvements | Indicates code refactoring (informational)         |
| 📝 Documentation: Docs/comments updates  | Indicates documentation updates (informational)    |
| ⚙️ Configuration: Config/build system    | Indicates configuration changes (informational)    |
| 🧪 Test: New/updated tests               | Indicates test additions/updates (informational)   |
| 🚀 Performance: Performance improvement  | Indicates performance optimization (informational) |
| 🔒 Security: Security-related change     | Indicates security-related changes (informational) |

**Script Behavior**: The automated script does NOT select Type of Change checkboxes. File classification is deterministic and pattern-based (file extension and path only).

**AI Completion Behavior**: Read the checkbox guidance in the template comment and select the matching items based on PR intent.

### Template Section Detail

#### 1. Overview

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

**Script behavior**:
- Script generates metadata-only baseline: Title, Branch, Stats
- Script preserves template guidance comments
- Script does NOT interpret template content semantically

**AI completion behavior**:
- Read the guidance comment and Example block
- Produce visible content in the same format
- Replace metadata-only baseline when richer Overview content is available

**Generated baseline**:
```markdown
## Overview

**Title**: [PR title]

**Branch**: [head] -> [base]

**Stats**: [N files changed (+A / -D lines)]

_This section was auto-generated._
```

#### 2. Changes

**Template guidance**:
```markdown
## Changes
<!--
REQUIRED: Describe the specific technical changes made.

Format (one per section):
### [File/Module Name]
- **[Function/Class]**: Description of change
-->
```

**Script behavior**:
- Script generates file list grouped by classification (Config, Docs, Feature, Test, Other)
- Each file shows path + line changes (+X / -Y lines)
- Script preserves template guidance comments

**AI completion behavior**:
- Read the Example block and produce any additional prose or grouping required by the template
- Keep deterministic file list unless a manual editorial change is explicitly desired

**Generated baseline**:
```markdown
## Changes

### Config
- **.github/workflows/ci.yaml**: +50 / -10 lines

### Docs
- **README.md**: +100 / -20 lines

**Summary**: 2 files changed (+150 / -30 lines)
```

#### 3. Related Issues

**Template guidance**:
```markdown
## Related Issues
<!--
Link related GitHub issues using #issue_number
Example: Closes #123, Related to #456
-->
```

**Script behavior**:
- Script preserves this section in template order

**AI completion behavior**:
- Fill issue links when PR context or linked issues are known

#### 4-7. Other Sections (Optional, Preserved)

These sections are preserved in PR Body as template-ordered placeholders by the script:

- **Testing**: Test coverage details (preserved for AI completion)
- **Type of Change**: Change categorization (preserved for AI completion)
- **Checklist**: PR quality checks (preserved for AI completion)
- **Additional Notes**: Extra context (preserved for AI completion)

**Script does NOT generate semantic content for these sections**. AI completion reads their comments and Examples to create visible content when required.

### Example: Script Execution Result

**Before script execution**:
```markdown
## Overview
[Manual content or empty]

## Changes
[Manual content or empty]

## Type of Change
- [x] New feature
- [ ] Bug fix

## Related Issues
Closes #456

## Testing
- Added 15 unit tests
```

**After `pr_body.sh` execution**:
```markdown
## Overview

**Title**: Implement user authentication API gateway integration

**Branch**: feature/auth-gateway -> main

**Stats**: 5 files changed (+250 / -30 lines)

_This section was auto-generated._

## Changes

### Feature
- **src/AuthGateway.ts**: +120 / -10 lines
- **src/CognitoClient.ts**: +80 / -5 lines

### Config
- **terraform/iam_roles.tf**: +30 / -10 lines

### Test
- **tests/AuthGateway.test.ts**: +20 / -5 lines

**Summary**: 5 files changed (+250 / -30 lines)

## Type of Change
- [x] New feature
- [ ] Bug fix

## Related Issues
Closes #456

## Testing
- Added 15 unit tests
```

**Key Points**:
- `## Overview` and `## Changes` are always regenerated deterministically
- Other sections preserve visible content and restore template comments when empty
- AI completion adds context after baseline generation

---

## Default Format (No Template)

**Note**: This section describes a hypothetical agent-based comment format that is NOT implemented by the current `pr_body.sh` script.

The actual script always generates metadata-only baseline for Overview and file-list-only for Changes, regardless of template presence.

For reference only (not implemented):

```markdown
<!-- github-pr-body:v1 -->

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

**Script Behavior**: Classification is deterministic and pattern-based (file extension and path only). The script does NOT read template "Type of Change" checkboxes or any other template indicators.

File pattern to classification mapping:

| File Pattern                                 | Classification | Notes                                   |
| -------------------------------------------- | -------------- | --------------------------------------- |
| `.go`, `.ts`, `.py`, `.java`                 | **Feature**    | Application code (not test/config/docs) |
| `*_test.go`, `*.test.ts`, `test_*.py`        | **Test**       | Test files by naming convention         |
| `*.md`, `docs/`                              | **Docs**       | Documentation files                     |
| `go.mod`, `package.json`, `requirements.txt` | **Config**     | Dependency manifests                    |
| `Dockerfile`, `.github/workflows/`           | **Config**     | Infrastructure and CI/CD configuration  |
| `*.tf`, `terraform/`                         | **Config**     | Terraform infrastructure code           |

---

## Decision Logic Summary

**Current script behavior**:

```
FOR each PR:
  ├─ Generate Overview section (metadata-only: Title, Branch, Stats)
  ├─ Classify files by pattern (deterministic)
  ├─ Generate Changes section (file list grouped by classification)
  └─ Preserve all other H2 sections as-is

Classification logic:
  FOR each file:
    ├─ Match file path/extension against patterns
    ├─ Assign to category: Config | Docs | Feature | Test | Other
    └─ Group files by category in Changes section
```

**Not implemented** (reference only, for potential future agent enhancement):



---

## Example: Terraform-Heavy Repository

**Note**: This example describes hypothetical agent behavior that is NOT implemented by `pr_body.sh`.

The actual script generates metadata-only Overview and file-list Changes, regardless of template content.

For reference only (conceptual future enhancement):

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
- Best practice: keep section comments explicit and machine-readable so AI completion can follow them consistently.
