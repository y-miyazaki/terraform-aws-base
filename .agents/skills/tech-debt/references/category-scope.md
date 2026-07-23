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

This skill writes technical debt reports and may apply **closed-set** fixes when `may_edit` is `true` and paths are on the resolved allowlist:

- `broken_doc_ref`, `stale_doc` — documentation paths only
- simple `pin_drift` — manifest files only (`package.json`, `go.mod`, etc.)

When `may_edit` is `false`, do not edit any file — survey output only.

When `may_edit` is `true`, write only `report_file` and closed-set fix targets within the resolved allowlist. Read source files outside allowlist for evidence; do not modify paths outside allowlist. Structural or security debt remains report-only — delegate to `refactor` or human.

### Automation caller examples (this repository)

| Key         | Example                                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------------------ |
| `allowlist` | `docs/report/tech-debt/**/*.md`, `docs/**/*.md`, `package.json`, `go.mod` (report + closed-set doc/manifest fixes) |
| `denylist`  | `**/.env`, `**/credentials*`, `**/secrets*`, `**/migration/*.sql`, `**/infrastructure/**`, `src/**`, `.github/**`  |
