# Pre-Creation Checklist & Validation

## Pre-Creation Checklist

### NC-00: Input Schema Validation

- [ ] Input payload is valid JSON and matches the schema defined in `SKILL.md` Input section
- [ ] Required fields exist: `topic`, `document_type`, `profile`
- [ ] `document_type` and `profile` use allowed enum values
- [ ] If `target_file` is provided and `document_type` is NOT `other` or `general`, it matches `^docs/(tutorials|how-to|reference|explanation)/[a-z0-9-]+\.md$`
- [ ] If `document_type` is `other` or `general`, `target_file` is a valid `.md` path (no further regex constraint)
- **PASS** if schema validation succeeds, **FAIL** if validation fails

### NC-01: Target File Resolution and Duplicate Handling

- [ ] List all files in `docs/` of the target project (including `tutorials/`, `how-to/`, `reference/`, `explanation/` subdirectories)
- [ ] If a target file is provided, confirm it exists or that its creation is explicitly intended and it is under the correct Diataxis subdirectory
- [ ] If no target file is provided, resolve directory from `category-diataxis-mapping.md` and use `{document_type}.md` as filename
- [ ] If exact match not found and creation is intended, confirm no file with the same name exists across subdirectories
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

- [ ] Requested topic is matched to a document type and Diataxis quadrant (see `references/category-diataxis-mapping.md`)
- [ ] Target directory follows the Diataxis mapping (`docs/tutorials/`, `docs/how-to/`, `docs/reference/`, `docs/explanation/`)
- [ ] A matching template exists as `category-templates-common-{document_type}.md` (or `general` fallback is used)
- **PASS** if type mapping and template mapping are explicit, **FAIL** if type is ambiguous or unmatched

### DC-01: Template Applied

- [ ] Template from selected category template reference file matching `document_type` is used as base
- [ ] All guide comments (`<!-- Answer: ... -->`) are addressed with concrete content
- [ ] Structural placeholders (`<Title>`, `<Component>`) are replaced with actual names
- [ ] Sections marked as optional in the template are removed if not applicable (not left as empty headings)
- **PASS** if template applied and all guide comments resolved, **FAIL** if guide comments remain or sections are empty

### DC-02: Structure Rules Satisfied

- [ ] First line is H1 heading (human-readable title, not filename)
- [ ] Purpose paragraph follows H1 immediately
- [ ] H2 sections use consistent noun or imperative phrases within the file
- [ ] No YAML frontmatter block in the generated file
- **PASS** if all rules satisfied, **FAIL** if any rule violated

### DC-03: Cross-References Valid

- [ ] Links to other `docs/` files use relative paths (e.g., `../explanation/architecture.md`, `../how-to/troubleshooting.md`)
- [ ] All referenced files exist in `docs/` subdirectories
- **PASS** if all links are relative and targets exist, **FAIL** if absolute paths used or target files missing

### DC-04: Code Block Language Identifiers

- [ ] Every code block has a language identifier (` ```sh `, ` ```hcl `, ` ```go `, etc.)
- **PASS** if all code blocks have identifiers, **FAIL** if any code block is bare (` ``` ` with no language)

### DC-05: Template Structure Alignment

- [ ] Apply this check using the selected template definition in `references/category-templates-common-{document_type}.md` (and profile-specific overrides when applicable)
- [ ] Generated document follows the section structure defined in the selected template
- [ ] Required sections from the template are present; optional sections are either populated or removed
- [ ] No sections are added that contradict the template's stated "Avoid" guidance
- **PASS** if the document follows its selected template structure, **FAIL** if required sections for that template are missing without rationale
- If the project has its own documentation standard, evaluate against project standard first and use this checklist as fallback

### DC-06: Content Substance

- [ ] Every section contains project-specific information derived from source code, config, or user input
- [ ] No section consists solely of generic advice applicable to any project
- [ ] Technical claims reference specific files, functions, or configurations
- [ ] The first paragraph after H1 answers "what is this and why should I read it" for this specific project
- **PASS** if all sections contain concrete, project-specific content, **FAIL** if generic filler detected

## docs/index.md Generation Template

When regenerating `docs/index.md`, use this structure:

```markdown
# Documentation Index

Directory layout follows [Diataxis](https://diataxis.fr/).

## Tutorials

_Learning-oriented walkthroughs._

- [filename.md](tutorials/filename.md) - One-line description

## How-To

_Task-oriented guides for specific goals._

- [filename.md](how-to/filename.md) - One-line description

## Reference

_Information-oriented technical descriptions._

- [filename.md](reference/filename.md) - One-line description

## Explanation

_Understanding-oriented discussion of concepts and decisions._

- [filename.md](explanation/filename.md) - One-line description
```

Rules:
- Omit empty quadrant sections (no placeholder text for missing categories)
- List files alphabetically within each section
- Description is the document's H1 title or first sentence of purpose paragraph
- Non-Diataxis directories (e.g., `agents/`, `report/`) get their own H2 section after the four quadrants
