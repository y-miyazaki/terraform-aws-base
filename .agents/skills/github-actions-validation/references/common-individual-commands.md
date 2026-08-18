# Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use the validation script.

## yaml_map_order.py

**Purpose**: Verify or fix alphabetical map key order (ORD-01)

```bash
# Check tracked workflow and action YAML (example paths)
python3 scripts/lib/yaml_map_order.py check \
  .github/workflows/ci.yml \
  .github/actions/example/action.yml

# Rewrite unsorted map blocks in place
python3 scripts/lib/yaml_map_order.py fix \
  .github/workflows/ci.yml
```

**What it checks**:

- `env`, `inputs`, `outputs`, `permissions`, `secrets`, and `with` map keys are alphabetically ordered

## actionlint

**Purpose**: Validate workflow syntax and detect common issues

```bash
# Check all workflows (run from repository root so .github/actionlint.yaml applies)
cd "$(git rev-parse --show-toplevel)"
actionlint .github/workflows/*.{yml,yaml}

# Check specific workflow
actionlint .github/workflows/ci.yml

# Check with shellcheck integration
actionlint -shellcheck= .github/workflows/*.yml
```

**What it checks**:

- YAML syntax errors
- Invalid workflow structure
- Deprecated actions
- Invalid action inputs
- Expression syntax errors
- Shell command issues
- Best practice violations

## ghalint run

**Purpose**: Security and configuration validation

```bash
# Run ghalint
ghalint run .github/workflows/

# Run with specific config
ghalint run -config .ghalint.yml .github/workflows/
```

**What it checks**:

- Security issues
- Permissions configuration
- Secrets usage
- Third-party action versions
- Workflow triggers
- Configuration best practices

## zizmor

**Purpose**: Scan workflows for GitHub Actions security issues

```bash
# Run zizmor
zizmor .
```

**What it checks**:

- Information leaks
- Insecure triggers
- Overly permissive tokens
- Insecure step-level configurations
- Vulnerable third-party actions
