---
name: refactor
description: >-
  Behavior-preserving structural refactors with stack gates. Survey candidates
  first, then apply all actionable in-scope structural fixes in one run — interactively or from
  automation hints (duplication_block, oversized_unit). Default is survey only; apply
  edits only when the user explicitly requests apply or automation sets may_edit in
  Constraints. Architecture: proposal first, one approved slice per apply batch. Not for
  lint-only style, features, behavior-changing bugfixes, or upgrades.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.6.0"
---

**UTILITY SKILL** — structural refactor survey and apply, not feature work.

## Input

- **Interactive:** paths/symbols and optional mode — constraints in `## Constraints` or [category-scope.md](references/category-scope.md)
- **Automation:** detect JSON with `hints[]` in prompt; read `may_edit`, `write_target`, and `report_file` (when `write_target: report`) from `## Constraints` per [category-automation-envelope.md](references/category-automation-envelope.md)

Path allowlist, when present, arrives in `## Constraints`.

## Output Specification

Refactor report per [common-output-format.md](references/common-output-format.md). Survey shape when no files are edited; apply shape when edited — within [category-scope.md](references/category-scope.md). Automation path: [common-output-format-loop.md](references/common-output-format-loop.md) and [category-automation-envelope.md](references/category-automation-envelope.md).

## Execution Scope

### USE FOR:

- Survey structural candidates; dedupe, extract/inline, clarify, shallow moves; automation hints; architecture Phase A/B; characterization tests

### DO NOT USE FOR:

- Lint/style-only; features/API/behavior fixes; cross-boundary apply; loop architecture; tech-debt input

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-operations.md](references/category-operations.md) (always read)
- [category-techniques.md](references/category-techniques.md) (always read)
- [category-verification.md](references/category-verification.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read)
- [category-automation-envelope.md](references/category-automation-envelope.md) (always read — automation path)
- [common-output-format-loop.md](references/common-output-format-loop.md) (always read — automation path)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

Resolve **may_edit** before Phase B:

| Source                                                      | `may_edit`                                                                                                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Interactive — default                                       | `false` — Phase A survey only; do not edit files                                                                         |
| Interactive — structured JSON `mode`                        | `survey` → `false`; `apply` → `true`; omit → `false` per [category-input-schema.md](references/category-input-schema.md) |
| Interactive — apply language in the same request            | `true` — examples: apply, refactor, fix, 適用して                                                                        |
| Interactive — follow-up after a prior survey in the session | `true` when the user asks to apply, fix, or refactor listed candidates                                                   |
| Automation — `## Constraints`                               | `may_edit: true` or `may_edit: false` from [category-automation-envelope.md](references/category-automation-envelope.md) |

When `may_edit` is `true`, resolve `write_target`: on the **interactive** path use `fix` (this skill); on the **automation** path read `write_target` from `## Constraints`. Do not branch on `level` or `delivery`.

Every run has **Phase A — Survey** (discover candidates). **Phase B — Apply** runs only when `may_edit` is `true` and `write_target` is `fix`.

### Phase A — Survey (always)

1. Parse input per [category-input-schema.md](references/category-input-schema.md); read constraints; resolve scope.
2. Classify intent per [category-operations.md](references/category-operations.md). Architecture without slice → Phase A architecture proposal; stop before apply.
3. Discover **all** structural candidates in scope — automation: every `hints[]` entry plus in-scope evidence in hinted files; interactive: user paths/symbols or in-scope exploration.
4. Lint-primary, feature/API, comment-only overlap, or cross-boundary items → mark **watch** on the candidate row; do not plan apply.
5. Emit survey result shape per [common-output-format.md](references/common-output-format.md) (`### Candidates` only; no Changes/Deferred/Verification). If zero actionable candidates → no-op report; stop.

### Phase B — Apply (`may_edit: true` and `write_target: fix` only)

1. For each **apply** candidate in survey order: pick one technique per [category-techniques.md](references/category-techniques.md); minimal in-scope structural edit.
2. Gate per [category-verification.md](references/category-verification.md). Failed gate for one candidate → revert that edit; move row to **Deferred**; continue remaining candidates.
3. Re-run stack gates on all touched packages before synthesis.
4. Emit one **apply** report: `### Changes`, `### Deferred`; omit `### Candidates`. Reconcile with `git diff --name-only` before synthesis.

### Automation path (`hints[]` in detect JSON)

1. Parse [category-input-schema.md](references/category-input-schema.md); read `may_edit` from [category-automation-envelope.md](references/category-automation-envelope.md).
2. If empty/`skip` → no-op report; stop.
3. Run Phase A on **all** `hints[]` entries (not only the first).
4. When `may_edit` is `false` → stop after Phase A; emit survey shape with `### Candidates`; load `assets/pr-body-template-survey.md` at synthesis; append `## Session Metrics` per [category-automation-envelope.md](references/category-automation-envelope.md); no file edits.
5. When `may_edit` is `true` and `write_target` is `fix` → Phase B for every apply candidate within allowlist; structural intent only; load `assets/pr-body-template.md` at synthesis; append `## Session Metrics`.
6. When `may_edit` is `true` and `write_target` is not `fix` → stop after Phase A; emit survey shape; note expected `write_target: fix` in Overview; append `## Session Metrics`.

### Interactive path

1. Resolve `may_edit`: structured JSON `mode` per [category-input-schema.md](references/category-input-schema.md) (`survey` → `false`, `apply` → `true`; default `survey` when omitted); else natural language per the table above (default `false` unless apply language or follow-up).
2. Run Phase A.
3. `may_edit: false` → emit **survey** result shape; stop; no file edits.
4. `may_edit: true` → implicit `write_target: fix` on the interactive path; run Phase B for all apply candidates; architecture without `approved_slice` → proposal only (no Phase B).
5. Emit result shape per [common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                                     | Severity    | Action                                                                          |
| --------------------------------------------- | ----------- | ------------------------------------------------------------------------------- |
| Automation: empty/`skip`                      | Info        | No-op report; stop                                                              |
| Survey: zero candidates                       | Info        | No-op report; stop                                                              |
| Architecture request without slice            | Recoverable | Architecture proposal only; stop                                                |
| Lint-primary or feature/API candidate         | Recoverable | Watch on candidate; skip apply                                                  |
| Weak or failed gate for one candidate         | Recoverable | Revert that candidate; Deferred; continue                                       |
| Cross-boundary or out-of-scope target         | Recoverable | Watch on candidate; skip apply                                                  |
| Apply requested but `may_edit` is `false`     | Info        | Survey only; note that edits require explicit apply request or `may_edit: true` |
| `may_edit` true with `write_target` not `fix` | Recoverable | Survey only; note expected `write_target: fix`                                  |
