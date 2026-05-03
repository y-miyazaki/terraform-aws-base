# Pre-Creation Checklist & Validation

## Pre-Creation Checklist

### NC-01: Target File Resolution and Duplicate Handling

- [ ] List all files in `docs/` of the target project
- [ ] For `create` mode: confirm no file with the same name exists
- [ ] For `update` mode: confirm target file exists and is under `docs/`
- [ ] Check duplicates case-insensitively (`document.md` vs `DOCUMENT.md`)
- **PASS** if mode and file state are consistent, **FAIL** on create-mode collision, missing update target, or case-only duplicate risk

### NC-02: Filename Follows Naming Rules

- [ ] All characters are lowercase ASCII
- [ ] Word separators are underscores only (no hyphens, no camelCase)
- [ ] No version numbers in the filename
- [ ] Extension is `.md`
- [ ] Numeric prefix used only when documents have a defined reading order
- **PASS** if all rules satisfied, **FAIL** if any rule violated

### NC-03: Document Type Matched

- [ ] Requested topic is matched to a core type, extension type, or project-defined custom type
- [ ] Filename pattern follows the selected type's convention from the Workflow table
- [ ] If custom type is used, a matching template section exists (or `general` fallback is used)
- **PASS** if type mapping and template mapping are explicit, **FAIL** if type is ambiguous or unmatched

### DC-01: Template Applied

- [ ] Template from `references/category-templates.md` matching the document type is used as base
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

- [ ] Technical docs include `Overview`
- [ ] Technical docs include `Prerequisites` (or clearly state not applicable)
- [ ] Technical docs include `Architecture/Design`
- [ ] Technical docs include `Implementation Details`
- [ ] Technical docs include `Testing/Validation`
- [ ] Technical docs include `Troubleshooting`
- **PASS** if required structure is present or explicitly marked not applicable, **FAIL** if major sections are missing without rationale
- If the project has its own documentation standard, evaluate against project standard first and use this checklist as fallback
