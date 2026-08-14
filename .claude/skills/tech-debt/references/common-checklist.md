# Tech-Debt Checklist

Gate IDs are for agent self-check and Deferred/Watch reasons. Finding identity in reports remains **path + kind + snippet/metric** — not these IDs.

## Classification

Read [category-debt-taxonomy.md](category-debt-taxonomy.md) first. For each signal/hotspot:

### CLASS-01: Category, severity, nature

1. Assign one primary `category` using the decision order in the taxonomy
2. Assign severity → persisted report section (Critical / High-Priority / Watch / Noise) and PR row placement (`### Candidates` / `### Watch` for survey; `### Changes` / `### Deferred` for apply)
3. Add `nature` only when narrative evidence is clear (snippet, ADR, trade-off note) — omit for metrics-only signals (churn, `eol_hint`, `pin_drift`)

- **PASS** if every Candidate row has category + severity mapping

### CLASS-02: Delegate

- [ ] Assign Delegate per taxonomy row (`refactor`, `docs-updater`, `self`, `human`, …)
- [ ] Structural work → Delegate `refactor` (do not apply structural edits in this skill)
- **PASS** if no finding lacks a Delegate when Candidates are emitted

## Detect vs lint

### CLASS-03: Detect facts only

- [ ] Classify detect facts only. Do not run or restate linter/SAST results
- [ ] Use `code_quality` for maintainability inferred from markers/churn plus context — not linter metric duplication
- [ ] Markers (`todo_comment`, `fixme`, `hack`, `xxx`) are secondary — default to Watch unless **systemic** (same marker theme or debt pattern across multiple core files, packages, or architectural boundaries — not an isolated comment)
- **PASS** if no Candidate restates a linter metric as its sole evidence

## Out of scope

Report EOL/deprecation facts; do not recommend new-technology or tool migration playbooks.

## Scope

### SCOPE-01: Allowlist and caps

- [ ] On the automation path, respect caller `allowlist` / `denylist` per [category-scope.md](category-scope.md) (allowlist in `## Constraints`; denylist enforced by verifier)
- [ ] Read source outside the allowlist for evidence only — never edit it
- [ ] Cap Critical + High-Priority persisted findings at 25; retain all Critical first, then High-Priority until the cap; defer overflow to Watch with a truncation note
- [ ] Do not invent APIs, paths, metrics, ownership, or CVEs
- **PASS** if no edit or report write escapes allowlist/denylist

## Evidence

### EVID-01: Read before classify

- [ ] Cite `path` + `line` (or hotspot metric) from detect facts
- [ ] Read ±30 lines around each signal before classifying
- [ ] Prefer taxonomy source language in `Reason` (e.g. "maintainability / complexity", "version lock", "wrong Diátaxis form")
- **PASS** if every non-Noise finding has path-level evidence from the tree

### EVID-02: Previous report comparison

When `previous_report` is set and readable, match findings by **identity**, not line number alone — load comparison rules below (and the previous file) when that path exists:

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

- **PASS** if previous_report set ⇒ comparison labels are present or absence is noted in Overview

## Edit

### EDIT-01: Closed-set apply only

- [ ] When `may_edit` is `false`, emit survey shape — do not write `report_file`
- [ ] When `may_edit` is `true`, write allowlisted `report_file` and apply closed-set fixes only (`broken_doc_ref`, `stale_doc`, simple `pin_drift`) per [category-scope.md](category-scope.md)
- [ ] Do not perform structural refactors here (Delegate to refactor)
- **PASS** if apply edits are closed-set only

## Output

### OUT-01: Survey vs apply shape

- [ ] Emit survey or apply shape per [common-output-format.md](common-output-format.md)
- [ ] Include `Category` (and `Nature` when set) on every candidate/finding row
- **PASS** if shapes are not mixed and Category is present on every row

## Error Handling

| Condition                                                    | Severity    | Action                                                                    |
| ------------------------------------------------------------ | ----------- | ------------------------------------------------------------------------- |
| `skip` true, or both `signals` and `hotspots` empty          | recoverable | Emit survey no-op; stop without `report_file`                             |
| Evidence `path` missing or unreadable                        | recoverable | Classify as Watch with reason; continue other items                       |
| `previous_report` set but file missing                       | recoverable | Proceed without resolved/regression notes; note absence in Summary        |
| `report_file` outside allowlist or on denylist               | blocking    | Do not write any report file; note in Summary; still emit session summary |
| Finding would require invented APIs, paths, metrics, or CVEs | fatal       | Omit the finding (or Noise / Ignore); never fabricate evidence            |

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
