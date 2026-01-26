---
name: shell-script-validation
description: Use shell-script-validation/scripts/validate.sh for shell script validation. This skill provides the validation workflow and troubleshooting guidance. Individual commands are for debugging only.
license: MIT
---

# Shell Script Validation

This skill provides guidance for validating shell scripts to ensure code quality, correctness, and adherence to best practices.

## When to Use This Skill

This skill is applicable for:

- Validating shell script syntax
- Running static analysis on bash scripts
- Testing scripts with Bats framework
- Ensuring script quality before deployment
- Debugging script validation failures

## Validation Commands

### ⚠️ Required: Use the Validation Script

**Always use the comprehensive validation script.** This is the primary and recommended method for all validation tasks. Individual commands should only be used for debugging specific failures.

Run the centralized validation script before committing shell scripts:

```bash
# Run all validations in the workspace
bash shell-script-validation/scripts/validate.sh

# Validate a specific directory
bash shell-script-validation/scripts/validate.sh ./scripts/new_feature/

# Validate a specific script
bash shell-script-validation/scripts/validate.sh ./scripts/deploy.sh
```

### When to Use Individual Commands

Use individual commands **only** for:

- Debugging specific validation failures reported by the script
- Understanding what the validation script does internally
- Developing or improving the validation script itself

**Do not use individual commands as your primary validation method.**

#### 1. bash -n (Syntax Check)

**Purpose**: Verify script syntax without execution

```bash
# Check single script
bash -n script.sh

# Check all scripts in directory
find . -name "*.sh" -exec bash -n {} \;
```

**What it checks**:

- Syntax errors
- Unclosed quotes
- Missing keywords (fi, done, esac)
- Invalid command structures

#### 2. shellcheck (Static Analysis)

**Purpose**: Comprehensive static analysis and best practice enforcement

```bash
# Check single script
shellcheck script.sh

# Check with specific severity
shellcheck --severity=warning script.sh

# Check all scripts
shellcheck scripts/**/*.sh
```

**What it checks**:

- Common mistakes and pitfalls
- Quoting issues
- Variable usage problems
- Deprecated syntax
- Portability issues
- Best practice violations

#### 3. validate.sh (Comprehensive Validation)

**Purpose**: Project-wide script validation

```bash
# Run comprehensive validation for entire workspace
bash shell-script-validation/scripts/validate.sh -v -f

# Run for specific paths
bash shell-script-validation/scripts/validate.sh ./scripts/utils.sh ./env/config.sh
```

**What it checks**:

- All scripts in the project
- Syntax errors (bash -n)
- Static analysis (shellcheck)
- Project-specific standards
- Common library usage

## Bats Test Standards

### Test File Structure

```bash
#!/usr/bin/env bats

# setup function runs before each test
setup() {
    # Common setup code
    export TEST_VAR="value"
}

# teardown function runs after each test
teardown() {
    # Cleanup code
    unset TEST_VAR
}

# Test functions in alphabetical order
@test "description of test case" {
    # Arrange
    local input="test"

    # Act
    result=$(function_to_test "$input")

    # Assert
    [ "$result" = "expected" ]
}
```

### Bats Best Practices

- Test functions in alphabetical order (except `setup`/`teardown`)
- Use `@test "description"` format
- Cover boundary values and edge cases
- Test both normal and error scenarios
- Use descriptive test names

### Running Bats Tests

```bash
# Run all tests
bats test/*.bats

# Run specific test file
bats test/my_test.bats

# Run with verbose output
bats -t test/*.bats
```

## Validation Workflow

### Before Committing

1. **Make changes** - Edit shell scripts

2. **Check syntax**:

   ```bash
   bash -n script.sh
   ```

3. **Run shellcheck**:

   ```bash
   shellcheck script.sh
   ```

4. **Run comprehensive validation**:

   ```bash
   # Run for specific script being worked on
   bash shell-script-validation/scripts/validate.sh -v -f ./script.sh
   # Or run for the whole project
   bash shell-script-validation/scripts/validate.sh -v -f
   ```

5. **Run tests** (if applicable):

   ```bash
   bats test/*.bats
   ```

6. **Fix issues** - Address any failures

7. **Commit** - Only commit when all checks pass

## Common Validation Failures

### bash -n failures

**Common issues**:

- Unclosed quotes
- Missing `fi`, `done`, or `esac`
- Invalid syntax

**Fix**: Correct the syntax error indicated in the error message

### shellcheck failures

**Common issues**:

- SC2086: Quote variables to prevent word splitting
- SC2046: Quote command substitutions
- SC2006: Use `$(...)` instead of backticks
- SC2034: Unused variable
- SC2164: Use `cd ... || exit` for safety

**Fix**: Follow shellcheck's suggestions

Example fixes:

```bash
# ❌ Bad
cd $dir
echo $var

# ✅ Good
cd "$dir" || exit
echo "$var"
```

### validate.sh failures

**Common issues**:

- Missing `set -euo pipefail`
- Not sourcing `lib/all.sh`
- Incorrect function order
- Missing error handling

**Fix**: Follow project script standards

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

### Error Handling

```bash
# Use error_exit from common library
error_exit "Error message"

# Set up cleanup trap
cleanup() {
    rm -f "$temp_file"
}
trap cleanup EXIT
```

## Best Practices

### Validation Frequency

- Run `bash -n` after every script edit
- Run `shellcheck` before committing
- Run `validate.sh` before pushing
- Run Bats tests after logic changes

## Security Validation

### Security Checklist

- [ ] No hardcoded credentials
- [ ] Input validation for all user inputs
- [ ] Proper quoting to prevent command injection
- [ ] Temporary files use `mktemp`
- [ ] Cleanup with `trap` for temporary files
- [ ] Sensitive data in environment variables

### Common Security Issues

```bash
# ❌ Bad - Command injection risk
eval "$user_input"

# ✅ Good - Validate and quote
if [[ "$user_input" =~ ^[a-zA-Z0-9_]+$ ]]; then
    process "$user_input"
fi

# ❌ Bad - Insecure temporary file
temp_file="/tmp/myfile"

# ✅ Good - Secure temporary file
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT
```

## Quick Reference

```bash
# Run all validations
bash shell-script-validation/scripts/validate.sh -f

# Run for specific directory
bash shell-script-validation/scripts/validate.sh ./scripts/lib/

# Run tests
bats test/*.bats
```

### Validation Checklist

Before committing:

- [ ] Validation script passes (`bash shell-script-validation/scripts/validate.sh`)
- [ ] Bats tests pass (if applicable)
- [ ] Follows project script standards
- [ ] No security issues

## Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use the validation script.

### bash -n (Syntax Check)

**Purpose**: Verify script syntax without execution

```bash
# Check single script
bash -n script.sh

# Check all scripts in directory
find . -name "*.sh" -exec bash -n {} \;
```

**What it checks**:

- Syntax errors
- Unclosed quotes
- Missing keywords (fi, done, esac)
- Invalid command structures

### shellcheck (Static Analysis)

**Purpose**: Comprehensive static analysis and best practice enforcement

```bash
# Check single script
shellcheck script.sh

# Check with specific severity
shellcheck --severity=warning script.sh

# Check all scripts
shellcheck scripts/**/*.sh
```

**What it checks**:

- Common mistakes and pitfalls
- Quoting issues
- Variable usage problems
- Deprecated syntax
- Portability issues
- Best practice violations

### validate.sh (Comprehensive Validation)

**Purpose**: Project-wide script validation

```bash
# Run comprehensive validation for entire workspace
bash shell-script-validation/scripts/validate.sh -v -f

# Run for specific paths
bash shell-script-validation/scripts/validate.sh ./scripts/utils.sh ./env/config.sh
```

**What it checks**:

- All scripts in the project
- Syntax errors (bash -n)
- Static analysis (shellcheck)
- Project-specific standards
- Common library usage

## Summary

Shell script validation ensures code quality and reliability:

1. **Automate validation** - Use `shell-script-validation/scripts/validate.sh` for comprehensive checks
2. **Validate frequently** - Run checks during development, not just before commit
3. **Test with Bats** - Cover edge cases and errors
4. **Follow standards** - Use project template and best practices
5. **Ensure security** - Validate inputs and quote variables
6. **Validate before committing** - Never commit invalid scripts
