---
name: test-gap
description: >-
  Find under-tested code and add meaningful tests without changing production
  code or existing assertions. Use in conversation when the user asks to find
  missing tests, add tests for an under-tested script or package, or improve
  test coverage. Also the loop entry skill for scheduled runs when automation
  supplies detect JSON (hotspots, ledger). Interactive default is survey only;
  edit test files when the request asks for changes to be made (for example
  fix, apply, or update) or automation sets agent_edit_allowed in Constraints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.1.0"
---

**UTILITY SKILL** — add tests for under-tested code; never change production code or weaken existing tests.

## Input

- **Interactive (required):** natural-language request; optional target path. Constraints in `## Constraints` or [category-scope.md](references/category-scope.md).
- **Automation (optional):** detect JSON in the prompt (`hotspots[]`, `ledger.processed[]`) from a caller or the optional skill detect script; not required for interactive runs. Read `agent_edit_allowed` and `agent_edit_target` from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md). Detect never states that tests are missing — you select the target.

## Output Specification

Test-gap report per [common-output-format.md](references/common-output-format.md). Survey shape when no files are edited; apply shape when test files are edited — within [category-scope.md](references/category-scope.md). Load `assets/pr-body-template.md` (apply) or `assets/pr-body-template-survey.md` (survey) only at synthesis.

## Execution Scope

### USE FOR:

- Survey: rank under-tested targets (see Target selection) and report candidates
- Apply: add new test files or new test cases for one target within the allowlist

### DO NOT USE FOR:

- Editing production code (report a suspected bug under `### Deferred` instead)
- Deleting, skipping, commenting out, or loosening existing tests or assertions
- CI repair (use `ci-sweeper`), structural refactors (use `refactor`), reports (use `tech-debt`)
- Editing caller state or ledger files (the caller owns them)

## Reference Files Guide

- [category-scope.md](references/category-scope.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-detect-scope.md](references/category-detect-scope.md) (read on interactive path)
- [category-input-schema.md](references/category-input-schema.md) (read when detect JSON is present or the optional detect script is run)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read when synthesizing the PR body)
- `assets/pr-body-template.md` and `assets/pr-body-template-survey.md` (read when synthesizing the PR body)

## Workflow

Resolve **agent_edit_allowed** before selecting targets:

| Source                                                                                                          | `agent_edit_allowed`                                                                                                                         |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Interactive — default: the request asks to look, check, triage, or survey, or only names the skill              | `false` — survey only; do not edit files                                                                                                     |
| Interactive — the request asks for changes to be made (for example fix, apply, 修正して, 適用して, update, add) | `true`                                                                                                                                       |
| Interactive — follow-up after a survey asking to apply                                                          | `true`                                                                                                                                       |
| Automation — `## Constraints`                                                                                   | `agent_edit_allowed: true` or `agent_edit_allowed: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When intent is unclear, survey and offer to apply — edits are harder to undo than a report.

When `agent_edit_allowed` is `true`, resolve `agent_edit_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `agent_edit_target` from `## Constraints`. Do not branch on other caller metadata outside `## Constraints`.

### Target selection

1. Parse detect JSON when present; otherwise resolve the detect universe from the prompt ([category-detect-scope.md](references/category-detect-scope.md)), run this skill's optional detect script `scripts/detect_test_gap.sh` (default `--scope all`), then Agent-complement beyond its churn facts; if detect cannot run, gather candidates from the user request and repository tools instead of silent no-op. Load [category-input-schema.md](references/category-input-schema.md) when parsing detect output. On detect non-zero exit or `status: "error"`, read stdout and stop.
2. Discover the stack and test layout from the repository (existing test directories, CI config, repository agent rules). Do not assume a language. A caller may restrict the stack (for example to one test framework); when it does, the caller instructions win.
3. Candidate sources, in order: files in `hotspots[]` (churn) without a matching test; production files with no paired test (per the repository's test-pairing conventions, if any); public functions with no test.
4. `ledger.processed[]` lists test file paths. Exclude a target whose paired test file path appears there; adding another new test file for that same target also counts as selecting it again. Re-select it only with a stated new reason (for example the production file changed since), written in Overview. An `## Open Rejections` section, when the caller supplies one in the prompt (optional; it lists targets a reviewer rejected in an earlier run, with the reason), counts as a stated new reason for selecting a listed target again.
5. Rank candidates: prefer the highest churn and the clearest observable behavior.

### Edit gate

1. IF no candidate remains after selection → emit survey no-op per [common-output-format.md](references/common-output-format.md) (Overview explains no-op); stop.
2. IF `agent_edit_allowed` is `false` → go to Survey.
3. ELSE IF `agent_edit_target` is not `fix` → go to Survey; note expected `agent_edit_target: fix` in Overview.
4. ELSE → go to Apply.

### Survey

1. List the ranked candidates (one row each) under `### Candidates` with the behaviors each test should assert.
2. Emit the survey shape; stop — do not edit files.

### Apply

1. Choose exactly one target: the top-ranked candidate.
2. Read the target and its callers. Read the nearest existing tests and copy their layout, helpers, and naming.
3. Write tests that assert observable behavior: return values, side effects, error paths. A test that cannot fail is not acceptable.
4. Place files only within `Allowed paths` (interactive: the repository's existing test directories). Never edit production files.
5. Run the repository's existing test command for the new tests when it is available and report the actual result in `## Verification`. When you cannot run it (no tooling, or the caller says tests are not run here), state the command and expected result and mark it not run — never claim tests passed without running them.
6. Emit the apply shape; reconcile `### Changes` / `### Deferred` with `git diff --name-only`.

On the automation path, append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md) at every stop.

### Error Handling

| Condition                                                           | Severity    | Action                                                       |
| ------------------------------------------------------------------- | ----------- | ------------------------------------------------------------ |
| Detect script non-zero exit or `status: "error"` (when invoked)     | Fatal       | Read stdout; stop — do not treat as success-path detect JSON |
| No under-tested target outside the ledger                           | Info        | Emit survey no-op; do not write files                        |
| Edit requested but `## Constraints` set `agent_edit_allowed: false` | Info        | Survey only; note that the caller Constraints disallow edits |
| `agent_edit_allowed` true with `agent_edit_target` not `fix`        | Recoverable | Survey only; note expected `agent_edit_target: fix`          |
| Target needs production changes to be testable                      | Recoverable | Choose another target or list it in `### Deferred`           |
| Path outside the allowlist                                          | Recoverable | List in `### Deferred`; do not edit                          |
| Unable to find the repository's test layout                         | Recoverable | Survey only; explain what is missing                         |

### Examples

- Prompt: `Find under-tested scripts in this repository`
- Result: Survey report per [references/common-output-format.md](references/common-output-format.md); add tests for one target only when `agent_edit_allowed` is true and `agent_edit_target` is `fix`.
