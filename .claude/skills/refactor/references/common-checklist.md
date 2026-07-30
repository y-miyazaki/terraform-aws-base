# Refactor Checklist

Gate IDs are for agent self-check and Deferred/Watch reasons. Candidate identity in reports remains **path / symbol / hint** — not these IDs.

## Intent

### INTENT-01: Classify before survey edits

- [ ] Intent is **structural** (default) or **architecture-improvement** per [category-contract.md](category-contract.md)
- [ ] Ambiguous wording → **structural**
- [ ] Architecture triggers recognized: architecture improvement, redesign, module boundary, deep module, responsibility split, testability at seams
- **PASS** if intent is set before discovering candidates

### INTENT-02: Architecture path gates

- [ ] Architecture without user-approved slice → Phase A proposal only; Outcome `proposal`; no apply
- [ ] Architecture Phase B → user names **one** approved slice; apply as O2 cap only when `may_edit` is `true` and `write_target` is `fix`
- **PASS** if architecture never skips proposal → approve → one slice

## Survey

### SURVEY-01: Full in-scope discovery

- [ ] Phase A runs **before** any file edit when `may_edit` is `true`; sole phase when `may_edit` is `false` or when architecture lacks `approved_slice`
- [ ] Discover candidates in scope — automation: every `hints[]` entry; interactive structural: user paths or in-scope exploration; architecture Phase B: **only** the `approved_slice`
- [ ] Prefer structure-driven evidence (duplication, oversized unit, user-named symbol) — not lint/SAST smell scores
- [ ] Zero structural candidates → Outcome `no-op`; stop (architecture proposal is not a no-op)
- **PASS** if every in-scope hint/path/slice was considered

### SURVEY-02: Apply vs watch marking

- [ ] Apply-worthy candidates → `### Candidates`; otherwise → `### Watch` ([common-output-format.md](common-output-format.md)) — do not put watch-only items in Candidates
- [ ] Lint/style-only, feature/API, comment-only, cannot-verify, or cross-boundary → **Watch**
- [ ] Suggested approach uses plain-language direction from evidence + [category-contract.md](category-contract.md) (dedupe, extract, clarify, shallow move) — load [category-techniques.md](category-techniques.md) when `may_edit` is `true`
- **PASS** if no Candidates row is lint-primary or cross-boundary

### SURVEY-03: Read before classifying

- [ ] Read target files/symbols (or hint paths) before emitting Candidates
- **PASS** if every Candidate cites concrete evidence from the tree

## Apply

Load [category-techniques.md](category-techniques.md) when `may_edit` is `true`.

### APPLY-01: Edit gate and batch

- [ ] Run only when `may_edit` is `true` **and** `write_target` is `fix` (interactive default `may_edit: false`; automation per `## Constraints`)
- [ ] Apply **every** candidate marked **apply** in survey order
- [ ] Pick **one** technique per candidate from [category-techniques.md](category-techniques.md)
- [ ] Failed gate for one candidate → revert that edit; record under **Deferred**; continue remaining candidates
- **PASS** if no apply edit runs unless both `may_edit` is true and `write_target` is `fix`

### APPLY-02: Closed structural set

- [ ] Treat `duplication_block` as **logic duplication** — dedupe executable/shared logic, not documentation or comment-only templates
- [ ] When deduplicating logic, preserve file headers and symbol documentation unless consolidating documented behavior in the same edit
- [ ] Stay in closed depth tiers O1/O2 ([category-contract.md](category-contract.md)): **O1** = local structure same behavior; **O2** = plus shallow same-package move
- [ ] No public API semantics changes; no feature behavior changes
- [ ] No one-shot cross-boundary apply or GoF introduction — architecture path is propose → approve → one O2 slice
- [ ] Automation apply (`may_edit: true` and `write_target: fix`): structural intent only; no architecture Phase A/B during apply
- **PASS** if every edit is behavior-preserving O1/O2 structural work

## Verification

Always load [category-verification.md](category-verification.md) for apply vs watch and Phase B gates.

### VERIFY-01: Verification gates

- [ ] Establish characterization / verification gate before or with edits ([category-verification.md](category-verification.md))
- [ ] Architecture Phase A: skip apply and verification — proposal only
- [ ] Re-run applicable gates on all touched areas after Phase B completes
- [ ] If a same-package move (O2) lacks an adequate gate → downgrade that candidate to O1 or watch
- [ ] No gate available without user or context direction → watch on candidate — do not invent tests
- [ ] Lint tools may run as part of a gate; lint-only findings must not expand the target
- **PASS** if apply claims match commands actually run

## Output

### OUT-01: Single result shape

- [ ] Pick **one** result shape per run — survey-only **or** apply — per [common-output-format.md](common-output-format.md) (interactive) or [common-output-format-automation.md](common-output-format-automation.md) (automation)
- [ ] Survey: omit `### Changes`, `### Deferred`, and `## Verification`
- [ ] Apply: omit `### Candidates` and `### Watch` (fold watch into **Deferred**)
- [ ] Do not put `O1`/`O2`/`O3`, intent labels, or Fowler technique names in user-facing tables
- [ ] Before PR synthesis (apply mode): reconcile **Changes** / **Deferred** with `git diff --name-only`
- [ ] Do not claim validation passed when commands failed or were not run
- [ ] Automation: when gates named in session instructions are unavailable, record under `## Session Metrics` and watch affected candidates
- **PASS** if survey and apply shapes are not mixed

## Error handling

See SKILL.md Error Handling. Checklist gates above cover survey/apply/verify; do not duplicate severity tables here.
