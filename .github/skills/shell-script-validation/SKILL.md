---
name: shell-script-validation
description: Shell script validation covering syntax and static analysis. Always use validate.sh script. For troubleshooting, see reference/.
license: MIT
---

# Shell Script Validation

This skill provides guidance for validating shell scripts using the comprehensive validation script.

## When to Use This Skill

This skill is applicable for:

- Validating shell script before committing
- Running comprehensive script quality checks
- Ensuring syntax correctness
- Verifying best practice compliance

## ⚠️ CRITICAL: Always Use the Validation Script

**DO NOT run individual commands (bash -n, shellcheck) directly.**

**The validation script handles everything automatically.**

### Usage

```bash
# Run all validations in the workspace
bash shell-script-validation/scripts/validate.sh

# Validate a specific directory
bash shell-script-validation/scripts/validate.sh ./scripts/new_feature/

# Validate a specific script
bash shell-script-validation/scripts/validate.sh ./scripts/deploy.sh

# With verbose output and auto-fix
bash shell-script-validation/scripts/validate.sh -v -f
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **`bash -n`** - Syntax check without execution
2. **`shellcheck`** - Comprehensive static analysis and best practice enforcement
3. **Project standards** - Verify script template compliance

## Validation Requirements

Before considering scripts complete:

- ✅ **All validation checks pass**
- ✅ **No syntax errors**
- ✅ **No shellcheck warnings**
- ✅ **Follows project script standards**
- ✅ **Bats tests pass (if applicable)**

## Validation Workflow

### Before Committing

1. **Make changes** - Edit shell scripts
2. **Run validation**:
   ```bash
   bash shell-script-validation/scripts/validate.sh ./script.sh
   ```
3. **Fix issues** - Address any failures
4. **Run tests** (if applicable):
   ```bash
   bats test/*.bats
   ```
5. **Commit** - Only commit when all checks pass

## Common Failures & Quick Fixes

### Syntax Errors

```
Error: bash -n failed
script.sh: line 15: syntax error near unexpected token 'fi'
```

**Fix**: Correct the syntax error indicated in the message

### shellcheck Errors

```
SC2086: Quote variables to prevent word splitting
```

**Fix**: Add quotes around variables

```bash
# Bad
cd $dir

# Good
cd "$dir" || exit
```

### Common shellcheck Issues

**SC2006: Use $(...) instead of backticks**

```bash
# Bad
result=`command`

# Good
result=$(command)
```

**SC2046: Quote command substitutions**

```bash
# Bad
for file in $(find . -name "*.txt"); do

# Good
find . -name "*.txt" | while read -r file; do
```

**SC2086: Quote variables**

```bash
# Bad
echo $var

# Good
echo "$var"
```

**SC2164: Use cd ... || exit**

```bash
# Bad
cd /some/path

# Good
cd /some/path || exit
```

## Script Standards

### Required Template Elements

Every script must include:

```bash
#!/bin/bash
# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"
```

### Function Order

Functions must be ordered as follows:

1. `show_usage` / `parse_arguments` (if present)
2. Other functions in alphabetical order
3. `main` function last

## Troubleshooting

### Validation Script Not Found

```bash
# Navigate to project root
cd /workspace

# Verify script exists
ls -la .github/skills/shell-script-validation/scripts/validate.sh

# Run with bash explicitly
bash shell-script-validation/scripts/validate.sh
```

### Permission Denied

```bash
# Run with bash explicitly
bash shell-script-validation/scripts/validate.sh ./script.sh
```

### Need More Details

For detailed information, see the reference documentation:

- **[Individual Commands](reference/individual-commands.md)** - Detailed command usage for debugging
- **[Troubleshooting Guide](reference/troubleshooting.md)** - Comprehensive error resolution
- **[Script Standards](reference/standards.md)** - Project script template and conventions
