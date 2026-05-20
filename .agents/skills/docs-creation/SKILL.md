---
name: docs-creation
description: >-
  Create or update docs files with deterministic matching and templates.
  Use for specification, architecture, design, troubleshooting, and maintenance docs.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.8.4"
---

## Input

- Topic/purpose (required)
- Optional target file under `docs/` and baseline mode (`initial-only` or `always`)
- Core docs set: `docs/specification.md`, `docs/architecture.md`, `docs/design.md`, `docs/troubleshooting.md`, `docs/maintenance.md`

## Output Specification

Create or update markdown files under `docs/`, then return a report using [references/common-output-format.md](references/common-output-format.md).
Report must include changed file paths, mode (`initial-only` or `always`), and duplicate-check result.

File rules:

- lowercase underscore `.md` filename
- no YAML frontmatter
- H1 title, purpose paragraph, H2 sections

## Execution Scope

- Ensure baseline docs by mode.
- Resolve update/create deterministically and apply templates.
- Add valid docs links and conditionally update README docs index.
- Do not rename/delete files, add YAML frontmatter, or run markdown linting.

### USE FOR:

- create new documentation files under `docs/`
- update existing docs with template-aligned structure
- maintain README docs index entries linked to `docs/`

### DO NOT USE FOR:

- edit inline code comments or source-code docstrings
- rewrite non-markdown assets
- run markdown lint or link checker as part of this skill

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [templates](references/category-templates.md)
- [go-templates](references/category-templates-go.md)
- [tf-templates](references/category-templates-terraform.md)

## Workflow

1. List markdown files in `docs/`; resolve baseline mode (`initial-only` by default).
2. Apply baseline:

- IF mode is `initial-only` AND `docs/` has zero markdown files, create missing core docs.
- IF mode is `always`, create missing core docs every run.

3. Choose template by profile (`Terraform > Go > default`, fallback `general`).
4. Resolve target: explicit path; else canonical filename, normalized H1, weighted score (`f*3+h1*2+p*1`, min 2), then lexicographically smallest path.

- `f`: filename exact/close match score (0 or 1)
- `h1`: H1 title exact/close match score (0 or 1)
- `p`: purpose keyword match score (0 or 1)

5. Run case-insensitive duplicate check; duplicates must fail the run.
6. Create/update with naming/structure rules and valid relative links (`./`, `../`, or repo-relative path that exists).
7. IF README has docs-index markers update inside markers; ELSE IF docs section has docs links append there; ELSE skip.
8. Return report using [references/common-output-format.md](references/common-output-format.md).

## Error Handling and Troubleshooting

- If `docs/` does not exist, create `docs/` first and continue.
- If selected template file is missing, fall back to `general` template and record fallback in report.
- If duplicate check fails, return `status: failed` and stop before write actions.
- If README markers are malformed, skip marker update and report as deferred with reason.

## Best Practices

- Run NC-01 duplicate checks before write actions.
- Keep H1 titles in `docs/`.
