# Markdown Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `markdownlint` — Markdown syntax and style enforcement
2. `markdown-link-check` — broken link detection

## Checks by Tool

### markdownlint
- MDL-01: Heading hierarchy is consistent (no skipped levels)
- MDL-02: No trailing spaces or hard tabs
- MDL-03: Code blocks have language specifiers where applicable
- MDL-04: List marker style is consistent within a file
- MDL-05: Blank line rules around headings and code blocks followed
- MDL-06: Table formatting is valid
- MDL-07: No bare URLs (use `[text](url)` format)

### markdown-link-check
- LINK-01: All relative file paths resolve to existing files
- LINK-02: All anchor (`#`) references match headings in the target file
- LINK-03: External URLs return HTTP 2xx (non-redirected)
- LINK-04: No dead links from renamed or deleted files

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
