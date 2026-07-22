## Input Schema

Provided via prompt context by the calling workflow (loop-prompt-generate action).

```json
{
  "changelog_file": "CHANGELOG.md",
  "changelog_exists": false,
  "commit_range": "abc1234..def5678",
  "compare_url": "https://github.com/owner/repo/compare/abc1234..def5678",
  "level": "L2",
  "repository": "owner/repo",
  "repository_url": "https://github.com/owner/repo",
  "skip": false,
  "commits": [
    {
      "sha": "def5678",
      "type": "feat",
      "scope": "changelog",
      "breaking": false,
      "subject": "add loop-changelog workflow"
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

| Field | Type | Description |
| `changelog_file` | string | Repository-relative path to update |
| `changelog_exists` | boolean | When false, create Keep a Changelog template before editing |
| `commit_range` | string | SHA range that triggered detection |
| `compare_url` | string | Optional GitHub compare URL for the active `commit_range` (empty when unknown) |
| `level` | enum | Operating level: `L1` (report only), `L2` (edit + PR), `L3` (edit + auto-merge) |
| `repository` | string | `owner/repo` when resolved (Actions env or git remote) |
| `repository_url` | string | Web base URL for commit links (no trailing slash) |
| `skip` | boolean | When true, no unreleased changelog-worthy commits or undocumented releases |
| `commits` | array | Commits to summarize under `## [Unreleased]` (may be empty) |
| `commits[].sha` | string | Full commit SHA |
| `commits[].type` | string | Prefix type (`feat`, `fix`, `renovate`, `chore`, …) |
| `commits[].scope` | string | Optional scope from subject line |
| `commits[].breaking` | boolean | Whether the commit is marked breaking |
| `commits[].subject` | string | Subject text after the `type(scope):` prefix |
| `releases` | array | Undocumented release versions to promote into `## [x.y.z] - date` sections (may be empty) |
| `releases[].version` | string | Semantic version without leading `v` |
| `releases[].tag` | string | Git tag name (typically `v{version}`) |
| `releases[].tag_sha` | string | Commit SHA the tag points to (or anchor SHA when tag is absent) |
| `releases[].date` | string | Release date (`YYYY-MM-DD`) |
| `releases[].commit_shas` | array | Commit SHAs whose bullets move from `## [Unreleased]` into this release |

### Operating levels

| Level | Agent behavior for loop-changelog                               |
| ----- | --------------------------------------------------------------- |
| `L1`  | Emit changelog report only — do not edit `changelog_file`       |
| `L2`  | Emit report and edit `changelog_file` within allowlist          |
| `L3`  | Same file edits as `L2`; caller may auto-merge the changelog PR |

Path allowlist is injected in the implementer prompt `## Constraints` section from the caller (`LOOP_ALLOWLIST`). Denylist is a caller `denylist` input enforced by loop-execute verifier. When `LOOP_ALLOWLIST` is absent, no allowlist restriction within skill-specific limits — see [category-scope.md](category-scope.md).

