# Refactor Checklist

Gate IDs are for agent self-check and Deferred/Watch reasons. Candidate identity in reports remains **path / symbol / hint** — not these IDs.

## Intent

### INTENT-01: Classify before survey edits

- [ ] Intent is **structural** (default) or **architecture-improvement** per [category-operations.md](category-operations.md)
- [ ] Ambiguous wording → **structural**
- [ ] Architecture triggers recognized: architecture improvement, redesign, module boundary, deep module, responsibility split, testability at seams
- **PASS** if intent is set before discovering candidates

### INTENT-02: Architecture path gates

- [ ] Architecture without user-approved slice → Phase A proposal only; Outcome `proposal`; no apply
- [ ] Architecture Phase B → user names **one** approved slice; apply as O2 cap only
- [ ] Do not require users to pass `max_tier: O3` or bare O3 labels
- **PASS** if architecture never skips proposal → approve → one slice

## Survey

### SURVEY-01: Full in-scope discovery

- [ ] Phase A runs **before** any file edit when `may_edit` is `true`; sole phase when `may_edit` is `false`
- [ ] Discover **all** candidates in scope — automation: every `hints[]` entry; interactive: user paths or in-scope exploration
- [ ] Prefer structure-driven evidence (duplication, oversized unit, user-named symbol) — not lint/SAST smell scores
- [ ] Zero candidates → Outcome `no-op`; stop
- **PASS** if every in-scope hint/path was considered

### SURVEY-02: Apply vs watch marking

- [ ] Emit `### Candidates` with one row per candidate ([common-output-format.md](common-output-format.md))
- [ ] Mark each row **apply** or **watch**
- [ ] Lint/style-only, feature/API, comment-only, or cross-boundary → **watch**
- [ ] Suggested approach uses plain-language direction from evidence + [category-operations.md](category-operations.md) (dedupe, extract, clarify, shallow move) — load [category-techniques.md](category-techniques.md) when `may_edit` is `true`
- **PASS** if no apply row is lint-primary or cross-boundary

### SURVEY-03: Read before classifying

- [ ] Read target files/symbols (or hint paths) before emitting Candidates
- [ ] Do not invent APIs, paths, or behavior
- **PASS** if every Candidate cites concrete evidence from the tree

## Apply

Load [category-techniques.md](category-techniques.md) when `may_edit` is `true`.

### APPLY-01: Edit gate and batch

- [ ] Run only when `may_edit` is `true` (interactive default; automation per `## Constraints`)
- [ ] Apply **every** candidate marked **apply** in survey order
- [ ] Pick **one** technique per candidate from [category-techniques.md](category-techniques.md)
- [ ] Failed gate for one candidate → revert that edit; record under **Deferred**; continue remaining candidates
- **PASS** if no apply edit runs with `may_edit` false

### APPLY-02: Closed structural set

- [ ] Treat `duplication_block` as **logic duplication** — dedupe executable/shared logic, not documentation or comment-only templates
- [ ] When deduplicating logic, preserve file headers and symbol documentation unless consolidating documented behavior in the same edit
- [ ] Stay in closed depth tiers O1/O2 ([category-operations.md](category-operations.md)): **O1** = local structure same behavior; **O2** = plus shallow same-package move
- [ ] No public API semantics changes; no feature behavior changes
- [ ] No one-shot cross-boundary apply or GoF introduction — architecture path is propose → approve → one O2 slice
- [ ] Automation apply (`may_edit: true`): structural intent only; no architecture Phase A/B during apply
- **PASS** if every edit is behavior-preserving O1/O2 structural work

## Verification

Load [category-verification.md](category-verification.md) when `may_edit` is `true`.

### VERIFY-01: Stack gates

- [ ] Establish characterization / stack gate before or with edits ([category-verification.md](category-verification.md))
- [ ] Architecture Phase A: skip apply and stack validation — proposal only
- [ ] Re-run stack gates on all touched packages after Phase B completes
- [ ] If a same-package move (O2) lacks an adequate gate → downgrade that candidate to O1 or watch
- [ ] Unsupported language → watch on candidate — do not invent tests for an unknown stack
- [ ] Lint tools may run as part of a stack gate; lint-only findings must not expand the target
- **PASS** if apply claims match commands actually run

## Output

### OUT-01: Single result shape

- [ ] Pick **one** result shape per run — survey-only **or** apply — per [common-output-format.md](common-output-format.md) (interactive) or [common-output-format-automation.md](common-output-format-automation.md) (automation)
- [ ] **Survey** (`may_edit: false`): `### Candidates` (+ optional `### Watch`); **MUST NOT** emit `### Changes`, `### Deferred`, or `## Verification`
- [ ] **Apply** (`may_edit: true`): `### Changes` (+ optional `### Deferred`) and `## Verification`; **MUST NOT** emit `### Candidates` or `### Watch` in final output
- [ ] Classify intent and depth tier internally before edits; **do not** put `O1`/`O2`/`O3`, intent labels, or Fowler technique names in user-facing tables
- [ ] Before PR synthesis (apply mode): reconcile **Changes** / **Deferred** with `git diff --name-only`
- [ ] Architecture Phase A: use survey shape + **Architecture Proposal**; no file edits
- [ ] Do not claim validation passed when commands failed or were not run
- **PASS** if survey and apply shapes are not mixed

## Error handling

- Nothing actionable after survey → Outcome `no-op`, empty Changes, stop
- Validation fails for one candidate → revert that candidate; Deferred; continue batch
- Missing validation tooling named in Instructions → note in Session Metrics; watch affected candidates
