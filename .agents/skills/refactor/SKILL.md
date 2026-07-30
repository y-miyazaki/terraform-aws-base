---
name: refactor
description: >-
  Behavior-preserving structural refactors with verification gates. Survey candidates
  first, then apply all actionable in-scope structural fixes in one run — interactively or from
  optional automation hints (duplication_block, oversized_unit). Default is survey only; apply
  edits only when the user explicitly requests apply or automation sets may_edit in
  Constraints. Architecture: proposal first, one approved slice per apply batch. Not for
  lint-only style, features, behavior-changing bugfixes, or upgrades.
  Use when surveying or applying structural refactors interactively or from automation hints.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.8.6"
---

**UTILITY SKILL** — structural refactor survey and apply, not feature work.

## Input

- **Interactive (required):** paths/symbols and optional mode — constraints in `## Constraints` or [category-scope.md](references/category-scope.md)
- **Automation (optional):** detect JSON with `hints[]` in prompt — from a caller or optional skill detect script; not required for interactive runs. Read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Refactor report per [common-output-format.md](references/common-output-format.md). Survey shape when no files are edited; apply shape when edited — within [category-scope.md](references/category-scope.md). Automation path: [common-output-format-automation.md](references/common-output-format-automation.md) and [category-automation-envelope.md](references/category-automation-envelope.md).

## Execution Scope

### USE FOR:

- Survey structural candidates; dedupe, extract/inline, clarify, shallow moves; automation hints; architecture Phase A/B; characterization tests

### DO NOT USE FOR:

- Lint/style-only; features/API/behavior fixes; cross-boundary apply; platform-wide architecture refactors; external debt-survey apply input

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-contract.md](references/category-contract.md) (always read)
- [category-verification.md](references/category-verification.md) (always read — apply vs watch and Phase B gates)
- [category-techniques.md](references/category-techniques.md) (read when may_edit is true)
- [category-input-schema.md](references/category-input-schema.md) (read when structured mode JSON or automation detect JSON is present)
- [category-automation-envelope.md](references/category-automation-envelope.md) (read on automation path)
- [common-output-format-automation.md](references/common-output-format-automation.md) (read on automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Phases, modes, depth tiers, and intent: [category-contract.md](references/category-contract.md). Self-check gates: [common-checklist.md](references/common-checklist.md).

Canonical sequence: resolve `may_edit` → Phase A (discover/classify; emit only when stopping) → Phase B only when edit-authorized → emit **one** result shape (OUT-01).

Resolve **may_edit** before Phase B. Interactive rows — first match wins:

| Source                                                      | `may_edit`                                                                                                                                                 |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Interactive — structured JSON `mode` present                | From `mode` only (`survey` → `false`; `apply` → `true`) — wins over natural-language; load [category-input-schema.md](references/category-input-schema.md) |
| Interactive — explicit apply language in the same request   | `true` — examples: apply, 適用して, "apply the candidates". Do **not** treat bare skill name `refactor` or bare `fix` as apply                             |
| Interactive — follow-up after a prior survey in the session | `true` when the user explicitly asks to apply listed candidates                                                                                            |
| Interactive — default                                       | `false` — survey only; do not edit files                                                                                                                   |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md)                                   |

When `may_edit` is `true`, resolve `write_target`: interactive → `fix`; automation → from `## Constraints`. Do not branch on other caller metadata. Before Phase B, load [category-techniques.md](references/category-techniques.md).

Phase B runs only when `may_edit` is `true` and `write_target` is `fix`. Architecture without `approved_slice` never enters Phase B (INTENT-02).

### Phase A — Survey (always)

Discover and classify only. Emit a final report from Phase A **only** when this run will not enter Phase B (see Interactive / Automation paths).

1. Resolve scope ([category-scope.md](references/category-scope.md)); parse structured/detect JSON when present ([category-input-schema.md](references/category-input-schema.md)).
2. Classify intent ([category-contract.md](references/category-contract.md)).
3. **Architecture without `approved_slice`:** emit survey shape with `### Architecture Proposal` only; stop (INTENT-02). Do **not** treat as zero-actionable no-op.
4. Discover candidates (SURVEY-01): structural → all in-scope; architecture Phase B → **only** the `approved_slice`. Read targets before classifying (SURVEY-03); route apply-worthy → Candidates, else → Watch (SURVEY-02).
5. Structural zero actionable → no-op report; stop.

### Phase B — Apply (`may_edit: true` and `write_target: fix`)

1. For each **apply** candidate: one technique ([category-techniques.md](references/category-techniques.md)); gate ([category-verification.md](references/category-verification.md)); on failure revert → Deferred; continue (APPLY-01).
2. Re-run gates on touched areas; emit apply shape; reconcile with `git diff --name-only` (OUT-01).

### Automation path (`hints[]` in detect JSON)

1. Parse detect JSON; read `may_edit` / `write_target` from `## Constraints`.
2. Empty/`skip` → no-op; stop.
3. Phase A on **all** `hints[]` (structural only — no architecture Phase A/B).
4. `may_edit: false` or `write_target` ≠ `fix` → emit survey shape + Session Metrics (note expected `write_target: fix` when mismatched); no Phase B.
5. Else → Phase B; emit apply shape + Session Metrics ([category-automation-envelope.md](references/category-automation-envelope.md)).

### Interactive path

1. Resolve `may_edit` (table above).
2. Phase A (architecture without `approved_slice` stops inside Phase A step 3).
3. `may_edit: false` or `write_target` ≠ `fix` → emit survey shape; stop.
4. Else → Phase B; emit apply shape.

### Error Handling

| Condition                                        | Severity    | Action                                                                          |
| ------------------------------------------------ | ----------- | ------------------------------------------------------------------------------- |
| Detect script non-zero exit or `status: "error"` | Fatal       | Read stdout; stop — do not treat as success-path detect JSON                    |
| Automation: empty/`skip`                         | Info        | No-op report; stop                                                              |
| Survey: zero candidates                          | Info        | No-op report; stop                                                              |
| Architecture request without slice               | Recoverable | Architecture proposal only; stop                                                |
| Lint-primary or feature/API candidate            | Recoverable | Watch on candidate; skip apply                                                  |
| Weak or failed gate for one candidate            | Recoverable | Revert that candidate; Deferred; continue                                       |
| Cross-boundary or out-of-scope target            | Recoverable | Watch on candidate; skip apply                                                  |
| Apply requested but `may_edit` is `false`        | Info        | Survey only; note that edits require explicit apply request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix`    | Recoverable | Survey only; note expected `write_target: fix`                                  |

### Examples

- Prompt: `Survey structural refactor candidates in this package`
- Result: Survey report per [references/common-output-format.md](references/common-output-format.md); apply only when `may_edit` is true, `write_target` is `fix`, and candidates are marked apply.
