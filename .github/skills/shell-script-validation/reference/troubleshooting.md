# Shell Script Validation - Troubleshooting Guide

## bash -n Failures

**Common issues**:
- Unclosed quotes
- Missing fi, done, or esac

**Fix**: Correct the syntax error

## shellcheck Failures

**SC2086**: Quote variables
```bash
# Bad: echo $var
# Good: echo "$var"
```

**SC2046**: Quote command substitutions
```bash
# Bad: for f in $(find ...); do
# Good: find ... | while read -r f; do
```

**SC2006**: Use $(...) instead of backticks
```bash
# Bad: result=`command`
# Good: result=$(command)
```

**SC2164**: Use cd ... || exit
```bash
# Bad: cd /path
# Good: cd /path || exit
```

See [Script Standards](standards.md) for project template requirements.
