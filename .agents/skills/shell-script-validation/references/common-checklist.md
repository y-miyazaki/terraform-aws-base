# Shell Script Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `bash -n` — syntax parse check
2. `shellcheck` — static analysis and best practice enforcement
3. Project standards check — common header and structure conventions

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
- STD-01: `SCRIPT_DIR` is defined using `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`
- STD-02: Common library (`scripts/lib/`) is sourced where required
- STD-03: `set -euo pipefail` (or equivalent) is present at script top
- STD-04: Script follows the project's common header template

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
