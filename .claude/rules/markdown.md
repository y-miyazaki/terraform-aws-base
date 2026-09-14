---
paths:
  - "README.md"
  - "CONTRIBUTING.md"
  - "docs/**/*.md"
  - "mkdocs.yml"
---

# Markdown Instructions

## Scope

- Scope covers repository documentation maintenance and MkDocs navigation sync.
- This file defines repository-specific documentation operations rather than general Markdown theory.

## Standards

### Naming Conventions

| Component    | Rule       | Example                   |
| ------------ | ---------- | ------------------------- |
| File (docs/) | kebab-case | getting-started.md        |
| Image file   | kebab-case | architecture-overview.png |
| Directory    | kebab-case | docs/user-guide/          |

## Guidelines

### Structure and Formatting (DOC)

- DOC-00 (MUST): Modify only the relevant section without unnecessary reorganization
- DOC-01 (SHOULD): Split the document when a single file becomes difficult to navigate, review, or maintain
- DOC-02 (SHOULD): Use PNG for diagrams and JPEG for photos; keep under 500KB when size metadata is available
- DOC-03 (SHOULD): Add to an existing document before creating a new file or directory
- DOC-04 (SHOULD): Preserve important context or rationale when simplifying documentation
- DOC-05 (MUST): In `docs/`, use relative `.md` links with the target document's title as link text — not file names, paths, raw URLs, or generic labels such as "here"

### Terminology and Consistency (TERM)

- TERM-01 (MUST): Use official product names (for example PostgreSQL, GitHub Actions, Terraform in prose)
- TERM-02 (SHOULD): Use terms consistently within the same section or paragraph without unexplained alternation
- TERM-03 (SHOULD): Spell out abbreviations on first use with the short form in parentheses
- TERM-04 (SHOULD): Keep subjects explicit — avoid ambiguous "it", "this", or "that" without a clear antecedent
- TERM-05 (SHOULD): Keep version numbers, dates, and URLs current; do not invent versions or dates
- TERM-06 (SHOULD): Write procedures in active voice with a clear actor
- TERM-07 (SHOULD): Include a language identifier on fenced code blocks
- TERM-08 (SHOULD): Verify commands, file paths, and documented behaviors against the current repository
- TERM-09 (MUST): Document only features, commands, file paths, and workflows supported by repository contents or provided context
- TERM-10 (SHOULD): Avoid directional references ("above", "below", "前述の", "後述の"); use explicit section links instead
- TERM-11 (MUST): State required tools, permissions, and environmental prerequisites before step-by-step instructions

### Writing Style (STYLE)

- STYLE-01 (SHOULD): Convey one idea per sentence; split compound sentences when they address distinct points
- STYLE-02 (SHOULD): Remove filler adverbs and roundabout phrases ("in order to" → "to", "make use of" → "use")
- STYLE-03 (SHOULD): Remove or quantify subjective claims ("simple", "easy", "fast", "lightweight")
- STYLE-04 (SHOULD): Place conditional clauses before the action ("If X, do Y" not "Do Y if X")
- STYLE-05 (SHOULD): Address instructions to "you" rather than "we" or passive constructions

### Code Modification Guidelines

- When adding, deleting, or renaming files under `docs/`, update the `nav` section in `mkdocs.yml` to keep navigation in sync.
- When revising documentation: identify the target section, review existing content, check consistency with related files, apply updates, and verify formatting.

## Testing and Validation

On-demand validation: see markdown-validation skill SKILL.md.

## Security Guidelines

- Do not include sensitive information (tokens, keys, internal URLs, personal data) in documentation.
- Do not expose internal infrastructure details, private repository URLs, or organization-specific identifiers (AWS account IDs, internal hostnames, Slack/Jira URLs).
- Do not make destructive operations the default in command examples; add warnings when required.
- Prefer trustworthy primary sources for external links and avoid unclear shortened URLs.
- If code samples include dummy credentials, explicitly label them as dummy values.
