# CLAUDE.md

Behavioral rules for `scripts/**` and the root installers (`install_go.sh`, `install_terraform.sh`). Generic shell rules live in the companion Shell Script rules (`.claude/rules/shell-script.md`); this file holds only what is specific to this repository. Tests: [test/bats/CLAUDE.md](../test/bats/CLAUDE.md).

---

## Source of truth and sync (MUST)

| Edit here                                                                                           | Never hand-edit (synced by the Stop hook)                                                    |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `scripts/lib/*.sh`                                                                                  | `.apm/packages/*/.apm/skills/*/scripts/lib/` and the `.claude/`, `.agents/` and other copies |
| `scripts/{shell-script,go,terraform}/validate.sh`, `scripts/shell-script/fix_function_doc_order.sh` | The paired skill `scripts/` copies                                                           |

Do not run `apm install` or the `scripts/self/apm/sync_*` scripts by hand; the Stop hook does it. `scripts/self/**` is repository-only tooling and is not distributed.

## Library contracts are public (MUST)

`scripts/lib/` is copied into every distributed skill, so a function signature, exit status or output change is a breaking change for consumers.

- A `check_*` / `is_*` function that tests a value or a contract returns a status (`return 1`) and does not call `error_exit` or `exit`; the caller decides (`if ! f; then`, `f || exit 1`). `require_*` functions and `error_exit` are assertions that stop the run by design (for example `require_dependencies`); keep them out of anything named `check_*`.
- A function that wraps a command returns that command's status and keeps stdout clean (data only); diagnostics go to stderr.
- Build commands as arrays and run them through `execute_command`; do not assemble command strings for `bash -c`.
- When a contract changes, add an entry to the breaking-change list of the change (migration step for downstream repositories) and update the Bats suite that pins the old behavior.

## Require tools first (MUST)

A script checks the tools it needs (`require_dependencies`, `command -v`) at the start, before it looks at the work. A missing tool then fails every run the same way, on a developer machine and in CI, instead of passing quietly on runs that happen to have nothing to do and failing later on the first change that needs the tool. Do not move the check behind a no-op exit to make a test pass.

The environment is the test's job: a suite that needs go, golangci-lint, node or any other CLI mocks it (`mock_tool_write` in `test/bats/support/shell_tool_mock.bash`) or skips, and a suite that proves the missing-tool report runs with a system-only `PATH` (see [test/bats/CLAUDE.md](../test/bats/CLAUDE.md)).

## Temporary files (MUST)

Where disposable files go is set in [CLAUDE.md § Conventions](../CLAUDE.md#conventions). In a script, create them with `mktemp` and remove them on exit (`trap`); never write them into the repository or the repo-level `tmp/`. A path derived from `$PWD` or the repository root is not a temp location.

## Failure behavior (MUST)

- A path, option or input the user gave that does not resolve is an error (non-zero), never a silent "nothing to do".
- An unknown option exits non-zero; only `-h` / `--help` exits 0.
- A destructive script (`clean_*`, `rm -rf`) never deletes what git tracks and refuses to run when it cannot tell (for example git is unreadable in a repository).
- A pipeline under `set -o pipefail` whose failure the script wants to tolerate uses `x=$(a | b) || x=default`, not `a | b || echo default` (the second form prints twice).

## Input paths (MUST)

A path argument resolves against the caller's current working directory, and absolute paths are accepted; a default target is the current directory or a fixed repository location (for example `.github/workflows` of the repository root) that the help states. A script that needs the repository root derives it itself but never re-resolves a path the caller gave against another base (the repository root or the script's own location); a tool that always scans the whole repository (for example actionlint) runs from the repository root. A path that does not exist is an error (see Failure behavior). State the default target in the script's help and in the skill's Input.

A script passes an argument to an external tool only when that tool's own help or documentation defines it (check `--help`); an argument the tool silently ignores makes the script look scoped when it is not. A script that scans the whole repository changes to the repository root itself, so the result does not depend on the directory it is started in. A default value in a script distributed with a skill names no path or glob of this repository; the caller supplies it (an empty default means no filter).

Audited: `scripts/go/validate.sh` and `scripts/terraform/validate.sh` resolve a path argument against the current directory and follow this rule.

Known deviation: `scripts/shell-script/validate.sh` resolves paths against a root derived from its install location and falls back to the repository root; align it the next time it changes.

## Pairing (MUST)

Every script and every `scripts/lib/*.sh` has a Bats suite under `test/bats/` that mirrors its path and names it in a `# Tests for <repo-relative path>` header; the Stop hook `scripts/self/hooks/bats_changed.sh` maps changed files to suites through that header. Entry scripts keep the `if [[ ${BASH_SOURCE[0]} == "$0" ]]; then main "$@"; fi` guard so a suite can source them and call one function.
