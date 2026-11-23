---
paths:
  - "**/.cursor/cli.json"
  - "**/.cursor/permissions.json"
  - "**/.cursor/hooks.json"
---

# Cursor Settings Instructions

## Scope

- Scope covers choosing between permission settings and hooks when editing Cursor settings files.
- Critical: permission files decide who may run a command and hooks run commands automatically; do not use a hook to express an allow or deny rule.

## Standards

### Mechanism Selection

| Purpose                                      | Mechanism                                                       |
| -------------------------------------------- | --------------------------------------------------------------- |
| Allow or deny a command, path, or tool (CLI) | `.cursor/cli.json` `permissions.allow` / `deny`                 |
| Allow a command or MCP server (editor)       | `.cursor/permissions.json` `terminalAllowlist` / `mcpAllowlist` |
| Deny a command or path (editor)              | `autoRun.block_instructions` in `.cursor/permissions.json`      |
| Format a file after an edit                  | `afterFileEdit` hook in `.cursor/hooks.json`                    |
| Validate the result at the end of a turn     | `stop` hook in `.cursor/hooks.json`                             |
| Scan or reject a prompt                      | `beforeSubmitPrompt` hook in `.cursor/hooks.json`               |

## Guidelines

### Permissions and Hooks (PERM)

- PERM-01 (MUST): Express command and path allow and deny rules in `cli.json` and `permissions.json`, not in hooks
- PERM-02 (MUST): Record a denial in `permissions.json` as an `autoRun.block_instructions` sentence, because it has no deny array
- PERM-03 (MUST): Deny direct execution of formatters and linters that a hook already runs
- PERM-04 (SHOULD): Keep test runners allowed even when a `stop` hook runs them; the hook runs the full suite
- PERM-05 (MUST): Edit the source of a hook entry that a package manager generates, not the generated `hooks.json`
- PERM-06 (SHOULD): Make a hook print nothing on success and bounded output on failure, because hook output enters the conversation

## Testing and Validation

On-demand validation: see instructions-review skill SKILL.md.

## Security Guidelines

- Do not add allow rules that widen access to credentials, key files, or environment dumps.
- Do not weaken or remove an existing deny rule or `block_instructions` sentence to make a hook or command pass.
