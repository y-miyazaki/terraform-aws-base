# Markdown Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `markdownlint-cli2` — Markdown syntax and style enforcement
2. `markdown-link-check` — broken link detection

## markdownlint-cli2 (MDL)

- MDL-01 (SHOULD): Heading hierarchy is consistent (no skipped levels)
- MDL-02 (SHOULD): No trailing spaces or hard tabs
- MDL-03 (SHOULD): Code blocks have language specifiers where applicable
- MDL-04 (SHOULD): List marker style is consistent within a file
- MDL-05 (SHOULD): Blank line rules around headings and code blocks followed
- MDL-06 (SHOULD): Table formatting is valid
- MDL-07 (SHOULD): No bare URLs (use `[text](url)` format)

## markdown-link-check (LINK)

- LINK-01 (SHOULD): All relative file paths resolve to existing files
- LINK-02 (SHOULD): All anchor (`#`) references match headings in the target file
- LINK-03 (SHOULD): External URLs return HTTP 2xx (non-redirected)
- LINK-04 (SHOULD): No dead links from renamed or deleted files

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
