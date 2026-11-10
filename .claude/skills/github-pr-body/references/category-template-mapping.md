# PR Template Mapping & Decision Logic

## Overview

`pr_body.sh` behavior:

- Generates a metadata-only baseline for `## Overview` (Title, Branch, Stats)
- Generates the file list for `## Changes` (grouped by deterministic path-based classification)
- Rebuilds other sections in template order and preserves template comments for AI completion
- Does not interpret chapter meaning or generate section prose; full-body AI completion does that (see [category-pr-body-guidelines.md](category-pr-body-guidelines.md))

---

## Standard Template Sections to PR Body Update Mapping

### Template Location

`pr_body.sh` reads only `.github/PULL_REQUEST_TEMPLATE.md` at the repository root; that is the supported template location. A root-level `PULL_REQUEST_TEMPLATE.md`, `docs/PULL_REQUEST_TEMPLATE.md`, and multi-template directories (`.github/PULL_REQUEST_TEMPLATE/`) are not read by the script.

### Section Handling

`## Overview` and `## Changes` are script-generated. AI completion fills every other H2 in the template that carries guidance comments or examples; H2s without guidance are preserved as-is. The rows below are examples (e.g. a template with these sections), not a required set:

| Template Section     | Required? | Purpose                       | Script Behavior                     | AI Completion Behavior                                  |
| -------------------- | --------- | ----------------------------- | ----------------------------------- | ------------------------------------------------------- |
| **Overview**         | ✅ YES    | High-level change summary     | Deterministic baseline content      | Refine or replace using comment guidance                |
| **Related Issues**   | No        | Links to GitHub issues        | Preserve template section structure | Generate visible content if guidance indicates it       |
| **Changes**          | ✅ YES    | Technical modifications       | File list with classification       | Optionally refine prose around generated structure      |
| **Testing**          | No        | Test coverage and methods     | Preserve template section structure | Generate visible content using Example or checklist     |
| **Type of Change**   | No        | Change categorization         | Preserve template section structure | Select checkboxes based on PR meaning                   |
| **Checklist**        | No        | Quality/convention compliance | Preserve template section structure | Update checkboxes based on validation and reviewer data |
| **Additional Notes** | No        | Extra context                 | Preserve template section structure | Generate content when example or PR context warrants it |

### Type of Change (when the template has a Type of Change section)

Apply this subsection only when the template has a Type of Change section. Example checkbox set (a template may define a different list; use its own items):

| Template Checkbox                        | Purpose                                            |
| ---------------------------------------- | -------------------------------------------------- |
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

#### 4. Other Template Sections (Preserved)

Every other H2 in the template is preserved in template order by the script. For example:

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

**Stats**: 4 files changed (+250 / -30 lines)

_This section was auto-generated._

## Changes

### Config

- **terraform/iam_roles.tf**: +30 / -10 lines

### Feature

- **src/AuthGateway.ts**: +120 / -10 lines
- **src/CognitoClient.ts**: +80 / -5 lines

### Test

- **tests/auth_gateway_test.ts**: +20 / -5 lines

**Summary**: 4 files changed (+250 / -30 lines)

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
- Fill the `## Testing` section: `10 new unit tests added for AuthGateway`; leave the script-generated `## Changes` as is

### Custom/Non-Standard Templates

**Issue**: Repository uses unconventional template structure

**Best Effort Approach**:

1. Fill each template H2 from its own comment guidance; do not infer format from the heading name alone
2. If a section has no guidance, preserve it without inventing structure
3. Prioritize actual PR description content over strict template alignment
4. Document any assumptions in the overview

---

## Change Categorization by File Type

**Script Behavior**: Classification is deterministic and path-based. The script does NOT read template "Type of Change" checkboxes or any other template indicators. Rules are checked in this order; the first match wins:

| Path match                                                                                                                           | Classification |
| ------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| ends with `_test.go`, `_test.ts`, `_test.js`, `_test.py`, `_test.java`                                                               | **Test**       |
| ends with `.md`, `.txt`, `.rst`                                                                                                      | **Docs**       |
| contains `Dockerfile`, `docker-compose`, `.github/workflows`, `manifest`, `stack`, `terraform`, `Makefile`, `package.json`, `go.mod` | **Config**     |
| ends with `.go`, `.ts`, `.js`, `.py`, `.java`                                                                                        | **Feature**    |
| anything else                                                                                                                        | **Other**      |

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

---

## Reference

- [GitHub Creating PR Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
- Best practice: keep section comments explicit and machine-readable so AI completion can follow them consistently.
