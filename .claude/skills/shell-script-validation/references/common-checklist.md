# Shell Script Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `bash -n` — syntax parse check
2. `shellcheck` — static analysis and best practice enforcement
3. Project standards check — common header and structure conventions (opt-in function doc sections via `--check-function-docs`)

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

## Optional: `--check-function-docs`

Pass to `validate.sh` to enforce [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments) with explicit `Globals`, `Arguments`, `Outputs`, and `Returns` sections (`None` when a section does not apply), in that order. When this skill ships `scripts/fix_function_doc_order.sh`, use it on the target path or directory to normalize section order. Opt-in only.

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
