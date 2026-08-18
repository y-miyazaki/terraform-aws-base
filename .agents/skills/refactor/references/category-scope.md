# Path Scope

## How scope is resolved

| Context                                         | Allowlist                                                | Denylist                                                            |
| ----------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------- |
| **Interactive** — no path constraints in prompt | **Unrestricted**                                         | **None from skill** — follow repository security instructions       |
| **Interactive** — user `allowlist` / `denylist` | User allowlist globs only                                | User denylist globs                                                 |
| **Automation** — `## Constraints`               | `Allowed paths: …` when the caller supplies an allowlist | Caller denylist — enforced by the automation checker (may be empty) |

Do **not** treat automation-only allowlist examples as interactive scope. See [category-automation-envelope.md](category-automation-envelope.md) on the automation path.

Batch behavior (survey all / apply all / do not expand beyond resolved scope): [category-contract.md](category-contract.md).
