# docs-creator Checklist

## Quality Validation

### QV-01: Content Substance

- [ ] Every section contains project-specific information (not generic advice)
- [ ] Technical claims reference specific files, functions, or configurations
- [ ] No empty headings or placeholder text remain
- **PASS** if all sections have concrete content

### QV-02: Structure Appropriate

- [ ] First line is H1 heading (descriptive title, not filename)
- [ ] Purpose paragraph follows H1 immediately
- [ ] Structure matches the Diataxis quadrant intent
- [ ] No YAML frontmatter added
- **PASS** if structure is clear and appropriate

### QV-03: Cross-References Valid

- [ ] Links to other docs/ files use relative paths with `.md` extension
- [ ] All referenced files exist
- [ ] Code blocks have language identifiers
- **PASS** if all links resolve and code blocks are tagged

### QV-04: Naming and Placement

- [ ] Filename is kebab-case, lowercase, `.md`
- [ ] File is in the correct Diataxis directory
- [ ] No duplicate filename across docs/ subdirectories
- **PASS** if naming rules satisfied

### QV-05: Index and Nav Consistency

- [ ] `docs/index.md` regenerated if docs/ files changed
- [ ] mkdocs.yml nav updated if applicable
- [ ] README markers updated if applicable
- **PASS** if all auxiliary files are in sync

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
- Omit empty quadrant sections
- List files alphabetically within each section
- Description is the document's H1 title or first sentence of purpose paragraph
- Non-Diataxis directories (e.g., `agents/`, `report/`) get their own H2 section after the four quadrants
