# Pre-Creation Checklist & Validation

## Pre-Creation Checklist

### NC-00: Core Docs Baseline

- [ ] Resolve baseline mode (`initial-only` default, `always` when explicitly provided)
- [ ] Check whether `docs/architecture.md` and `docs/specification.md` exist
- [ ] For `initial-only`, enforce core docs creation only when `docs/` has zero `.md` files
- [ ] For `always`, enforce core docs creation in every run when missing
- **PASS** if baseline mode rules are satisfied, **FAIL** if required core docs are missing after processing

### NC-01: Target File Resolution and Duplicate Handling

- [ ] List all files in `docs/` of the target project
- [ ] If a target file is provided, confirm it exists or that its creation is explicitly intended and it is under `docs/`
- [ ] If no target file is provided, determine whether an existing document should be updated before creating a new one
- [ ] Apply deterministic match order when no target file is provided:
	1. canonical filename exact match
	2. normalized H1 exact match
	3. weighted keyword score >= 2 where filename*3 + H1*2 + purpose*1
	4. keyword extraction rule is applied consistently (lowercase, split by spaces/underscores/hyphens/slashes/dots, remove stopwords, remove tokens length <= 3)
	5. tie-breaker: lexicographically smallest path
- [ ] Verify weighted keyword scoring with an example:
  - topic: `performance monitoring`
  - `monitoring.md`: filename overlap=1, H1 overlap=0, purpose overlap=0 => score=3
  - `performance.md`: filename overlap=1, H1 overlap=0, purpose overlap=0 => score=3
  - same score => choose lexicographically smallest path
- [ ] For a new file, confirm no file with the same name exists
- [ ] Check duplicates case-insensitively (`document.md` vs `DOCUMENT.md`)
- [ ] If case-only duplicates are found, fail and stop create/update actions
- **PASS** if target resolution and file state are consistent, **FAIL** on duplicate collisions, invalid target path, or unresolved case-only duplicate conflicts

### NC-02: Filename Follows Naming Rules

- [ ] All characters are lowercase ASCII
- [ ] Word separators are underscores only (no hyphens, no camelCase)
- [ ] No version numbers in the filename
- [ ] Extension is `.md`
- [ ] Numeric prefix used only when documents have a defined reading order
- **PASS** if all rules satisfied, **FAIL** if any rule violated

### NC-03: Document Type Matched

- [ ] Requested topic is matched to a core type, extension type, or project-defined custom type
- [ ] Types marked `Required = Yes` in the Workflow table are present or created in this run
- [ ] Filename pattern follows the selected type's convention from the Workflow table
- [ ] If custom type is used, a matching template section exists in a selected category template reference file (or `general` fallback is used)
- **PASS** if type mapping and template mapping are explicit, **FAIL** if type is ambiguous or unmatched

### DC-01: Template Applied

- [ ] Template from selected category template reference file matching the document type is used as base
- [ ] All `<placeholder>` values are replaced with actual content
- [ ] Empty optional sections are removed (not left as placeholder headings)
- **PASS** if template applied and placeholders replaced, **FAIL** if placeholders remain

### DC-02: Structure Rules Satisfied

- [ ] First line is H1 heading (human-readable title, not filename)
- [ ] Purpose paragraph follows H1 immediately
- [ ] H2 sections use consistent noun or imperative phrases within the file
- [ ] No YAML frontmatter block in the generated file
- **PASS** if all rules satisfied, **FAIL** if any rule violated

### DC-03: Cross-References Valid

- [ ] Links to other `docs/` files use relative paths: `./filename.md`
- [ ] All referenced files exist in `docs/`
- **PASS** if all links are relative and targets exist, **FAIL** if absolute paths used or target files missing

### DC-04: Code Block Language Identifiers

- [ ] Every code block has a language identifier (` ```sh `, ` ```hcl `, ` ```go `, etc.)
- **PASS** if all code blocks have identifiers, **FAIL** if any code block is bare (` ``` ` with no language)

### DC-05: Technical Documentation Structure Alignment

- [ ] Apply this check using the selected template definition in `references/category-templates.md`
- [ ] For types with technical standard structure (`architecture`, `design`, `module_catalog`, `security_coverage`, `monitoring`, `performance`), include `Overview`, `Prerequisites`, `Architecture/Design`, `Implementation Details`, `Testing/Validation`, `Troubleshooting` (or explicitly mark non-applicable sections)
- [ ] For types with dedicated workflow style (`specification`, `troubleshooting`, `maintenance_notes`, `improvements`, `design_decisions`, `general`), follow the selected template sections without forcing the technical standard structure
- **PASS** if the document follows its selected template structure, **FAIL** if required sections for that template are missing without rationale
- If the project has its own documentation standard, evaluate against project standard first and use this checklist as fallback
