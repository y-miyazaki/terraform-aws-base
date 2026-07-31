# Exit Codes and Error Envelope

| Exit code | Meaning                                                                      |
| --------- | ---------------------------------------------------------------------------- |
| 0         | Success — stdout is detect script JSON. Parse per schema below and continue. |
| 1         | Fatal — stdout is detect script error JSON. Read stdout, then **stop**.      |

Detect scripts list `jq` as a required dependency. When `jq` is unavailable at fatal-error emission, stdout may be only `{status, skip, message}` (bootstrap JSON) instead of the full skill-specific field set below.

## Detect script stdout (exit 0 only)

Field set emitted by this skill's detect script or an equivalent caller-supplied JSON object.

```json
{
  "status": "ok",
  "scope": "range",
  "since": "abc1234",
  "changelog_file": "CHANGELOG.md",
  "changelog_exists": false,
  "commit_range": "abc1234..def5678",
  "compare_url": "https://github.com/owner/repo/compare/abc1234..def5678",
  "repository": "owner/repo",
  "repository_url": "https://github.com/owner/repo",
  "skip": false,
  "commits": [
    {
      "sha": "def5678",
      "type": "feat",
      "scope": "changelog",
      "breaking": false,
      "subject": "add changelog workflow"
    }
  ],
  "releases": [
    {
      "version": "1.8.16",
      "tag": "v1.8.16",
      "tag_sha": "abc1234",
      "date": "2026-07-12",
      "commit_shas": ["abc1234", "def5678"]
    }
  ]
}
```

| Field                    | Type    | Description                                                                               |
| ------------------------ | ------- | ----------------------------------------------------------------------------------------- |
| `status`                 | string  | `ok` on success path                                                                      |
| `scope`                  | string  | Detect scope (`all` or `range`)                                                           |
| `since`                  | string  | Range start ref when `scope` is `range` (may be empty)                                    |
| `changelog_file`         | string  | Repository-relative path to update                                                        |
| `changelog_exists`       | boolean | When false, create Keep a Changelog template before editing                               |
| `commit_range`           | string  | SHA range that triggered detection                                                        |
| `compare_url`            | string  | Optional GitHub compare URL for the active `commit_range` (empty when unknown)            |
| `repository`             | string  | `owner/repo` when resolved (Actions env or git remote)                                    |
| `repository_url`         | string  | Web base URL for commit links (no trailing slash)                                         |
| `skip`                   | boolean | When true, no unreleased changelog-worthy commits or undocumented releases                |
| `commits`                | array   | Commits to summarize under `## [Unreleased]` (may be empty)                               |
| `commits[].sha`          | string  | Full commit SHA                                                                           |
| `commits[].type`         | string  | Prefix type (`feat`, `fix`, `renovate`, `chore`, …)                                       |
| `commits[].scope`        | string  | Optional scope from subject line                                                          |
| `commits[].breaking`     | boolean | Whether the commit is marked breaking                                                     |
| `commits[].subject`      | string  | Subject text after the `type(scope):` prefix                                              |
| `releases`               | array   | Undocumented release versions to promote into `## [x.y.z] - date` sections (may be empty) |
| `releases[].version`     | string  | Semantic version without leading `v`                                                      |
| `releases[].tag`         | string  | Git tag name (typically `v{version}`)                                                     |
| `releases[].tag_sha`     | string  | Commit SHA the tag points to (or anchor SHA when tag is absent)                           |
| `releases[].date`        | string  | Release date (`YYYY-MM-DD`)                                                               |
| `releases[].commit_shas` | array   | Commit SHAs whose bullets move from `## [Unreleased]` into this release                   |

`commits` and `releases` may be empty arrays.

Path allowlist is not a JSON field. When present, it arrives in `## Constraints` — see [category-scope.md](category-scope.md).
