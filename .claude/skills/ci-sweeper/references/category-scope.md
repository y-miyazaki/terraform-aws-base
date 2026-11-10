# Path Scope

## How scope is resolved

| Context                                         | Allowlist                                                               | Denylist                                                            |
| ----------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Interactive** — no path constraints in prompt | **Unrestricted** within [skill-specific limits](#skill-specific-limits) | **None from skill** — follow repository security instructions       |
| **Interactive** — user `allowlist` / `denylist` | User allowlist globs only (within skill-specific limits)                | User denylist globs                                                 |
| **Automation** — `## Constraints`               | `Allowed paths: …` when the caller supplies an allowlist                | Caller denylist — enforced by the automation checker (may be empty) |

Skills do **not** ship a repository-wide default denylist.

Do **not** treat automation-only allowlist examples as interactive scope. See [category-automation-envelope.md](category-automation-envelope.md) on the automation path.

Do not edit paths that appear to hold secrets (environment files, credential stores, private keys) even when no denylist is set — follow repository security instructions.

## Skill-specific limits

- When more than three failures are present, fix only the first `regression`; defer the rest
- A fix requiring more than five files gets no edits (Watch in survey, Deferred in apply)
