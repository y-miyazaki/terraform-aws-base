## Path Scope

### How scope is resolved

| Context                                         | Allowlist                                                                                                             | Denylist                                                             |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Interactive** — no path constraints in prompt | **Unrestricted** within [skill-specific limits](#skill-specific-limits) and [ignore conventions](#ignore-conventions) | **None from skill** — follow repository security instructions        |
| **Interactive** — user `allowlist` / `denylist` | User allowlist globs only (within skill-specific limits)                                                              | User denylist globs                                                  |
| **Automation** — `## Constraints`               | `Allowed paths: …` when the caller supplies an allowlist                                                              | Caller denylist — enforced by the automation verifier (may be empty) |

Skills do **not** ship a repository-wide default denylist. Per-repo deny rules belong in caller configuration, repository instructions (`AGENTS.md`), or explicit user constraints — not in skill references.

Do **not** treat automation-only allowlist examples as interactive scope. See [category-automation-envelope.md](category-automation-envelope.md) on the automation path.

### Ignore conventions

When discovering targets, skip paths ignored by `.gitignore` or `.cursorignore` unless the user explicitly names the path.

Do not edit paths that appear to hold secrets (environment files, credential stores, private keys) even when no denylist is set — follow repository security instructions.

### Skill-specific limits

This skill edits the changelog file only (`CHANGELOG.md` or `changelog_file` from input).

When `may_edit` is `false`, do not edit any file — survey output only.

When `may_edit` is `true`, edit only `changelog_file` and only when that path is within the resolved allowlist (interactive: skill-specific limits; automation: `Allowed paths` when set).
