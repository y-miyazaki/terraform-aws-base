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

- Fix at most one `regression` when more than three failures are present
- Defer fixes requiring more than five files as Watch
