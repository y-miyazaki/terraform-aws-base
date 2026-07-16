---
paths:
  - "**/*.sh"
  - "**/*.bats"
---

# AI Assistant Instructions for Bats

## Scope

- Scope covers authoring Bats suites (`*.bats`) and applies when editing Shell scripts (`*.sh`) that require pairing a suite.
- Shell script implementation rules remain in the companion Shell Script rules (stem `shell-script`); this file defines test-suite conventions only.
- When adding or materially changing a shell script or sourced library, add or update the matching Bats suite in the same change (see companion Shell Script rules TEST-00).
- After `apm install`, stem `bats` is distributed as `.cursor/rules/bats.mdc` (Cursor) or `.claude/rules/bats.md` (Claude) — not as `bats.instructions.md`.

## Standards

### Naming Conventions

| Component        | Rule                                              | Example                             |
| ---------------- | ------------------------------------------------- | ----------------------------------- |
| Suite file       | snake_case; mirror source path under `test/bats/` | `scripts/lib/common.bats`           |
| Support helper   | snake_case `.bash` under `test/bats/support/`     | `common.bash`, `mock_cli.bash`      |
| `@test` name     | Descriptive sentence (lowercase)                  | `parse_args accepts --verbose flag` |
| Package constant | UPPER_SNAKE_CASE                                  | `TARGET_SCRIPT`, `FIXTURE_DIR`      |

### Suite File Structure

Required order for every `test/bats/**/*.bats` file:

1. `#!/usr/bin/env bats`
2. Header comment: `# Tests for <repo-relative path>`
3. Optional project support preamble (load `test/bats/support/common.bash` or equivalent when the repository provides it)
4. Target constants (`TARGET_SCRIPT`, `TARGET_LIB`, …) when needed
5. `setup()` — source script(s), export env, create temp state
6. `teardown()` — when `setup()` creates temp files or dirs
7. `@test` functions in a-z order by test description

When the repository provides `test/bats/support/common.bash`, use a walk-up loader such as:

```bash
_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"
```

### Support Library

| File | Role |
| `test/bats/support/common.bash` | Optional shared helpers (source paths, fixtures, temp dirs) |
| `test/bats/support/*.bash` | Domain mocks; load from `setup()` or per-test as needed |

Prefer [bats-support](https://github.com/bats-core/bats-support) and [bats-assert](https://github.com/bats-core/bats-assert) when the project adopts them.

## Guidelines

### File Layout (BAT)

- BAT-01 (MUST): Mirror Source Path
  - Check: Is the suite placed under `test/bats/` with the same relative path as the script or library under test?
- BAT-02 (MUST): Header Target Path
  - Check: Does the header comment name the repo-relative path of the script or library under test?
- BAT-03 (SHOULD): Shared Support Helpers
  - Check: Are repeated setup paths centralized in `test/bats/support/` instead of copied into every suite?

### Setup and Teardown (SETUP)

- SETUP-01 (MUST): Source in setup()
  - Check: Are targets sourced or invoked from `setup()` (or a shared helper), not ad hoc per test?
- SETUP-02 (MUST): Teardown Temp State
  - Check: Does `teardown()` remove files or directories created in `setup()` (`mktemp`, mock bins, fixture dirs)?
- SETUP-03 (SHOULD): Export Before Source
  - Check: Are environment variables exported before sourcing when the sourced script reads them at load time?

### Test Design (TEST)

- TEST-01 (SHOULD): Unit vs Integration Split
  - Check: Are pure functions tested after `setup()` sources the script, and CLI flows tested via `run bash "${SCRIPT}" …`?
- TEST-02 (MUST): Use run for CLI Assertions
  - Check: Are CLI exit status and output asserted with Bats `run` and `$status` / `$output` (or bats-assert equivalents)?
- TEST-03 (MUST): Subshell for cwd Changes
  - Check: Are integration commands that need a different working directory wrapped in `run bash -c 'cd … && …'` or an equivalent helper — never bare `cd` immediately before `run`?
- TEST-04 (SHOULD): Test Order
  - Check: Are `@test` blocks ordered a-z by description (after `setup`/`teardown`)?
- TEST-05 (SHOULD): No Duplicate Source
  - Check: Is the target script sourced once in `setup()` without redundant `source` inside individual tests?

### Mocking (MOCK)

- MOCK-01 (SHOULD): Centralize CLI Mocks
  - Check: Are external CLI mocks placed under `BATS_TEST_TMPDIR` or `test/bats/support/` helpers, with `PATH` prepended in the test?

### Anti-Patterns

- Bare `cd` immediately before `run` — `run` executes in a subshell that resets cwd
- Mixing relative script paths in integration tests without a repository root helper
- Inconsistent headers — always use the full repo-relative path under test
- Real secrets or live tokens in fixtures — use placeholders and assert redaction behavior
- Skipping `teardown()` when `setup()` writes temp files or directories

### Code Modification Guidelines

- Add or update suites under `test/bats/` mirroring the changed script path in the same change as the script.
- Reuse `test/bats/support/` helpers; extend shared support instead of copying preamble logic.
- After changes, run `bats -r test/bats` and the repository's shell validation entry point (for example `shell-script-validation` `validate.sh` when available).
- Shell script DOC/header rules remain in the companion Shell Script rules (stem `shell-script`); do not duplicate them here.

## Testing and Validation

**Entry point (recommended)**:

```bash
bats -r test/bats
bash <agent-root>/skills/shell-script-validation/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
bats test/bats/path/to/script.bats
bats test/bats/path/to/script.bats -f "partial test name"
```

**References**:

- [bats-core writing tests](https://bats-core.readthedocs.io/en/stable/writing-tests.html)
- [bats-core tutorial](https://bats-core.readthedocs.io/en/stable/tutorial.html)
- Suite conventions: this file. Shell script authoring: companion Shell Script rules (stem `shell-script`). Validation workflow: `shell-script-validation` skill SKILL.md.

## Security Guidelines

- Do not embed real API keys, tokens, or credentials in `@test` fixtures — use obvious placeholders and verify sanitization/redaction where applicable.
- Write temporary artifacts only under `BATS_TEST_TMPDIR`, `mktemp`, or ignored paths; remove them in `teardown()`.
- Do not make destructive host paths the default in examples (avoid `rm -rf /` patterns); scope file operations to test fixtures.
