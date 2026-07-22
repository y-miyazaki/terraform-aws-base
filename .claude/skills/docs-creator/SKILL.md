---
name: docs-creator
description: >-
  Create or improve documentation files with Diataxis-aware placement and consistent naming.
  Use when the user wants to create any new documentation, improve existing docs, write a README,
  or restructure documentation. Also use when asked to "write docs", "improve this doc",
  "add a tutorial", "update the readme", or any request involving markdown documentation authoring,
  even if they don't explicitly say "create documentation".
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.0.0"
---

**UTILITY SKILL** — creates and improves documentation content.

## Input

- Natural language request describing what to document (required)
- `target_file`: explicit path if updating an existing file (optional)

## Output Specification

Return structured report per [references/common-output-format.md](references/common-output-format.md).

## Execution Scope

### USE FOR:

- Create new documentation files (README, specs, architecture, tutorials, how-to guides)
- Improve or rewrite existing documentation content
- Apply consistent structure to unstructured docs

### DO NOT USE FOR:

- Syncing docs after code changes (use docs-updater skill)
- Source code comments or docstrings
- Markdown linting (use markdown-validation skill)
- Auto-generated references (godoc, terraform-docs output)

## Reference Files Guide

- [category-diataxis-mapping.md](references/category-diataxis-mapping.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)

## Workflow

1. **Determine intent**: new document or improvement to existing one?

2. **Resolve placement** per [category-diataxis-mapping.md](references/category-diataxis-mapping.md). README → repository root.

3. **Resolve filename**: kebab-case, lowercase, `.md`. No version numbers. If `target_file` provided and exists, use as-is.

4. **Gather context**: read relevant source files to populate with project-specific content. The document should be self-sufficient — a reader understands the system without reading source code. Remove sections that cannot be populated rather than leaving filler.

5. **Write or update**:

   - New: structure content per Diataxis quadrant intent.
   - Existing: preserve original structure. Additions at end of sections. Restructuring requires explicit user request.
   - Cross-references: relative paths with `.md` extension.

6. **Regenerate `docs/index.md`** if docs/ files changed. Use template in [common-checklist.md](references/common-checklist.md).

7. **Update mkdocs.yml nav** if applicable. Place in correct Diataxis section.

8. **Update README markers** (`<!-- docs-index-start/end -->`) if present.

9. Return report.

### Error Handling

| Condition                | Severity    | Action                     |
| ------------------------ | ----------- | -------------------------- |
| `docs/` missing          | Recoverable | Create directory, continue |
| Ambiguous intent         | Blocking    | Ask user                   |
| mkdocs.yml missing       | Recoverable | Skip nav update            |
| README markers malformed | Recoverable | Skip, note in report       |

### Examples

- "Create architecture doc for caching" → `docs/explanation/caching-architecture.md`
- "Improve the README" → update `README.md` in place
- "Write a getting started tutorial" → `docs/tutorials/getting-started.md`
