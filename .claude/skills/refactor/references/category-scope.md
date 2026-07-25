## Path Scope

### How scope is resolved

| Context                                         | Allowlist                                                                                                             | Denylist                                                             |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Interactive** — no path constraints in prompt | **Unrestricted** within [skill-specific limits](#skill-specific-limits) and [ignore conventions](#ignore-conventions) | **None from skill** — follow repository security instructions        |
| **Interactive** — user `allowlist` / `denylist` | User allowlist globs only (within skill-specific limits)                                                              | User denylist globs                                                  |
| **Automation** — `## Constraints`               | `Allowed paths: …` when the caller supplies an allowlist                                                              | Caller denylist — enforced by the automation verifier (may be empty) |

Skills do **not** ship a repository-wide default denylist.

Do **not** treat automation-only allowlist examples as interactive scope. See [category-automation-envelope.md](category-automation-envelope.md) on the automation path.

### Ignore conventions

When discovering targets, skip paths ignored by `.gitignore` or `.cursorignore` unless the user explicitly names the path.

Do not edit paths that appear to hold secrets (environment files, credential stores, private keys) even when no denylist is set — follow repository security instructions.

### Skill-specific limits

- Survey all in-scope candidates in one run; apply all marked **apply** in Phase B — do not expand into repo-wide cleanup beyond resolved scope
- Generated agent trees (`.agents/`, `.claude/`, `.cursor/`, …) are not edit targets; when the consumer uses a package source layout, edit those sources instead of generated trees
