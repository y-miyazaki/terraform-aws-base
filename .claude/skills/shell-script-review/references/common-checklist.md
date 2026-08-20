# Shell Script Review Checklist

## Anti-Patterns (AP)

- AP-01 (SHOULD): Omit set -euo/main/entry guard from sourced libs
- AP-02 (SHOULD): Keep header/function DOC blocks when refactoring
- AP-03 (SHOULD): Function docs include Globals: (or None)
- AP-04 (SHOULD): Match sibling lib/\*.sh comment/separator style

## Code Standards (CODE)

- CODE-01 (SHOULD): Prefer local over globals inside functions
- CODE-02 (SHOULD): One responsibility per function; pass args explicitly

## Dependencies (DEP)

- DEP-01 (SHOULD): Verify required commands with command -v before use

## Documentation (DOC)

- DOC-01 (MUST): Header has Description/Usage/Design Rules
- DOC-02 (SHOULD): Functions document Globals/Arguments/Outputs/Returns
- DOC-03 (SHOULD): Globals comment purpose/unit/constraints

## Error Handling (ERR)

- ERR-01 (SHOULD): Trap EXIT/ERR/INT/TERM when cleanup is required
- ERR-02 (SHOULD): Check exit codes; avoid blanket || true
- ERR-03 (SHOULD): Errors include enough context to locate the failure
- ERR-04 (SHOULD): Clean up temps/processes/locks on exit
- ERR-05 (SHOULD): Use set +e / set -e explicitly for tolerated failures

## Function Design (FUNC)

- FUNC-01 (SHOULD): parse_arguments uses while+case with -h/--help
- FUNC-02 (SHOULD): Entry scripts implement show_usage (Usage/Options/Examples)
- FUNC-03 (SHOULD): Executable scripts use main + BASH_SOURCE entry guard

## Global / Base (G)

- G-01 (MUST): Set SCRIPT_DIR when sourcing or resolving relative paths
- G-02 (SHOULD): No secrets embedded in scripts
- G-03 (MUST): Order show_usage → parse_arguments → a-z → main
- G-04 (SHOULD): Re-runs are safe when operationally required

## Logging (LOG)

- LOG-01 (SHOULD): Errors go to stderr; normal output to stdout
- LOG-02 (SHOULD): Mask passwords/tokens before logging/echo

## Security (SEC)

- SEC-01 (SHOULD): Validate user input used in paths/commands
- SEC-02 (SHOULD): Quote expansions; avoid eval on untrusted input
- SEC-03 (SHOULD): Normalize/restrict user-controlled paths
- SEC-04 (SHOULD): Create temps with mktemp and trap cleanup
- SEC-05 (SHOULD): Check privileges before destructive/privileged ops
- SEC-06 (SHOULD): Initialize/validate inherited env that affects behavior
- SEC-07 (SHOULD): Set umask 027 (or stricter) near script start

## Testing (TEST)

- TEST-00 (MUST): Add/update paired Bats suite in the same change
- TEST-01 (SHOULD): Bats test functions ordered a-z after setup/teardown
