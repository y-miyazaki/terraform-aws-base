# Pre-Creation Checklist & Validation

## Pre-Creation Checklist

### NC-00: Input Schema Validation

- [ ] Input payload is valid JSON and matches the schema defined in `SKILL.md` Input section
- [ ] Required fields exist: `topic`, `document_type`, `profile`
- [ ] `document_type` and `profile` use allowed enum values
- [ ] If `target_file` is provided, it matches `^docs/[a-z0-9-]+\.md$`
- **PASS** if schema validation succeeds, **FAIL** if validation fails

### NC-01: Target File Resolution and Duplicate Handling

- [ ] List all files in `docs/` of the target project
- [ ] If a target file is provided, confirm it exists or that its creation is explicitly intended and it is under `docs/`
- [ ] If no target file is provided, attempt exact filename match on the canonical filename (e.g., `specification.md` for type `specification`)
- [ ] If exact match not found and creation is intended, confirm no file with the same name exists
- [ ] Check duplicates case-insensitively (`document.md` vs `DOCUMENT.md`)
- [ ] If case-only duplicates are found, fail and stop create/update actions
- [ ] If no match and ambiguous, ask user to provide explicit target file path
- **PASS** if target resolution and file state are consistent, **FAIL** on duplicate collisions, invalid target path, or unresolved case-only duplicate conflicts

### NC-02: Filename Follows Naming Rules

- [ ] All characters are lowercase ASCII
- [ ] Word separators are hyphens only (kebab-case; no underscores, no camelCase)
- [ ] No version numbers in the filename
- [ ] Extension is `.md`
- [ ] Numeric prefix used only when documents have a defined reading order
- **SKIP** for `other` type updating existing files (preserve original filename)
- **PASS** if all rules satisfied, **FAIL** if any rule violated

### NC-03: `document_type` Matched

- [ ] Requested topic is matched to a core type or extension type (see `references/category-document-types.md`)
- [ ] Filename pattern follows the selected type's convention
- [ ] A matching template section exists in the selected category template reference file (or `general` fallback is used)
- **PASS** if type mapping and template mapping are explicit, **FAIL** if type is ambiguous or unmatched

### DC-01: Template Applied

- [ ] Template from selected category template reference file matching `document_type` is used as base
- [ ] All `<placeholder>` values are replaced with actual content
- [ ] Sections marked as optional in the template are removed if not applicable (not left as placeholder headings)
- [ ] See the template definition for which sections are optional for each `document_type`
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

- [ ] Apply this check using the selected template definition in `references/category-templates-common-<document_type>.md` (and profile-specific overrides when applicable)
- [ ] For types with technical standard structure (`architecture`, `design`, `module-catalog`, `security-coverage`, `monitoring`, `performance`), include `Overview`, `Prerequisites`, `Architecture/Design`, `Implementation Details`, `Testing/Validation`, `Troubleshooting` (or explicitly mark non-applicable sections)
- [ ] For types with dedicated workflow style (`specification`, `troubleshooting`, `tutorial`, `maintenance-notes`, `improvements`, `design-decisions`, `general`), follow the selected template sections without forcing the technical standard structure
- **PASS** if the document follows its selected template structure, **FAIL** if required sections for that template are missing without rationale
- If the project has its own documentation standard, evaluate against project standard first and use this checklist as fallback
