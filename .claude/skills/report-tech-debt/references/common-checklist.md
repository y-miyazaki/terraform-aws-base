# loop-report-tech-debt Checklist

## Classification

Read [category-debt-taxonomy.md](category-debt-taxonomy.md) first. For each signal/hotspot:

1. Assign one primary `category` using the decision order in the taxonomy
2. Assign severity → report section (Critical / High-Priority / Watch / Noise)
3. Add `nature` only when narrative evidence is clear (snippet, ADR, trade-off note) — omit for metrics-only signals (churn, `eol_hint`, `pin_drift`)

## Detect vs lint

Classify detect facts only. Do not run or restate linter/SAST results. Use `code_quality` for maintainability inferred from markers/churn plus context — not linter metric duplication. Markers (`todo_comment`, `fixme`, `hack`, `xxx`) are secondary — default to Watch unless **systemic** (same marker theme or debt pattern across multiple core files, packages, or architectural boundaries — not an isolated comment).

## Out of scope

Report EOL/deprecation facts; do not recommend new-technology or tool migration playbooks.

## Scope Guards

- On loop path, respect caller `allowlist` / `denylist` per `category-scope.md` (allowlist in `## Constraints`; denylist enforced by verifier)
- Read source outside the allowlist for evidence only — never edit it
- Cap Critical + High-Priority persisted findings at 25; retain all Critical first, then High-Priority until the cap; defer overflow to Watch with a truncation note
- Do not invent APIs, paths, metrics, ownership, or CVEs

## Evidence Rules

- Cite `path` + `line` (or hotspot metric) from detect facts
- Read ±30 lines around each signal before classifying
- When `previous_report` is set, compare per [Previous report comparison](#previous-report-comparison) — match by path + kind + snippet/context; ignore line-number drift alone
- Prefer taxonomy source language in `Reason` (e.g. "maintainability / complexity", "version lock", "wrong Diátaxis form")

## Previous report comparison

When `previous_report` is set and readable, match findings by **identity**, not line number alone:

| Priority | Identity key                                      | Notes                                             |
| -------- | ------------------------------------------------- | ------------------------------------------------- |
| 1        | `path` + `kind` + normalized `snippet` / Evidence | Strip whitespace; compare substantive text        |
| 2        | `path` + `kind`                                   | When snippet drifted but same marker or debt type |
| 3        | `path` + `metric` (hotspots)                      | Churn-only hotspots                               |

- **Resolved**: identity in previous Critical/High/Watch tables absent from current signals/hotspots with no equivalent source evidence
- **Recurring**: same identity in both runs
- **Regression**: identity listed under previous "Resolved Since Previous" but present again this run
- **New**: identity in current run with no previous match

Do not mark Resolved when only `line` shifted but `path` + `kind` + snippet still match.

## Output

- Emit the session summary sections per `common-output-format.md`
- Include `Category` (and `Nature` when set) on every Critical / High-Priority / Watch item
- At `L1`, emit session summary only — do not write `report_file`
- At `L2`/`L3`, write only allowlisted `report_file` per [category-scope.md](category-scope.md)

## Error Handling

| Condition                                                    | Severity    | Action                                                                                                     |
| ------------------------------------------------------------ | ----------- | ---------------------------------------------------------------------------------------------------------- |
| `skip` true, or both `signals` and `hotspots` empty          | recoverable | Emit full session summary; Outcome `No technical debt signals detected`; do not create `report_file`; stop |
| Evidence `path` missing or unreadable                        | recoverable | Classify as Watch with reason; continue other items                                                        |
| `previous_report` set but file missing                       | recoverable | Proceed without resolved/regression notes; note absence in Summary                                         |
| `report_file` outside allowlist or on denylist               | blocking    | Do not write any report file; note in Summary; still emit session summary                                  |
| Finding would require invented APIs, paths, metrics, or CVEs | fatal       | Omit the finding (or Noise / Ignore); never fabricate evidence                                             |

## Examples

| Signal                                                 | Category                         | Section                   |
| ------------------------------------------------------ | -------------------------------- | ------------------------- |
| `TODO: extract shared validator` with clear call sites | `code_quality`                   | High-Priority             |
| `go.mod` pin on EOL major blocking upgrades            | `dependency_version`             | High-Priority or Critical |
| README still points at deleted workflow                | `documentation`                  | High-Priority             |
| Hardcoded secret-like token in sample config           | `security`                       | Critical (report only)    |
| High churn file, no concrete defect                    | `code_quality` or `architecture` | Watch                     |
| `TODO: maybe later` with no actionable path            | —                                | Noise / Ignore            |
| Same `hack` marker theme across 3+ core service files  | `code_quality` or `architecture` | High-Priority or Watch    |

