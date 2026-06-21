## other

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
This template applies to existing documents that do not match predefined document types.

### When to use

- Updating a manually created document that has no matching `document_type`
- Improving quality and consistency of existing documentation
- Bringing ad-hoc docs up to repository documentation standards

### Update Guidelines

When updating an existing document:

1. **Preserve the original structure** — do not reorganize sections unless explicitly requested
2. **Preserve the author's intent** — improve clarity without changing meaning
3. **Apply quality standards** — fix formatting, add missing code block language identifiers, ensure relative links
4. **Fill gaps** — add missing context, prerequisites, or troubleshooting where appropriate
5. **Remove stale content** — flag or remove outdated information with a note

### Quality Checklist for Updates

- [ ] H1 title is present and descriptive
- [ ] Purpose/overview paragraph exists after H1
- [ ] Code blocks have language identifiers
- [ ] Internal links use relative paths (`./filename.md`)
- [ ] No placeholder text or TODO markers remain
- [ ] Sections are not left empty — remove or populate

### Minimal Structure (apply only if document lacks basic structure)

```markdown
# <Document Title>

<Purpose and scope of this document.>

## Overview

<High-level summary of the content.>

## <Existing Sections>

<Preserve and improve existing content.>

## Related Documents (Optional)

- <related doc>
```

### Decision Prompts

Consider:
- What is the document's current purpose and audience?
- Which sections are outdated or incomplete?
- Are there broken links or stale references?
- Does the document follow repository conventions (kebab-case filenames, no frontmatter)?
