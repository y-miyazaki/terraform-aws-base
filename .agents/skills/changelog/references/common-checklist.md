# loop-changelog Checklist

## Type → Section Mapping (Keep a Changelog)

| Commit type (`commits[].type`) | Unreleased subsection |
| `feat` | Added |
| `fix` | Fixed |
| `docs` | Changed |
| `refactor`, `perf`, `style` | Changed |
| `build`, `ci`, `chore`, `test`, `revert` | Changed |
| `renovate`, `dependabot` | Changed (Dependencies) |
| `chore` with `scope=deps` | Changed (Dependencies) |
| Other explicit prefixed types | Changed |
| Breaking (`!` or `BREAKING CHANGE`) | note under subsection |

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
- Footer compare links: `[version]: {repository_url}/compare/{previous_tag_or_version}...{tag_sha}` when `repository_url` is present
- Do not invent versions, tags, or dates outside detect `releases[]`

## Scope Guards

- Edit only `changelog_file` from input per `category-scope.md` (loop: must match caller `LOOP_ALLOWLIST`)
- Do not remove or rewrite released version sections except to promote listed commits out of `## [Unreleased]`
- Loop state (`.loop/state-*.json`) is committed by finalize — do not edit state files

## Output

- Emit all report sections per `common-output-format.md`
- List every commit SHA processed in Summary
- List every release version promoted in Summary

## Error Handling

- `skip` true or empty `commits` and `releases` → report with Summary `No unreleased changelog commits`; stop
- `changelog_exists` false → create Keep a Changelog template, then add bullets
- Malformed existing changelog → preserve released sections; append/fix only `## [Unreleased]` and new detect `releases[]` sections

