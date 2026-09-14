---
paths:
  - "**/*.sh"
  - "**/*.bats"
---

# Bats Instructions

## Scope

- Scope covers authoring Bats suites and applies when editing shell scripts that require pairing a suite.
- Shell script implementation rules remain in the companion Shell Script rules (stem `shell-script`); this file defines test-suite conventions only.
- When adding or materially changing a shell script or sourced library, add or update the matching Bats suite in the same change (MUST) — same obligation as companion Shell Script rules (stem `shell-script`).
- Bats does not mandate a global directory layout — follow the **repository's established test tree** (discover from existing suites, CI config, or maintainer docs).

### Rule application (`globs` / `paths`)

| Pattern                       | Use when                                                           | Result                                                                         |
| ----------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| `**/*.sh,**/*.bats` (default) | Test rules must apply while editing **production** `.sh` files too | Suite pairing and conventions inject on script edits (G-05 companion coverage) |
| `**/*.bats` only              | Test rules should inject **only** when a suite file is open        | Pairing obligation is easy to miss when changing `foo.sh`                      |

**Why Bats lists two globs but Go uses one:** Bats pairs `*.sh` with `*.bats` — different extensions, so both must be listed. Go tests live in `*_test.go`, which already matches `**/*.go`. Listing only `**/*.bats` does not inject rules when editing the script under test.

## Standards

### Naming Conventions

| Component      | Rule                                                                 | Example                                      |
| -------------- | -------------------------------------------------------------------- | -------------------------------------------- |
| Suite file     | snake_case; when the repo mirrors paths, match the source under test | `lib/common.bats` mirroring `lib/common.sh`  |
| Support helper | snake_case `.bash` under the repository bats support dir when used   | `common.bash`, `mock_cli.bash` in `support/` |
| `@test` name   | Descriptive sentence (lowercase)                                     | `parse_args accepts --verbose flag`          |

### Suite File Structure

Required order for every repository `*.bats` suite file:

1. `#!/usr/bin/env bats`
2. Optional `# shellcheck disable=…` line(s)
3. Header comment block:
   - `# Tests for <repo-relative path>` (required)
   - `# Use cases:` followed by one `# - …` bullet per covered scenario (required)
4. Optional project support preamble (load shared support when the repository provides it)
5. Target constants (`TARGET_SCRIPT`, `TARGET_LIB`, …) when needed
6. `setup()` — source script(s), export env, create temp state
7. `teardown()` — when `setup()` creates temp files or dirs
8. `@test` functions in a-z order by test description

Example header:

```bash
#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2034,SC2154

# Tests for lib/common.sh
#
# Use cases:
# - execute_command runs and logs when VERBOSE=true
# - execute_command dry-run only logs the planned command
# - is_dry_run / log behave for VERBOSE and DRY_RUN flags
```

When the repository provides shared support (for example `support/common.bash`), use a walk-up loader such as:

```bash
_bats_support="$(dirname "${BATS_TEST_FILENAME}")"
while [[ ! -f "${_bats_support}/support/common.bash" ]]; do
    _bats_support="$(dirname "${_bats_support}")"
done
# shellcheck disable=SC1091
source "${_bats_support}/support/common.bash"
```

### Support Library

| Location                         | Role                                                                                   |
| -------------------------------- | -------------------------------------------------------------------------------------- |
| Repository `support/common.bash` | Optional shared helpers (source paths, fixtures, temp dirs)                            |
| Repository `support/*.bash`      | Domain mocks; load from `setup()` for shared mocks or at the start of individual tests |

Prefer [bats-support](https://github.com/bats-core/bats-support) and [bats-assert](https://github.com/bats-core/bats-assert) when the project adopts them.

## Guidelines

### File Layout (BAT)

- BAT-01 (MUST): When the repository pairs shell scripts with Bats suites, add or update the suite in the same change as the script or library
- BAT-01b (SHOULD): When the repository mirrors script paths under a bats root, place the suite with the same relative path as the script or library under test
- BAT-02 (MUST): Header comment names the repo-relative path of the script or library under test
- BAT-03 (MUST): Header includes `# Use cases:` with one `# - …` bullet per scenario the suite guarantees — not a dump of every `@test` name
- BAT-04 (SHOULD): Centralize repeated setup paths in repository support helpers instead of copying preamble into every suite

### Setup and Teardown (SETUP)

- SETUP-01 (MUST): Source or invoke targets from `setup()` (or a shared helper) — not ad hoc per test
- SETUP-02 (MUST): `teardown()` removes files or directories created in `setup()` (`mktemp`, mock bins, fixture dirs)
- SETUP-03 (SHOULD): Export environment variables before sourcing when the sourced script reads them at load time

### Test Design (BDES)

- BDES-01 (SHOULD): Test pure functions after `setup()` sources the script; test CLI flows via `run bash "${SCRIPT}" …`
- BDES-02 (MUST): Assert CLI exit status and output with Bats `run` and `$status` / `$output` (or bats-assert equivalents)
- BDES-03 (MUST): Wrap cwd-changing integration commands in `run bash -c 'cd … && …'` or an equivalent helper — never bare `cd` immediately before `run`
- BDES-04 (SHOULD): Order `@test` blocks a-z by description after `setup`/`teardown` (see shell-script-review TEST-01)
- BDES-05 (SHOULD): Source the target script once in `setup()` without redundant `source` inside individual tests

### Mocking (MOCK)

- MOCK-01 (SHOULD): Place external CLI mocks under `BATS_TEST_TMPDIR` or repository support helpers, with `PATH` prepended in the test

### Test Anti-Patterns (TAP)

- TAP-01 (MUST): Bare `cd` immediately before `run` — `run` executes in a subshell that resets cwd
- TAP-02 (SHOULD): Mixing relative script paths in integration tests without a repository root helper
- TAP-03 (MUST): Inconsistent headers — always use the full repo-relative path under test and a `# Use cases:` block
- TAP-04 (MUST): Omitting `# Use cases:` or leaving it empty when adding or expanding a suite
- TAP-05 (MUST): Real secrets or live tokens in fixtures — use placeholders and assert redaction behavior
- TAP-06 (SHOULD): Skipping `teardown()` when `setup()` writes temp files or directories
- TAP-07 (SHOULD): Mandating `test/bats/` when the repository uses a different bats root — discover and match existing layout

### Code Modification Guidelines

- Add or update the paired Bats suite in the same change as the script; follow the repository's established bats layout.
- Reuse repository support helpers; extend shared support instead of copying preamble logic.
- Shell script DOC/header rules remain in the companion Shell Script rules (stem `shell-script`); do not duplicate them here.

## Testing and Validation

On-demand suite verification: see shell-script-validation skill SKILL.md, or run `bats` against the changed suite (use the command or path the repository documents).

References: [bats-core writing tests](https://bats-core.readthedocs.io/en/stable/writing-tests.html), [bats-core tutorial](https://bats-core.readthedocs.io/en/stable/tutorial.html). Shell authoring: companion Shell Script rules (stem `shell-script`).

## Security Guidelines

- Do not embed real API keys, tokens, or credentials in `@test` fixtures — use obvious placeholders and verify sanitization/redaction where applicable.
- Write temporary artifacts only under `BATS_TEST_TMPDIR`, `mktemp`, or ignored paths; remove them in `teardown()`.
- Do not make destructive host paths the default in examples (avoid `rm -rf /` patterns); scope file operations to test fixtures.
