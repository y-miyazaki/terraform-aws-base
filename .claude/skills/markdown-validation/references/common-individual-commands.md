# Debugging Reference: Individual Commands

Use these commands only to get details after `scripts/validate.sh` reports a failure. Run them from the repository root against the files the script reported. They are read-only; do not add `--fix` unless the user asks for fixes.

## markdownlint-cli2

`scripts/validate.sh` hides markdownlint-cli2 output. Re-run it to see rule IDs and line numbers:

```bash
# One file
markdownlint-cli2 README.md

# A directory (quote the glob so markdownlint-cli2 expands it)
markdownlint-cli2 "docs/**/*.md"
```

markdownlint-cli2 discovers `.markdownlint-cli2.yaml`, `.markdownlint-cli2.jsonc`, or `.markdownlint.*` from the working directory; no flag is needed.

Output lines look like `docs/guide.md:12 MD022/blanks-around-headings ...`. Map rule IDs to checklist items:

| Rule IDs            | Checklist item |
| ------------------- | -------------- |
| MD001               | MDL-01         |
| MD009, MD010        | MDL-02         |
| MD040               | MDL-03         |
| MD004, MD007, MD029 | MDL-04         |
| MD022, MD031, MD032 | MDL-05         |
| MD055, MD056        | MDL-06         |
| MD034               | MDL-07         |

Rules not in this table (for example MD013, MD024, MD041) have no checklist item; report them with their rule ID only.

## markdown-link-check

`scripts/validate.sh` stops at the first file with a broken link. Re-run per file to list every broken link:

```bash
# One file, with the repository config when present
markdown-link-check -c .markdown-link-check.json README.md

# Without a config file
markdown-link-check README.md
```

Each failing link is printed as `[✖] <url> → Status: <code>`. A relative path or anchor failure maps to LINK-01 / LINK-02 / LINK-04; an external URL failure maps to LINK-03.

## Examples of Common Failures

### Missing blank line before heading (MD022)

```markdown
<!-- ✗ Incorrect -->

Some content

## Heading

<!-- ✓ Correct -->

Some content

## Heading
```

### Skipped heading level (MD001)

```markdown
<!-- ✗ Incorrect -->

# Title

### Section

<!-- ✓ Correct -->

# Title

## Section

### Subsection
```
