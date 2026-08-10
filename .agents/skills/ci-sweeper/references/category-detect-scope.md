# Detect Scope Axis

`--scope` is a **cursor axis**, not a universal "whole repo files" switch.

| Value | Cursor | Meaning |
| ----- | ------ | ------- |
| `range` | Commit (`--since` required) | Universe members related to `<since>..HEAD` |
| `all` | None | Full enumeration of this skill's domain universe, then caps/filters |
| `staged` | Index | Universe members in the git index — file-oriented skills only |

`all` is not unbounded: skill caps still apply (hint limits, commit limits, run limits).

## File-oriented enumeration

When natural units are files: enumerate eligible paths, then apply this skill's glob filter when configured; unset/empty glob means no glob filter. Resolve the universe from the user prompt **before** invoking detect when the user named paths/globs.

## Interactive discovery

1. Resolve universe from the prompt / Constraints (default = this skill's config).
2. If detect JSON is absent, run `scripts/` detect with the resolved scope (default `all`; use `staged`/`range` when the user named index or SHA range).
3. Classify mechanical output.
4. **Agent complement:** read targets; add in-scope candidates detect cannot see. User-supplied URL/path/symbol is primary evidence when present.
5. Empty detect alone does not force no-op if complement found work.

## This skill (`ci-sweeper`)

| Field | Value |
| ----- | ----- |
| Universe | Failed workflow runs on the relevant branch (scan limit applies) |
| `all` | Limit-bounded failure enumeration |
| `range` | Failures related to the `--since` window |
| `staged` | noop / deprecated (index cursor does not apply to CI runs) |
| Detect script | `scripts/detect_ci_failures.sh` |
| Interactive note | Prefer user-supplied run URL / job / log as primary evidence; still run detect when JSON is absent and tools allow; if `gh`/auth missing, fall back to user context — do not silent no-op |
