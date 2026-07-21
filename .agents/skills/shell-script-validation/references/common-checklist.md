# Shell Script Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `bash -n` — syntax parse check
2. `shellcheck` — static analysis and best practice enforcement
3. Project standards check — common header and structure conventions (opt-in function doc sections via `--check-function-docs`)

## Checks by Tool

### bash -n

- SYN-01: Script parses without syntax errors
- SYN-02: Shebang line is present (`#!/usr/bin/env bash` or `#!/bin/bash`)
- SYN-03: All here-docs and subshells are properly closed

### shellcheck

- SC-01: No SC warnings at severity ERROR or WARNING
- SC-02: Variables are properly quoted to prevent word-splitting
- SC-03: No use of deprecated or unsafe constructs
- SC-04: Conditional expressions use `[[ ]]` instead of `[ ]` where appropriate
- SC-05: Command substitution uses `$()` instead of backticks

### Project standards check

- STD-01: When the script sources libraries or resolves relative paths, `SCRIPT_DIR` is set with `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` (no `export`, no `SC2034` when referenced)
- STD-02: Common library (`scripts/lib/` or skill `scripts/lib/`) is sourced where required
- STD-03: `set -euo pipefail`, `umask 027`, and `export LC_ALL=C.UTF-8` are present at script top (entry scripts)
- STD-04: Script follows the project's common header template and `# Global variables` block when globals are defined

### Optional: `--check-function-docs`

Pass to `validate.sh` to enforce [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments) with explicit `Globals`, `Arguments`, `Outputs`, and `Returns` sections (`None` when a section does not apply), in that order. Use `scripts/fix_function_doc_order.sh` on files or directories (`scripts/lib/`, `.github/actions/`) to normalize section order. Opt-in only.

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
