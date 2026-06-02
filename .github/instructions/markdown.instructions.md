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

### Documentation (DOC)
- DOC-01 (MUST): README.md Section Order
  - Check: Does README.md follow the order: Title+Badge → Description → Features → Installation/Setup → Usage/Examples → Configuration → License/Contributing?
- DOC-02 (SHOULD): Table of Contents
  - Check: Is a TOC present when the document has three or more H2 sections?
- DOC-03 (SHOULD): Document Splitting
  - Check: Are large documents split into logical sections rather than kept as single monolithic files?
- DOC-04 (SHOULD): Image Optimization
  - Check: Are images PNG for diagrams and JPEG for photos, kept under 500KB, and sized for readability without excessive resolution?

### Revision Process

1. Identify the target section.
2. Review existing content.
3. Check consistency with related files.
4. Apply updates.
5. Verify formatting.

### Code Modification Guidelines

- After changes, prioritize the validation workflow from markdown-validation skill.
- Use individual checks for broken links and table formatting only during debugging.

## Testing and Validation

**Entry point (recommended)**:

```bash
bash <agent-root>/skills/markdown-validation/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
markdownlint-cli2 "docs/**"
markdown-link-check --quiet README.md
```

**Detailed guide**: See markdown-validation skill SKILL.md.

## Security Guidelines

- Do not include sensitive information (tokens, keys, internal URLs, personal data) in documentation.
- Do not make destructive operations the default in command examples; add warnings when required.
- Prefer trustworthy primary sources for external links and avoid unclear shortened URLs.
- If code samples include dummy credentials, explicitly label them as dummy values.
