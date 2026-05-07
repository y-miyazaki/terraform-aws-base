---
name: docs-creation
description: >-
  Creates and updates documentation files in the docs/ directory following project conventions.
  Enforces lowercase underscore file naming, consistent heading structure, and automatic
  create-or-update behavior based on the requested topic and existing docs files. Use when creating new docs, writing
  specifications, architecture overviews, design documents, design decisions,
  troubleshooting guides, or any technical documentation placed under docs/.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.8.3"
---

## Input

- Document purpose and topic (required)
- Target file path under `docs/` when a specific existing file must be updated or a specific filename must be used (optional)
- Core docs baseline mode (optional):
  - `initial-only` (default): ensure `architecture.md` and `specification.md` only when no markdown files exist under `docs/`
  - `always`: ensure `architecture.md` and `specification.md` on every run

`docs/` file discovery is automatic. Do not require users to provide a file list.

## Output Specification

One or more Markdown files created or updated under `docs/`.

Output contract:

- Filename: all-lowercase, underscore-separated, `.md` extension only
- No YAML frontmatter in the generated file
- First line: H1 heading (human-readable title, not the filename)
- Second block: one or two sentence purpose paragraph
- Body: H2 sections with content
- This output contract applies only to generated files under `docs/`, not to skill reference files under `references/`.

Report after creation using the format in [references/common-output-format.md](references/common-output-format.md).

## Execution Scope

**Does:**

- Ensure core documents `docs/architecture.md` and `docs/specification.md` based on baseline mode
- Create a new `docs/<filename>.md` when no matching document exists, or update the matching file when one already exists
- Resolve document level internally from topic or target file and apply the matching template from base and language-specific category references
- Add relative-path cross-references to existing `docs/` files where relevant
- Follow project-specific documentation standards when available; otherwise apply the default technical documentation structure defined in this skill
- Update `README.md` links section if it contains a `docs/` index block and the file is new

**Out of Scope:**

- Rename or delete existing files (use file rename workflow instead)
- Create subdirectories under `docs/` unless one already exists in the project
- Validate Markdown syntax (markdownlint's responsibility — use `markdown-validation` skill)
- Add YAML frontmatter, metadata comments, or generation timestamps to the generated file

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Pre-creation/update checklist (NC-01 through DC-05)
- [common-output-format.md](references/common-output-format.md) - Report format after file creation

**Category Details** (read when relevant):

- [references/category-templates.md](/workspace/.github/skills/docs-creation/references/category-templates.md) - Read when selecting base templates for generic document types
- [references/category-templates-terraform.md](/workspace/.github/skills/docs-creation/references/category-templates-terraform.md) - Read when Terraform profile is detected
- [references/category-templates-go.md](/workspace/.github/skills/docs-creation/references/category-templates-go.md) - Read when Go profile is detected without Terraform profile
- Project markdown guidance file (if present) - Read when a repository defines additional markdown/documentation rules

## Workflow

### Matching and Detection Rules

- Profile detection:
  - Excluded directories for profile detection: `vendor/`, `node_modules/`, `.terraform/`, `.git/`.
  - Terraform profile: at least one `*.tf` file exists in the repository root or any subdirectory excluding excluded directories.
  - Go profile: `go.mod` exists in the repository root or any subdirectory excluding excluded directories.
  - Multiple matches of the same profile: use the shallowest matching path.
  - Profile priority: Terraform > Go > default.
- Keyword extraction for matching:
  1. Convert topic, filename stem, H1 title, and purpose paragraph to lowercase.
  2. Split tokens by spaces, underscores, hyphens, slashes, and dots.
  3. Remove tokens with length less than or equal to 3.
  4. Remove stopwords: `the`, `and`, `for`, `with`, `from`, `into`, `docs`, `doc`, `document`, `documents`, `file`, `files`, `guide`, `overview`.
  5. Deduplicate tokens while preserving token set membership.

### Step 1: Ensure Core Docs Baseline

1. Inspect the existing `docs/` files.
2. Resolve baseline mode:

- Use `initial-only` when no mode is provided.
- Use the provided mode only when it is `initial-only` or `always`.

3. Apply baseline mode:

- For `initial-only`, create missing `docs/architecture.md` and `docs/specification.md` only when `docs/` has zero `.md` files.
- For `always`, create missing `docs/architecture.md` and `docs/specification.md` on every run.

4. Create `docs/architecture.md` using the `architecture` section in [references/category-templates.md](/workspace/.github/skills/docs-creation/references/category-templates.md) when required by the mode.
5. Create `docs/specification.md` by profile:

- Use `specification_terraform` from the Terraform-specific category template reference when Terraform profile is detected.
- Use `specification_go` from the Go-specific category template reference when Go profile is detected and Terraform profile is not detected.
- Otherwise use `specification / spec` from [references/category-templates.md](/workspace/.github/skills/docs-creation/references/category-templates.md).

### Step 2: Resolve Target Document and Filename

1. Inspect the existing `docs/` files.

- If the input provides a target file path, use that file.
- Otherwise, find the best existing match using this deterministic order:
  1. Exact file path match from normalized canonical filename of the resolved type.
  2. Exact normalized H1 match.
  3. Weighted keyword score using extracted keywords:
     - filename overlap count \* 3
     - H1 overlap count \* 2
     - purpose paragraph overlap count \* 1
     - minimum accepted score: 2
  4. Tie-breaker: choose lexicographically smallest path.
- If a matching document exists, update it.
- If no matching document exists, create a new file.

2. Resolve the document level internally:

- Match the requested topic or matched existing document to a type using the table below.
- If no specific type fits, use `general`.
- Treat rows marked `Required = Yes` as mandatory baseline documents.

3. Derive the filename following Naming Rules.

- If updating, keep the existing file path unless the input explicitly requires a different target.
- If creating, ensure the target filename does not already exist.

4. Check existing `docs/` files case-insensitively to prevent duplicates that differ only by case.

- If case-only duplicates exist, fail the run and report the conflicting paths.
- Do not create or update files until the duplicate conflict is resolved.

| Type                | Required | Filename pattern        | When to use                                        |
| ------------------- | -------- | ----------------------- | -------------------------------------------------- |
| `specification`     | Yes      | `specification.md`      | Behavioral or functional spec                      |
| `architecture`      | Yes      | `architecture.md`       | System structure, components, account layout       |
| `design_decisions`  | No       | `design_decisions.md`   | Recorded decisions: what, why, alternatives        |
| `design`            | No       | `design.md`             | Module design, resource layout, naming conventions |
| `module_catalog`    | No       | `module_catalog.md`     | Index of reusable modules/components               |
| `security_coverage` | No       | `security_coverage.md`  | Security service coverage matrix                   |
| `troubleshooting`   | No       | `troubleshooting.md`    | Symptoms → cause → resolution                      |
| `monitoring`        | No       | `monitoring.md`         | Alerts, dashboards, runbooks                       |
| `performance`       | No       | `performance.md`        | Benchmarks, bottlenecks, tuning                    |
| `maintenance_notes` | No       | `maintenance_notes.md`  | Periodic tasks, known quirks                       |
| `improvements`      | No       | `improvements.md`       | Planned and completed improvements                 |
| `general`           | No       | `<descriptive_name>.md` | Any other topic                                    |

For project-defined custom types:

1. Define filename pattern before generation.
2. Add or select a matching template section in a category template reference file.
3. If no dedicated template exists, use `general` as fallback.

**Naming Rules:**

| Rule                      | Correct               | Wrong                 |
| ------------------------- | --------------------- | --------------------- |
| All lowercase             | `design_decisions.md` | `DESIGN_DECISIONS.md` |
| Underscores as separators | `module_catalog.md`   | `module-catalog.md`   |
| No version numbers        | `specification.md`    | `specification_v2.md` |
| `.md` extension only      | `architecture.md`     | `architecture.txt`    |

Numeric prefix only when documents have a defined reading order: `01_architecture.md`.

### Step 3: Load Template

Load base and language-specific category template references and select the section matching the document type from Step 2.

- When the document type is `specification` and Terraform profile is detected, use `specification_terraform` from the Terraform-specific category template reference.
- When the document type is `specification` and Go profile is detected (without Terraform profile), use `specification_go` from the Go-specific category template reference.
- Otherwise, use the default template section for the selected type.

### Step 4: Create or Update File

1. Apply the template as the starting structure for the new file or as the structure guide for the update.
2. Replace all `<placeholder>` values with actual content.
3. Add cross-references to existing `docs/` files using relative paths: `[design_decisions.md](./design_decisions.md)`.
4. Confirm filename is all-lowercase with underscores.
5. For technical documents, follow this order unless the project defines a different required structure: Overview, Prerequisites, Architecture/Design, Implementation Details, Testing/Validation, Troubleshooting. Omit a section only when explicitly not applicable.

### Step 5: Update README (conditional)

IF `README.md` contains both markers `<!-- docs-index-start -->` and `<!-- docs-index-end -->`:
→ Update only the content between markers.

ELSE IF `README.md` has a `## Docs` or `## Documentation` section that already contains at least one `docs/` link:
→ Append the new link to the first H2 section that contains at least one markdown link target with `docs/`.

ELSE:
→ Skip this step.

### Step 6: Report

Output the creation report using [references/common-output-format.md](/workspace/.github/skills/docs-creation/references/common-output-format.md).

## Best Practices

- Run duplicate check (NC-01 in [references/common-checklist.md](/workspace/.github/skills/docs-creation/references/common-checklist.md)) before creating.
- Use case-insensitive duplicate detection in `docs/` (`document.md` vs `DOCUMENT.md`) before file creation.
- Keep H1 unique across all files in `docs/` — do not reuse titles.
- Use present tense, factual, concise prose. Avoid filler phrases ("This document aims to...").
- Always specify a language identifier on code blocks: ` ```sh `, ` ```hcl `, ` ```go `.
- Use filename-as-text style for internal docs links: `[design_decisions.md](./design_decisions.md)`.

## Versioning Policy

- Bump patch version for wording-only clarifications.
- Bump minor version for workflow logic changes, new required checks, or new template variants.
- Record the reason for the version bump in the pull request description.
- Do not maintain an in-file changelog for this skill; use pull request history as the change record.
