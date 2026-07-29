# Changelog Checklist

Gate IDs are for agent self-check and Skipped/Deferred reasons. Row identity in reports remains commit / subject / section — not these IDs.

## Type mapping

### MAP-01: Keep a Changelog section assignment

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

- [ ] Each new bullet uses the subsection for its commit `type`
- [ ] Breaking changes carry a note under the matching subsection
- **PASS** if mapping matches the table for every candidate row

## Bullet links

### LINK-01: Commit and compare URLs

When detect JSON includes `repository_url`:

- [ ] Each new bullet ends with a parenthesized commit link: opening paren, bracketed 7-char sha, URL `{repository_url}/commit/{full sha}`, closing paren
- [ ] Use the commit `subject` as the leading text; when `commits[].scope` is non-empty, prefix with `({scope})` before the subject
- [ ] When `repository_url` is empty, omit links (subject-only bullets)

When detect JSON includes `compare_url` and `## [Unreleased]` has no diff link yet:

- [ ] Insert one line directly under `## [Unreleased]`: `[Full diff]({compare_url})`
- [ ] Do not add compare links under released version sections
- **PASS** if links follow detect JSON when URLs are present

## Release sections

### REL-01: Release promotion from detect

When detect JSON includes `releases[]`:

- [ ] Add `## [version] - date` only for versions listed in `releases[]` that are not already documented
- [ ] Place new release sections immediately below `## [Unreleased]` (newest undocumented release closest to Unreleased)
- [ ] Move bullets from `## [Unreleased]` into the release section when their commit `sha` is in `releases[].commit_shas`
- [ ] Preserve subsection names (`### Added`, `### Changed`, etc.) when moving bullets
- [ ] Do not remove or rewrite released version sections except to promote listed commits out of `## [Unreleased]`
- [ ] Footer compare links: `[version]: {repository_url}/compare/{previous_tag_or_version}...{tag_sha}` when `repository_url` is present
- [ ] Do not invent versions, tags, or dates outside detect `releases[]`
- **PASS** if promotion matches `releases[]` only

## Scope

### SCOPE-01: changelog_file only

- [ ] Edit only `changelog_file` from input — see [category-scope.md](category-scope.md)
- **PASS** if no paths outside `changelog_file` are edited

## Output

### OUT-01: Survey vs apply shape

- [ ] Emit survey or apply shape per [common-output-format.md](common-output-format.md)
- [ ] Survey — list intended entries under `### Candidates`; do not edit `CHANGELOG.md`
- [ ] Apply — `### Changes` for bullets added; include `## Verification`
- **PASS** if survey and apply shapes are not mixed

## Error handling

- `skip` true or empty `commits` and `releases` → survey no-op Overview; stop without editing `CHANGELOG.md`
- `changelog_exists` false and edits allowed → create Keep a Changelog template, then add bullets
- Malformed existing changelog → preserve released sections; append/fix only `## [Unreleased]` and new detect `releases[]` sections
