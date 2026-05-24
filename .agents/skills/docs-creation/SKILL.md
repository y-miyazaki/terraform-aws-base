---
name: docs-creation
description: >-
  Create or update docs files with deterministic matching and templates.
  Use when creating or updating documentation files.
  Use for README, specification, architecture, design, troubleshooting, and maintenance docs.
  Use for updating existing manually-created documents to improve quality and consistency.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.9.0"
---

## Input

- Natural language request describing the topic/purpose (required)
- `document_type`: one of `readme`, `specification`, `architecture`, `design`, `design-decisions`, `troubleshooting`, `tutorial`, `general`, `module-catalog`, `monitoring`, `performance`, `security-coverage`, `maintenance-notes`, `improvements`, `other` (infer from request using [references/category-document-types.md](references/category-document-types.md); defaults to `other` when `target_file` points to an existing file)
- `profile`: `default`, `go`, or `terraform` (required)
- `target_file`: path to target `.md` file (optional; required for `other` type)

## Output Specification

Return structured report per [references/common-output-format.md](references/common-output-format.md) with changed file paths and duplicate-check result. Regenerate `docs/index.md` only when files under `docs/` are created or updated.

## Execution Scope

- Writes to markdown files under `docs/`, `README.md` at repository root, or existing files at `target_file` path (for `other` type).
- `readme` type MUST produce `README.md` at repository root.
- `general` is for creating new documents outside predefined types (template-driven).
- `other` is for updating existing documents outside predefined types (structure-preserving).
- Do not rename/delete files, add YAML frontmatter, or run markdown linting (use markdown-validation skill).

### USE FOR:

- create or update docs under `docs/` or `README.md`
- update existing manually-created documents (e.g. "Improve the existing CONTRIBUTING.md")
- apply templates to specification, architecture, design, troubleshooting, tutorial docs

### DO NOT USE FOR:

- source code comments or docstrings
- non-markdown assets
- markdown linting or link checking (use markdown-validation skill)

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-document-types.md](references/category-document-types.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read on failure
- Templates (read the one matching resolved `document_type`):
  - [category-templates-common-readme.md](references/category-templates-common-readme.md)
  - [category-templates-common-specification.md](references/category-templates-common-specification.md)
  - [category-templates-common-architecture.md](references/category-templates-common-architecture.md)
  - [category-templates-common-design.md](references/category-templates-common-design.md)
  - [category-templates-common-design-decisions.md](references/category-templates-common-design-decisions.md)
  - [category-templates-common-troubleshooting.md](references/category-templates-common-troubleshooting.md)
  - [category-templates-common-tutorial.md](references/category-templates-common-tutorial.md)
  - [category-templates-common-general.md](references/category-templates-common-general.md)
  - [category-templates-common-module-catalog.md](references/category-templates-common-module-catalog.md)
  - [category-templates-common-monitoring.md](references/category-templates-common-monitoring.md)
  - [category-templates-common-performance.md](references/category-templates-common-performance.md)
  - [category-templates-common-security-coverage.md](references/category-templates-common-security-coverage.md)
  - [category-templates-common-maintenance-notes.md](references/category-templates-common-maintenance-notes.md)
  - [category-templates-common-improvements.md](references/category-templates-common-improvements.md)
  - [category-templates-common-other.md](references/category-templates-common-other.md)
- [category-templates-go-specification.md](references/category-templates-go-specification.md) (Read when profile is `go` and `document_type` is `specification`)
- [category-templates-terraform-specification.md](references/category-templates-terraform-specification.md) (Read when profile is `terraform` and `document_type` is `specification`)

## Workflow

1. List markdown files in `docs/`.
2. Resolve `document_type`: use explicit value if present; otherwise infer from [references/category-document-types.md](references/category-document-types.md). If `target_file` is an existing file and type is unspecified, default to `other`. If ambiguous, ask user.
3. Resolve `target_file`: use [references/category-document-types.md](references/category-document-types.md) default path; `readme` → `README.md`; `other` requires explicit `target_file`. If unresolved, ask user.
4. Select template per profile and `document_type`. For `document_type=specification`, use profile-specific overrides from [category-templates-go-specification.md](references/category-templates-go-specification.md) or [category-templates-terraform-specification.md](references/category-templates-terraform-specification.md) when applicable.
5. Run case-insensitive duplicate check (skip for `other` type). Fail on duplicates.
6. Create/update per [common-checklist.md](references/common-checklist.md). For `other` type, preserve original structure and apply quality improvements.
7. IF README has docs-index markers, update inside markers; ELSE skip.
8. Regenerate `docs/index.md` if files under `docs/` changed.
9. Return report per [references/common-output-format.md](references/common-output-format.md).
