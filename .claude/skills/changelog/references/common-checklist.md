# Changelog Checklist

## Type → Section Mapping (Keep a Changelog)

| Commit type (`commits[].type`)           | Unreleased subsection  |
| ---------------------------------------- | ---------------------- |
| `feat`                                   | Added                  |
| `fix`                                    | Fixed                  |
| `docs`                                   | Changed                |
| `refactor`, `perf`, `style`              | Changed                |
| `build`, `ci`, `chore`, `test`, `revert` | Changed                |
| `renovate`, `dependabot`                 | Changed (Dependencies) |
| `chore` with `scope=deps`                | Changed (Dependencies) |
| Other explicit prefixed types            | Changed                |
| Breaking (`!` or `BREAKING CHANGE`)      | note under subsection  |

## Bullet links

When detect JSON includes `repository_url`:

- Each new bullet ends with a parenthesized commit link: opening paren, bracketed 7-char sha, URL `{repository_url}/commit/{full sha}`, closing paren
- Use the commit `subject` as the leading text; when `commits[].scope` is non-empty, prefix with `({scope})` before the subject
- When `repository_url` is empty, omit links (subject-only bullets)

When detect JSON includes `compare_url` and `## [Unreleased]` has no diff link yet:

- Insert one line directly under `## [Unreleased]`: `[Full diff]({compare_url})`
- Do not add compare links under released version sections

## Release sections

When detect JSON includes `releases[]`:

- Add `## [version] - date` only for versions listed in `releases[]` that are not already documented
- Place new release sections immediately below `## [Unreleased]` (newest undocumented release closest to Unreleased)
- Move bullets from `## [Unreleased]` into the release section when their commit `sha` is in `releases[].commit_shas`
- Preserve subsection names (`### Added`, `### Changed`, etc.) when moving bullets
- Do not remove or rewrite released version sections except to promote listed commits out of `## [Unreleased]`
- Footer compare links: `[version]: {repository_url}/compare/{previous_tag_or_version}...{tag_sha}` when `repository_url` is present
- Do not invent versions, tags, or dates outside detect `releases[]`

## Scope

Edit only `changelog_file` from input — see [category-scope.md](category-scope.md).

## Output

- Emit survey or apply shape per [common-output-format.md](common-output-format.md)
- Survey — list intended entries under `### Candidates`; do not edit `CHANGELOG.md`
- Apply — `### Changes` for bullets added; include `## Verification`

## Error Handling

- `skip` true or empty `commits` and `releases` → survey no-op Overview; stop without editing `CHANGELOG.md`
- `changelog_exists` false and edits allowed → create Keep a Changelog template, then add bullets
- Malformed existing changelog → preserve released sections; append/fix only `## [Unreleased]` and new detect `releases[]` sections
