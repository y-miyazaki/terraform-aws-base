---
paths:
  - "**/*.sh"
---

# Shell Script Instructions

## Scope

- Scope covers implementing and validating shell scripts, including pairing Bats suites in the same change when required.
- TEST-00 (MUST): When adding or materially changing a shell script or sourced library, add or update the matching Bats suite in the same change — do not defer tests. Follow the repository's established bats layout per companion Bats rules (stem `bats`).
- Suite layout and helpers: companion Bats rules (stem `bats`).

## Standards

### Script Structure

Required in-file order for **executable entry scripts** (invoked directly or via `bash lib/*.sh`):

1. shebang + header comments (DOC-01)
2. `set -euo pipefail` + secure defaults（`umask 027`, `export LC_ALL=C.UTF-8`）
3. `SCRIPT_DIR` setup (G-01) — only when the script sources libraries or resolves relative paths (see below)
4. global variable definitions
5. function definitions: `show_usage` / `parse_arguments` -> other functions in a-z order (G-03) -> `main` last
6. entry point: `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`

### SCRIPT_DIR (G-01)

Set `SCRIPT_DIR` **only when** the script sources libraries or builds paths relative to the script file (for example `source "${SCRIPT_DIR}/lib/all.sh"`). Omit it when the script uses only environment variables or absolute paths.

Canonical assignment (no `export`, no `# shellcheck disable=SC2034` when `${SCRIPT_DIR}` is referenced):

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

Placement:

- After secure defaults (step 2)
- Before the `# Global variables` block (step 4) or before an immediate `source "${SCRIPT_DIR}/..."` line
- Do not add `export SCRIPT_DIR` unless a child process must read `$SCRIPT_DIR` from the environment

### Sourced library files

Applies to `source`d modules (for example `lib/*.sh`, `scripts/lib/*.sh`):

- Omit items 2, 3, 5 (`show_usage` / `parse_arguments` / `main`), and 6 from the executable list above
- Match comment style, separators, and function doc blocks used by sibling files in the same directory
- List functions in a-z order (G-03)
- Every function doc block must include **Globals**, **Arguments**, **Outputs**, and **Returns** (`None` when a section does not apply)
- When refactoring logic, **do not remove** header or function comment blocks to save tokens

### Header Comment Format

```bash
#!/bin/bash
#######################################
# Description:
#   What this script does (one paragraph).
#
# Usage:
#   bash script_name.sh [OPTIONS] [args]
#
# Design Rules:
#   - Key design constraint 1.
#
# Output:
#   Description of output (include when script generates artifacts).
#
#######################################
```

### Function Documentation

Based on [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments). List all API sections explicitly; write `None` when a section does not apply (clearer than omitting the section).

```bash
#######################################
# Brief description of what the function does.
# Globals:
#   VAR_NAME - globals read or written (or None)
#
# Arguments:
#   $1 - description of argument 1 (or None)
#
# Outputs:
#   STDOUT/STDERR description (or None)
#
# Returns:
#   Exit status description (or None)
#######################################
function my_function() {
```

**Do not omit sections** — write `None` on the next line when a section has no applicable content.

## Guidelines

### Anti-Patterns (AP)

- AP-01 (SHOULD): Omit set -euo/main/entry guard from sourced libs
- AP-02 (SHOULD): Keep header/function DOC blocks when refactoring
- AP-03 (SHOULD): Function docs include Globals: (or None)
- AP-04 (SHOULD): Match sibling lib/\*.sh comment/separator style

### Code Standards (CODE)

- CODE-01 (SHOULD): Prefer local over globals inside functions
- CODE-02 (SHOULD): One responsibility per function; pass args explicitly

### Dependencies (DEP)

- DEP-01 (SHOULD): Verify required commands with command -v before use

### Documentation (DOC)

- DOC-01 (MUST): Header has Description/Usage/Design Rules
- DOC-02 (SHOULD): Functions document Globals/Arguments/Outputs/Returns
- DOC-03 (SHOULD): Globals comment purpose/unit/constraints

### Error Handling (ERR)

- ERR-01 (SHOULD): Trap EXIT/ERR/INT/TERM when cleanup is required
- ERR-02 (SHOULD): Check exit codes; avoid blanket || true
- ERR-03 (SHOULD): Errors include enough context to locate the failure
- ERR-04 (SHOULD): Clean up temps/processes/locks on exit
- ERR-05 (SHOULD): Use set +e / set -e explicitly for tolerated failures

### Function Design (FUNC)

- FUNC-01 (SHOULD): parse_arguments uses while+case with -h/--help
- FUNC-02 (SHOULD): Entry scripts implement show_usage (Usage/Options/Examples)
- FUNC-03 (SHOULD): Executable scripts use main + BASH_SOURCE entry guard

### Global / Base (G)

- G-01 (MUST): Set SCRIPT_DIR when sourcing or resolving relative paths
- G-02 (SHOULD): No secrets embedded in scripts
- G-03 (MUST): Order show_usage → parse_arguments → a-z → main
- G-04 (SHOULD): Re-runs are safe when operationally required

### Logging (LOG)

- LOG-01 (SHOULD): Errors go to stderr; normal output to stdout
- LOG-02 (SHOULD): Mask passwords/tokens before logging/echo

### Security (SEC)

- SEC-01 (SHOULD): Validate user input used in paths/commands
- SEC-02 (SHOULD): Quote expansions; avoid eval on untrusted input
- SEC-03 (SHOULD): Normalize/restrict user-controlled paths
- SEC-04 (SHOULD): Create temps with mktemp and trap cleanup
- SEC-05 (SHOULD): Check privileges before destructive/privileged ops
- SEC-06 (SHOULD): Initialize/validate inherited env that affects behavior
- SEC-07 (SHOULD): Set umask 027 (or stricter) near script start

### Testing (TEST)

- TEST-00 (MUST): Add/update paired Bats suite in the same change
- TEST-01 (SHOULD): Bats test functions ordered a-z after setup/teardown

### Code Modification Guidelines

- When adding or changing shell scripts or sourced libraries, add or update matching Bats suites under test/bats/ (mirror the script path) in the same change; follow companion Bats rules (stem `bats`) for suite layout.

## Testing and Validation

DOC-\* comment format and header separator style need judgment review (shell-script-review), not automated lint.

On-demand validation: see shell-script-validation skill SKILL.md. Suite layout: companion Bats rules (stem `bats`).

## Security Guidelines

- Keep `set -euo pipefail` and safe defaults (`umask 027`, `LC_ALL=C.UTF-8`) enabled; do not disable them.
- Handle sensitive information through environment variables or secret management, and never print it to stdout/logs.
- Add target confirmation and guard conditions before destructive commands to prevent accidental execution.
