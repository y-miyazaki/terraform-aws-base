---
name: docs-creation
description: >-
  Creates and updates documentation files in the docs/ directory following project conventions.
  Enforces lowercase underscore file naming, consistent heading structure, and appropriate
  document type selection. Use when creating new docs, writing specifications, architecture
  overviews, design documents, design decisions, troubleshooting guides, or any technical
  documentation placed under docs/.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.3.0"
---

## Input

- Document purpose and topic (required)
- Operation mode — `create` / `update` / `auto` (required)
- Document type (required):
  - Core types: `specification` / `architecture` / `design_decisions` / `design` / `troubleshooting` / `general`
  - Extension types: `module_catalog` / `monitoring` / `performance` / `security_coverage` / `maintenance_notes` / `improvements`
  - Project-defined custom types are allowed when mapped to a filename pattern and a template section
- Target file path under `docs/` when updating (required for `update`, optional for `auto`)
- Existing `docs/` file list for duplicate detection and cross-references (recommended)

## Output Specification

A single Markdown file created or updated at `docs/<filename>.md`.

Output contract:

- Filename: all-lowercase, underscore-separated, `.md` extension only
- No YAML frontmatter in the generated file
- First line: H1 heading (human-readable title, not the filename)
- Second block: one or two sentence purpose paragraph
- Body: H2 sections with content

Report after creation using the format in [references/common-output-format.md](references/common-output-format.md).

## Execution Scope

**Does:**

- Create or update one `docs/<filename>.md` per invocation
- Apply the template from [references/category-templates.md](references/category-templates.md) matching the document type
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

- [references/category-templates.md](references/category-templates.md) - Read to get the template for the chosen document type
- Project markdown guidance file (if present) - Read when a repository defines additional markdown/documentation rules

## Workflow

### Step 1: Resolve Document Type and Filename

1. Match the requested topic to a type using the table below.
2. Derive filename following Naming Rules.
3. Resolve operation mode:

- If mode is `update`: use the provided target file path and verify it exists.
- If mode is `create`: ensure target filename does not already exist.
- If mode is `auto`: update when exact target file is provided and exists; otherwise create.

4. Check existing `docs/` files case-insensitively to prevent duplicates that differ only by case.

| Type                | Filename pattern        | When to use                                        |
| ------------------- | ----------------------- | -------------------------------------------------- |
| `specification`     | `specification.md`      | Behavioral or functional spec                      |
| `architecture`      | `architecture.md`       | System structure, components, account layout       |
| `design_decisions`  | `design_decisions.md`   | Recorded decisions: what, why, alternatives        |
| `design`            | `design.md`             | Module design, resource layout, naming conventions |
| `module_catalog`    | `module_catalog.md`     | Index of reusable modules/components               |
| `security_coverage` | `security_coverage.md`  | Security service coverage matrix                   |
| `troubleshooting`   | `troubleshooting.md`    | Symptoms → cause → resolution                      |
| `monitoring`        | `monitoring.md`         | Alerts, dashboards, runbooks                       |
| `performance`       | `performance.md`        | Benchmarks, bottlenecks, tuning                    |
| `maintenance_notes` | `maintenance_notes.md`  | Periodic tasks, known quirks                       |
| `improvements`      | `improvements.md`       | Planned and completed improvements                 |
| `general`           | `<descriptive_name>.md` | Any other topic                                    |

For project-defined custom types:

1. Define filename pattern before generation.
2. Add or select a matching template section in `references/category-templates.md`.
3. If no dedicated template exists, use `general` as fallback.

**Naming Rules:**

| Rule                      | Correct               | Wrong                 |
| ------------------------- | --------------------- | --------------------- |
| All lowercase             | `design_decisions.md` | `DESIGN_DECISIONS.md` |
| Underscores as separators | `module_catalog.md`   | `module-catalog.md`   |
| No version numbers        | `specification.md`    | `specification_v2.md` |
| `.md` extension only      | `architecture.md`     | `architecture.txt`    |

Numeric prefix only when documents have a defined reading order: `01_architecture.md`.

### Step 2: Load Template

Load [references/category-templates.md](references/category-templates.md) and select the section matching the document type from Step 1.

### Step 3: Create File

1. Apply the template as the starting structure.
2. Replace all `<placeholder>` values with actual content.
3. Add cross-references to existing `docs/` files using relative paths: `[design_decisions.md](./design_decisions.md)`.
4. Confirm filename is all-lowercase with underscores.
5. For technical documents, follow this order unless the project defines a different required structure: Overview, Prerequisites, Architecture/Design, Implementation Details, Testing/Validation, Troubleshooting. Omit a section only when explicitly not applicable.

### Step 4: Update README (conditional)

IF `README.md` contains a docs index block (e.g. a table or list linking into `docs/`):
→ Add an entry for the new file.

ELSE:
→ Skip this step.

### Step 5: Report

Output the creation report using [references/common-output-format.md](references/common-output-format.md).

## Best Practices

- Run duplicate check (NC-01 in [references/common-checklist.md](references/common-checklist.md)) before creating.
- Use case-insensitive duplicate detection in `docs/` (`document.md` vs `DOCUMENT.md`) before file creation.
- Keep H1 unique across all files in `docs/` — do not reuse titles.
- Use present tense, factual, concise prose. Avoid filler phrases ("This document aims to...").
- Always specify a language identifier on code blocks: ` ```sh `, ` ```hcl `, ` ```go `.
