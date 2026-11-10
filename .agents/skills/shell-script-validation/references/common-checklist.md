# Shell Script Validation Checklist

## Execution Order

`scripts/validate.sh` runs these checks for each discovered script and continues after a failing script or check (no fail-fast); the exit code is non-zero when any check failed:

1. Shebang and permission checks (with `-f`, formatting is rewritten by `shfmt` first; with `-f` and `--check-function-docs`, function doc section order is also normalized by `scripts/fix_function_doc_order.sh` after shellcheck when that file is present)
2. `bash -n` — syntax parse check
3. `shellcheck` — static analysis and best practice enforcement
4. Function doc sections and top-level function order — only with `--check-function-docs`

After the script checks, it runs the repository's Bats suites unless `--skip-tests` is passed (`--tests PATH` limits which suites run).

`shellcheck` and `shfmt` are required, and `bats` or `bats-core` when Bats runs; the script stops before any check when one is missing.

## bash -n (SYN)

- SYN-01 (SHOULD): Script parses without syntax errors
- SYN-02 (SHOULD): Shebang line is present (`#!/usr/bin/env bash` or `#!/bin/bash`)
- SYN-03 (SHOULD): All here-docs and subshells are properly closed

## shellcheck (SC)

- SC-01 (SHOULD): No SC warnings at severity ERROR or WARNING
- SC-02 (SHOULD): Variables are properly quoted to prevent word-splitting
- SC-03 (SHOULD): No use of deprecated or unsafe constructs
- SC-04 (SHOULD): Conditional expressions use `[[ ]]` instead of `[ ]` where appropriate
- SC-05 (SHOULD): Command substitution uses `$()` instead of backticks

## Project standards (STD)

- STD-01 (SHOULD): When the script sources libraries or resolves relative paths, `SCRIPT_DIR` is set with `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` (no `export`, no `SC2034` when referenced)
- STD-02 (SHOULD): Shared shell libraries are sourced where required (path layout is repository-specific)
- STD-03 (SHOULD): `set -euo pipefail`, `umask 027`, and `export LC_ALL=C.UTF-8` are present at script top (entry scripts)
- STD-04 (SHOULD): Script follows the project's common header template and `# Global variables` block when globals are defined

## Function docs: `--check-function-docs`

The script leaves these checks off unless `--check-function-docs` (`-c`) is passed. This skill's default command passes it; omit it only when the targets intentionally skip function header sections, and state the opt-out in Summary.

When passed, `validate.sh` enforces [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments) with explicit `Globals`, `Arguments`, `Outputs`, and `Returns` sections in that order (`None` when a section does not apply), and checks top-level function order (show_usage, parse_arguments, a-z, main). When this skill ships `scripts/fix_function_doc_order.sh`, use it on the target path or directory to normalize section order.

## Pass Criteria

- All tools exit with code 0
- Checks that did not run are reported as `⊘ Skipped` with the reason
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
