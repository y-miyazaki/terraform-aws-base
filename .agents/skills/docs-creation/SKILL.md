---
name: docs-creation
description: >-
  Create or update docs files with deterministic matching and templates.
  Use when creating or updating documentation files.
  Use for specification, architecture, design, troubleshooting, and maintenance docs.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.8.4"
---

## Input

- Natural language request describing the topic/purpose (required)
- Extracted `document_type` (required in internal structured input; infer from the natural language request using [references/category-document-types.md](references/category-document-types.md) when not explicitly provided)
- Extracted profile: `default`, `go`, or `terraform` (required)
- Optional target file under `docs/` (if omitted, automatically matched using deterministic logic)

### Internal Structured Input Schema (JSON)

Use this schema to validate the structured fields extracted from the natural language request. Do not require the user to author JSON directly.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "topic": {
      "type": "string",
      "minLength": 3
    },
    "document_type": {
      "type": "string",
      "enum": ["specification", "architecture", "design", "design-decisions", "troubleshooting", "general", "module-catalog", "monitoring", "performance", "security-coverage", "maintenance-notes", "improvements"]
    },
    "profile": {
      "type": "string",
      "enum": ["default", "go", "terraform"]
    },
    "target_file": {
      "type": "string",
      "pattern": "^docs/[a-z0-9-]+\\.md$"
    }
  },
  "required": ["topic", "document_type", "profile"]
}
```

If extracted structured input does not satisfy this schema, stop before write actions and return `status: failed` per Output Specification format, including the schema and a valid minimal JSON example in Issues.

## USE FOR:

- Creating or updating docs under `docs/`
- Applying templates to specification, architecture, design, troubleshooting, and maintenance docs
- Generating `docs/index.md` entries for changed docs

## DO NOT USE FOR:

- Source code comments or docstrings
- Non-markdown assets
- Markdown linting or link checking

## Routing

- **UTILITY SKILL** for documentation creation and updates
- Natural-language prompt in, structured fields out
- Writes only markdown files under `docs/`

## Examples

- "Create an architecture doc for this repository"
- "Update troubleshooting for Terraform validation issues"

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Create or update markdown files under `docs/`, then return a report using [references/common-output-format.md](references/common-output-format.md).
Report must include changed file paths and duplicate-check result.
Always regenerate `docs/index.md` with relative links and one-line descriptions.

File rules: see [NC-02](references/common-checklist.md) and [DC-02](references/common-checklist.md).

## Execution Scope

- Writes only to markdown files under `docs/`.
- Do not rename/delete files, add YAML frontmatter, or run markdown linting.

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [document-types](references/category-document-types.md) (always read)
- common-template: `references/category-templates-common-<document_type>.md` (Read the file matching the resolved `document_type`; e.g., `references/category-templates-common-specification.md` for `specification`)
- [go-templates](references/category-templates-go.md) (Read when the profile is `go`; overrides `specification` template)
- [terraform-templates](references/category-templates-terraform.md) (Read when the profile is `terraform`; overrides `specification` template)

## Workflow

1. List markdown files in `docs/`.
2. Resolve `document_type`: use explicit `document_type` if present; otherwise infer one candidate from [references/category-document-types.md](references/category-document-types.md).
3. If `document_type` inference is ambiguous or no candidate matches, stop before write actions and ask the user to select one explicit `document_type`.
4. If no target file provided, resolve deterministic default path using [references/category-document-types.md](references/category-document-types.md); if no deterministic match exists, ask user for an explicit target file path.
5. Select template: use `references/category-templates-go.md` for `go` profile, `references/category-templates-terraform.md` for `terraform` profile; for `default` profile, read `references/category-templates-common-<document_type>.md`.
6. Run case-insensitive duplicate check; duplicates must fail the run.
7. Create/update with naming/structure rules from [common-checklist.md](references/common-checklist.md) and valid relative links.
8. IF README has docs-index markers, update inside markers; ELSE skip.
9. Regenerate `docs/index.md` with a list of all files in `docs/` with relative links and one-line descriptions. Format:

```markdown
# Documentation Index

- [specification.md](specification.md) - Repository specification and structure
- [architecture.md](architecture.md) - System architecture overview
```

10. Return report using [references/common-output-format.md](references/common-output-format.md).

## Error Handling and Troubleshooting

- If input JSON schema validation fails, return `status: failed` and include the schema plus a valid minimal JSON example.
- If `document_type` inference returns multiple candidates or no candidate, stop before write actions and request explicit `document_type`.
- If `docs/` does not exist, create `docs/` first and continue.
- If selected template file is missing, fall back to `general` template and record fallback in report.
- If duplicate check fails, return `status: failed` and stop before write actions.
- If README markers are malformed, skip marker update and report as deferred with reason.

## Best Practices

- Run NC-01 duplicate checks before write actions.
- Keep H1 titles in `docs/`.
