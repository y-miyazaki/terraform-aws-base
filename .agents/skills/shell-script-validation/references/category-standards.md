## Shell Script Validation - Script Standards

## Required Template

Executable entry scripts that source libraries or resolve relative paths:

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
#   Description of output (when applicable).
#
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load all-in-one library
# shellcheck source=./lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/all.sh"

#######################################
# Global variables
#######################################
```

Scripts that use only environment variables or absolute paths omit `SCRIPT_DIR` and the `source` block.

## SCRIPT_DIR (G-01)

- Set `SCRIPT_DIR` only when the script sources libraries or builds paths relative to the script file.
- Canonical assignment: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Do not use `export SCRIPT_DIR` unless a child process must read `$SCRIPT_DIR` from the environment.
- Do not add `# shellcheck disable=SC2034` when `${SCRIPT_DIR}` is referenced in the script.
- Place after secure defaults and before the `# Global variables` block (or immediately before `source "${SCRIPT_DIR}/..."`).

## Function Order

1. show_usage / parse_arguments (if present)
2. Other functions in alphabetical order
3. main function last

## Function Documentation (opt-in validation)

When `--check-function-docs` is passed to `validate.sh`, enforce [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments) plus explicit `None` for non-applicable sections:

```bash
#######################################
# Brief description of what the function does.
#
# Globals:
#   None
#
# Arguments:
#   $1 - path to process
#
# Outputs:
#   None
#
# Returns:
#   0 on success, 1 on failure
#######################################
function my_function() {
```

Required section headers in this order: `Globals:`, `Arguments:`, `Outputs:`, `Returns:`. Each section must have a body line (content or `None`). Use `scripts/fix_function_doc_order.sh` to normalize section order (accepts files or directories such as `scripts/lib/` and `.github/actions/`).

## Error Handling

- Use error_exit from common library
- Set up cleanup trap for temporary files
- Validate all inputs

See main [SKILL.md](../SKILL.md) for comprehensive validation workflow.
