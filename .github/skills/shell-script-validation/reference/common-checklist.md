# Shell Script Validation Checklist

## Syntax

- SYNTAX-01: bash -n pass
- SYNTAX-02: Valid bash syntax
- SYNTAX-03: No parsing errors
- SYNTAX-04: Shebang present

## Static Analysis

- LINT-01: shellcheck pass
- LINT-02: No warnings excluded
- LINT-03: No deprecated constructs
- LINT-04: Proper quoting

## Best Practices

- BP-01: set -e/u handling
- BP-02: Error exit usage
- BP-03: Trap configuration
- BP-04: Signal handling

## Structure

- STRUCT-01: SCRIPT_DIR defined
- STRUCT-02: Common header present
- STRUCT-03: Function organization
- STRUCT-04: Main entry point

## Dependencies

- DEPS-01: aqua installed
- DEPS-02: External commands available
- DEPS-03: lib sourcing correct
- DEPS-04: Version requirements met
