## Go Template Variants

Language-specific template variants. Use when the Go profile is detected.

Use these variants when Go profile is detected and Terraform profile is not detected.

## specification_go

```markdown
# Go Specification

This document defines behavior, package contracts, and runtime guarantees for Go components.

## Scope

<Describe covered packages, binaries, and environments.>

## Package Contracts

### `<package/path>`

**Responsibilities**:

- <responsibility 1>
- <responsibility 2>

**Public API**:

| Symbol   | Input    | Output     | Errors               |
| -------- | -------- | ---------- | -------------------- |
| `<Func>` | `<args>` | `<result>` | `<error conditions>` |

## Concurrency and State

<Describe goroutine model, synchronization rules, and state ownership boundaries. Omit if not applicable.>

## Configuration and Defaults

| Parameter | Default   | Source            | Notes   |
| --------- | --------- | ----------------- | ------- |
| `<name>`  | `<value>` | `<env/flag/file>` | <notes> |

## Validation and Safety Checks

- `go test ./...`
- `go vet ./...`
- `<project specific checks>`

## Compatibility and Change Management

<Define compatibility policy, rollout approach, and rollback notes.>
```
