---
paths:
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
---

# Claude Settings Instructions

## Scope

- Scope covers choosing between `permissions` and `hooks` when editing Claude Code settings files.
- Critical: `permissions` decide who may run a command and hooks run commands automatically; do not use a hook to express an allow, deny, or ask rule.

## Standards

### Mechanism Selection

| Purpose                                           | Mechanism                            |
| ------------------------------------------------- | ------------------------------------ |
| Allow, deny, or ask for a path or command pattern | `permissions` (`allow`/`deny`/`ask`) |
| Format a file after an edit                       | `PostToolUse` hook                   |
| Validate the result at the end of a turn          | `Stop` hook                          |
| Decide from tool input content or runtime state   | `PreToolUse` hook                    |
| Inject starting context                           | `SessionStart` hook                  |

## Guidelines

### Permissions and Hooks (PERM)

- PERM-01 (MUST): Express path and command allow, deny, and ask rules in `permissions`, not in hooks
- PERM-02 (MUST): Use `PreToolUse` only when the decision depends on tool input content or runtime state that a permission pattern cannot express
- PERM-03 (MUST): Deny direct execution in `permissions` of formatters and linters that a hook already runs
- PERM-04 (SHOULD): Keep test runners allowed even when a `Stop` hook runs them; the hook runs the full suite
- PERM-05 (MUST): Edit the source of a hook entry that a package manager generates, not the generated settings file
- PERM-06 (SHOULD): Make a hook print nothing on success and bounded output on failure, because hook output enters the conversation

## Testing and Validation

On-demand validation: see instructions-review skill SKILL.md.

## Security Guidelines

- Do not add `allow` rules that widen access to credentials, key files, or environment dumps.
- Do not weaken or remove an existing `deny` rule to make a hook or command pass.
