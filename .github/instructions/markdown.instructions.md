---
applyTo: "README.md,CONTRIBUTING.md,docs/**/*.md"
description: "AI Assistant Instructions for Markdown Documentation"
---

# AI Assistant Instructions for Markdown

## Scope

- Scope is limited to documentation maintenance for `README.md`, `CONTRIBUTING.md`, and `docs/**/*.md`.
- This file defines repository-specific documentation operations rather than general Markdown theory.

## Standards

### Naming Conventions

| Component    | Rule       | Example                   |
| ------------ | ---------- | ------------------------- |
| File (docs/) | kebab-case | getting-started.md        |
| Image file   | kebab-case | architecture-overview.png |
| Directory    | kebab-case | docs/user-guide/          |

## Guidelines

### README.md Structure

- **DOC-01 (MUST)**: Use the following order - inconsistent ordering makes it harder for first-time users to find required information:
  1. Project Title + Badge
  2. Description
  3. Features (concise list)
  4. Installation/Setup
  5. Usage/Examples
  6. Configuration (when needed)
  7. License/Contributing (when needed)

### Documentation Rules

- **DOC-02 (SHOULD)**: Add a TOC when the document has three or more sections.
- **DOC-03 (SHOULD)**: Split large documents into logical sections.
- **DOC-04 (SHOULD)**: Use appropriate image formats and sizes; avoid unnecessarily high resolution.

### Revision Process

1. Identify the target section.
2. Review existing content.
3. Check consistency with related files.
4. Apply updates.
5. Verify formatting.

### Code Modification Guidelines

- After changes, prioritize the validation workflow from [markdown-validation Skill](../../apm_modules/y-miyazaki/config/.apm/packages/common/.apm/skills/markdown-validation/SKILL.md).
- Use individual checks for broken links and table formatting only during debugging.

## Testing and Validation

**Entry point (recommended)**:

```bash
bash <agent-root>/skills/markdown-validation/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
markdownlint-cli2 "docs/**"
markdown-link-check README.md
```

**Detailed guide**: See [markdown-validation Skill](../../apm_modules/y-miyazaki/config/.apm/packages/common/.apm/skills/markdown-validation/SKILL.md).

## Security Guidelines

- Do not include sensitive information (tokens, keys, internal URLs, personal data) in documentation.
- Do not make destructive operations the default in command examples; add warnings when required.
- Prefer trustworthy primary sources for external links and avoid unclear shortened URLs.
- If code samples include dummy credentials, explicitly label them as dummy values.
