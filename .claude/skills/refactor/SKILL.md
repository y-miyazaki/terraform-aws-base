---
name: refactor
description: >-
  Behavior-preserving structural refactors with stack gates. Survey candidates
  first, then apply all actionable O1/O2 fixes in one run — interactively or from
  loop hints (duplication_block, oversized_unit). Survey-only mode lists
  candidates without edits. Architecture: proposal first, one approved slice per
  apply batch. Not for lint-only style, features, behavior-changing bugfixes, or
  upgrades.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "2.5.1"
---

## Input

- **Interactive:** paths/symbols and optional mode — constraints in `## Constraints` or [category-scope.md](references/category-scope.md)
- **Loop:** JSON with `hints[]` — [category-input-schema.md](references/category-input-schema.md)

## Operating levels

`level` arrives in loop JSON — see [category-input-schema.md#operating-levels](references/category-input-schema.md#operating-levels).

## Output Specification

Interactive: [common-output-format.md](references/common-output-format.md) — **survey** and **apply** use different Summary shapes; do not mix. Loop: [common-output-format-loop.md](references/common-output-format-loop.md) — survey loads `assets/pr-body-template-survey.md`; apply loads `assets/pr-body-template.md`.

## Execution Scope

### USE FOR:

- Survey structural candidates; dedupe, extract/inline, clarify, shallow moves; loop hints; architecture Phase A/B; characterization tests

### DO NOT USE FOR:

- Lint/style-only; features/API/behavior fixes; cross-boundary apply; loop architecture; tech-debt input

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-scope.md](references/category-scope.md) (always read)
- [category-operations.md](references/category-operations.md) (always read)
- [category-techniques.md](references/category-techniques.md) (always read)
- [category-verification.md](references/category-verification.md) (always read)
- [category-input-schema.md](references/category-input-schema.md) (always read — loop path)
- [common-output-format-loop.md](references/common-output-format-loop.md) (always read — loop path)
- `assets/pr-body-template.md` (always read — loop apply path)
- `assets/pr-body-template-survey.md` (always read — loop survey path)

## Workflow

Every run has **Phase A — Survey** (discover candidates). **Phase B — Apply** runs only when mode is `apply` and level allows edits.

### Mode resolution

| Source | Default mode | Survey-only triggers |
| ------ | ------------ | -------------------- |
| Interactive | `apply` | User asks to survey, list, inventory, or 洗い出し only |
| Loop `L1` | `survey` | Always — no file edits |
| Loop `L2` / `L3` | `apply` | `skip: true` or empty `hints[]` → no-op |

Explicit JSON `mode`: `survey` \| `apply` overrides defaults. See [category-input-schema.md](references/category-input-schema.md).

### Phase A — Survey (always)

1. Parse input; read constraints; resolve mode and scope.
2. Classify intent per [category-operations.md](references/category-operations.md). Architecture without slice → Phase A architecture proposal; stop before apply.
3. Discover **all** structural candidates in scope — loop: every `hints[]` entry plus in-scope evidence in hinted files; interactive: user paths/symbols or in-scope exploration.
4. Lint-primary, feature/API, comment-only overlap, or cross-boundary items → mark **watch** on the candidate row; do not plan apply.
5. Emit survey result shape per [common-output-format.md](references/common-output-format.md) (`### Candidates` only; no Changes/Deferred/Verification). If zero actionable candidates → no-op report; stop.

### Phase B — Apply (`mode: apply` only)

1. For each **apply** candidate in survey order: pick one technique per [category-techniques.md](references/category-techniques.md); minimal O1/O2 edit.
2. Gate per [category-verification.md](references/category-verification.md). Failed gate for one candidate → revert that edit; move row to **Deferred**; continue remaining candidates.
3. Re-run stack gates on all touched packages before synthesis.
4. Emit one **apply** report: `### Changes`, `### Deferred`; omit `### Candidates`. Reconcile with `git diff --name-only` before synthesis.

### Loop path (`hints[]` in loop JSON)

1. Parse [category-input-schema.md](references/category-input-schema.md); read constraints.
2. If empty/`skip` → no-op report; stop.
3. Run Phase A on **all** `hints[]` entries (not only the first).
4. At `L1` → stop after Phase A; emit **survey** loop report (`pr-body-template-survey.md`); no edits.
5. At `L2` / `L3` → Phase B for every apply candidate within allowlist; structural intent only.
6. Emit loop report per [common-output-format-loop.md](references/common-output-format-loop.md); use survey template at `L1`, apply template at `L2`/`L3`; reconcile with `git diff --name-only` before synthesis.

### Interactive path

1. Resolve mode (`survey` or `apply`; default `apply`).
2. Run Phase A.
3. `survey` mode → emit **survey** result shape; stop; no file edits.
4. `apply` mode → Phase B for all apply candidates; architecture without `approved_slice` → proposal only (no Phase B).
5. Emit **apply** result shape per [common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                              | Severity    | Action                                      |
| -------------------------------------- | ----------- | ------------------------------------------- |
| Loop: empty/`skip`                     | Info        | No-op report; stop                          |
| Survey: zero candidates                | Info        | No-op report; stop                          |
| Architecture request without slice     | Recoverable | Architecture proposal only; stop            |
| Lint-primary or feature/API candidate  | Recoverable | Watch on candidate; skip apply              |
| Weak or failed gate for one candidate  | Recoverable | Revert that candidate; Deferred; continue   |
| Cross-boundary or out-of-scope target  | Recoverable | Watch on candidate; skip apply              |
