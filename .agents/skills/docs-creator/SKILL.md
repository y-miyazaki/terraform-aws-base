---
name: docs-creator
description: >-
  Create or improve documentation files with Diataxis-aware placement and consistent naming.
  Use when the user wants to create any new documentation, improve existing docs, write a README,
  or restructure documentation. Also use when asked to "write docs", "improve this doc",
  "add a tutorial", "update the readme", or any request involving markdown documentation authoring,
  even if they don't explicitly say "create documentation". Not for syncing docs after code
  changes, source code docstrings, or Markdown linting.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.0.0"
---

**UTILITY SKILL** — creates and improves documentation content.

## Input

- **Request (required):** natural language describing what to document
- **target_file (optional):** explicit path when updating an existing file

## Output Specification

Return structured report per [references/common-output-format.md](references/common-output-format.md).

## Execution Scope

### USE FOR:

- Create new documentation files (README, specs, architecture, tutorials, how-to guides)
- Improve or rewrite existing documentation content
- Apply consistent structure to unstructured docs

### DO NOT USE FOR:

- Syncing docs after code changes
- Source code comments or docstrings
- Markdown linting
- Auto-generated references (godoc, terraform-docs output)

## Reference Files Guide

- [category-diataxis-mapping.md](references/category-diataxis-mapping.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)

## Workflow

1. **Determine intent**: new document or improvement to existing one? If neither can be inferred, stop with `Status: blocked`.

2. **Detect the existing docs layout**: list the repository's documentation directories and any `docs/index.md`, `mkdocs.yml`, or README docs-index markers.
   - Existing layout found (for example `docs/guides/`, `docs/api/`, or Diataxis directories): place the new file in the matching existing directory.
   - No docs layout yet: use the Diataxis fallback in [category-diataxis-mapping.md](references/category-diataxis-mapping.md).
   - README → repository root.

3. **Resolve filename**: kebab-case, lowercase, `.md`. No version numbers. If `target_file` is provided and exists, use it as-is. If the same filename already exists in a different docs directory, stop and ask the user.

4. **Gather context**: read the sources for the document type before writing. The document should be self-sufficient — a reader understands the system without reading source code. Remove sections that cannot be populated rather than leaving filler.

   | Document type      | Read first                                                                                  |
   | ------------------ | ------------------------------------------------------------------------------------------- |
   | README             | Entry points, build/run/test commands in manifests or task files, top-level config, license |
   | Tutorial / How-to  | The commands, scripts, and config the steps use; existing tests that exercise the same path |
   | Reference          | Public interfaces: CLI flags, config schemas, API signatures, environment variables         |
   | Explanation / spec | Module structure, design records or ADRs, and the code paths that implement the topic       |
   | Improving a doc    | The existing file in full, plus the sources above for its type, to correct stale content    |

5. **Write or update**:

   - New: structure content per the target directory's purpose (Diataxis quadrant intent when the fallback applies).
   - Existing: preserve original structure. Additions at end of sections. Restructuring requires explicit user request.
   - Cross-references: relative paths with `.md` extension.

6. **Update `docs/index.md`** only when it already exists and follows the template in [common-checklist.md](references/common-checklist.md), or when the user asks for it. Otherwise leave it unchanged and note it in the report.

7. **Update mkdocs.yml nav** if the file exists. Place the entry in the section matching the file's directory.

8. **Update README markers** (`<!-- docs-index-start/end -->`) if present.

9. **Self-check** every created or updated file against QV-01..QV-05 in [common-checklist.md](references/common-checklist.md). Fix failures before reporting; list any that remain in `## Notes` with the ItemID.

10. Return the report.

### Error Handling

| Condition                                           | Severity    | Action                                                       |
| --------------------------------------------------- | ----------- | ------------------------------------------------------------ |
| No docs directory exists                            | Recoverable | Create the Diataxis fallback directory needed, continue      |
| Ambiguous intent                                    | Blocking    | Ask user; report `Status: blocked`                           |
| Request matches `DO NOT USE FOR`                    | Blocking    | Do not edit; report `Status: blocked`; explain in `## Notes` |
| `target_file` given but does not exist              | Recoverable | Treat as a new file at that path; note it in the report      |
| Same filename exists in a different docs directory  | Blocking    | Stop and ask user; report `Status: blocked` with both paths  |
| Topic fits no quadrant and no existing directory    | Blocking    | Ask user for an explicit `target_file`                       |
| `docs/index.md` exists but does not follow template | Recoverable | Leave unchanged; note in report                              |
| mkdocs.yml missing                                  | Recoverable | Skip nav update                                              |
| README markers malformed                            | Recoverable | Skip, note in report                                         |
| QV check still fails after one fix attempt          | Recoverable | Keep the file; list the QV ItemID and cause in `## Notes`    |

### Examples

- Prompt: `Create architecture doc for caching` (no existing docs layout) → `docs/explanation/caching-architecture.md` (see [category-diataxis-mapping.md](references/category-diataxis-mapping.md))
- Prompt: `Improve the README` → update `README.md` in place
- Prompt: `Write a getting started tutorial` (no existing docs layout) → `docs/tutorials/getting-started.md`
