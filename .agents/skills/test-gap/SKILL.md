---
name: test-gap
description: >-
  Find under-tested code and add meaningful tests without changing production code or existing assertions.
  Use in conversation when the user asks to find missing tests, add tests for an under-tested script or package, or improve test coverage.
  Also the loop entry skill for scheduled runs when automation supplies detect JSON (hotspots, ledger). Interactive default is survey only;
  edit test files when the user explicitly requests adding tests or automation sets may_edit in Constraints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

**UTILITY SKILL** — add tests for under-tested code; never change production code or weaken existing tests.

## Input

- **Interactive (required):** natural-language request; optional target path. Constraints in `## Constraints` or [category-scope.md](references/category-scope.md).
- **Automation (optional):** detect JSON in the prompt (`hotspots[]`, `ledger.processed[]`) from the skill detect script. Detect never states that tests are missing — you select the target.

## Execution Scope

### USE FOR:

- Survey: pick under-tested targets (see Target selection) and report candidates
- Apply: add new test files or new test cases for one target within the allowlist

### DO NOT USE FOR:

- Editing production code (report a suspected bug in the PR body instead)
- Deleting, skipping, commenting out, or loosening existing tests or assertions
- CI repair (use `ci-sweeper`), structural refactors (use `refactor`), reports (use `tech-debt`)
- Editing caller state or ledger files (the caller owns them)

## Reference Files Guide

- [category-scope.md](references/category-scope.md) (always read)
- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (read when detect JSON is present)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [category-pr-body-links.md](references/category-pr-body-links.md) (read at PR body synthesis)

## Workflow

Resolve `may_edit` first:

| Source                                 | `may_edit`                                                                                           |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Interactive — default                  | `false` — survey only                                                                                |
| Interactive — add/write tests language | `true` — examples: テストを追加して, add tests for, write tests                                      |
| Automation — `## Constraints`          | value of `may_edit` in [category-automation-envelope.md](references/category-automation-envelope.md) |

### Target selection

1. Discover the stack and test layout from the repository (existing test directories, CI config, `AGENTS.md`/`CLAUDE.md` rules). Do not assume a language. A caller may restrict the stack (for example to one test framework); when it does, the caller instructions win.
2. Candidate sources, in order: files in `hotspots[]` (churn) without a matching test; production files with no paired test (for shell scripts, a missing Bats suite per the repository's TEST rules); public functions with no test.
3. `ledger.processed[]` lists test file paths. Exclude a target whose paired test file path appears there; adding another new test file for that same target also counts as selecting it again. Re-select it only with a stated new reason (for example the production file changed since), written in the PR body. An item under Open Rejections from a previous run counts as a stated new reason for selecting that target again.
4. Choose exactly one target. Prefer the file with the highest churn and the clearest observable behavior.

### Apply

1. Read the target and its callers. Read the nearest existing tests and copy their layout, helpers, and naming.
2. Write tests that assert observable behavior: return values, side effects, error paths. A test that cannot fail is not acceptable.
3. Place files only within `Allowed paths` (interactive: the repository's existing test directories). Never edit production files.
4. You cannot run the tests in this environment. Do not claim you ran them. State the command CI will run and the expected result in `## Verification`.
5. When `may_edit` is `false`, or `write_target` is not `fix`, emit the survey shape and stop.

### Error Handling

| Condition                                      | Severity    | Action                                             |
| ---------------------------------------------- | ----------- | -------------------------------------------------- |
| Detect `status: "error"`                       | Fatal       | Stop; report the error text                        |
| No under-tested target outside the ledger      | Info        | Report no-op; do not write files                   |
| Target needs production changes to be testable | Recoverable | Choose another target or list it in `### Deferred` |
| Path outside the allowlist                     | Recoverable | List in `### Deferred`; do not edit                |
| Unable to find the repository's test layout    | Recoverable | Survey only; explain what is missing               |

## Output

Follow [common-output-format.md](references/common-output-format.md). Load `assets/pr-body-template.md` (apply) or `assets/pr-body-template-survey.md` (survey) only at synthesis.
