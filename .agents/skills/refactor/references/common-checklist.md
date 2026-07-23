# Refactor Checklist

## Intent classification

- Classify **structural** (default) or **architecture-improvement** before edits ([category-operations.md](category-operations.md))
- Architecture triggers: architecture improvement, redesign, module boundary, deep module, responsibility split, testability at seams
- When ambiguous → **structural**
- Architecture intent without user-approved slice → Phase A proposal only; Outcome `proposal`; no apply
- Architecture Phase B → user names **one** approved slice; apply as O2 cap only
- Do not require users to pass `max_tier: O3` or bare O3 labels

## Survey (Phase A)

- Run **before** any file edit in `apply` mode; sole phase in `survey` mode
- Discover **all** candidates in scope — loop: every `hints[]` entry; interactive: user paths or in-scope exploration
- Prefer structure-driven evidence (duplication, oversized unit, user-named symbol) — not lint/SAST smell scores
- Emit `### Candidates` with one row per candidate (see [common-output-format.md](common-output-format.md))
- Mark each row **apply** or **watch**; lint/style-only, feature/API, comment-only, or cross-boundary → **watch**
- Zero candidates → Outcome `no-op`; stop
- Do not require or read `docs/report/tech-debt/**`

## Apply (Phase B)

- Run only when `may_edit` is `true` (interactive default; automation per `## Constraints`)
- Apply **every** candidate marked **apply** in survey order
- Pick **one** technique per candidate from [category-techniques.md](category-techniques.md)
- Treat `duplication_block` as **logic duplication** — dedupe executable/shared logic, not documentation or comment-only templates
- When deduplicating logic, preserve file headers and symbol documentation unless consolidating documented behavior in the same edit
- Stay in closed depth tiers O1/O2 ([category-operations.md](category-operations.md)): **O1** = local structure same behavior; **O2** = plus shallow same-package move
- No public API semantics changes; no feature behavior changes
- No one-shot cross-boundary apply or GoF introduction — architecture path is propose → approve → one O2 slice
- Automation apply (`may_edit: true`): structural intent only; no architecture Phase A/B during apply
- Failed gate for one candidate → revert that edit; record under **Deferred**; continue remaining candidates

## Verification

- Establish characterization / stack gate before or with edits ([category-verification.md](category-verification.md))
- Architecture Phase A: skip apply and stack validation — proposal only
- Re-run stack gates on all touched packages after Phase B completes
- If a same-package move (O2) lacks an adequate gate → downgrade that candidate to O1 or watch
- Unsupported language → watch on candidate — do not invent tests for an unknown stack
- Lint tools may run as part of a stack gate; lint-only findings must not expand the target

## Output

- Pick **one** result shape per run — survey-only **or** apply — per [common-output-format.md](common-output-format.md) (interactive) or [common-output-format-loop.md](common-output-format-loop.md) (automation)
- **Survey** (`may_edit: false`): `### Candidates` (+ optional `### Watch`); **MUST NOT** emit `### Changes`, `### Deferred`, or `## Verification`
- **Apply** (`may_edit: true`): `### Changes` (+ optional `### Deferred`) and `## Verification`; **MUST NOT** emit `### Candidates` or `### Watch` in final output
- Classify intent and depth tier internally before edits; **do not** put `O1`/`O2`/`O3`, intent labels, or Fowler technique names in user-facing tables
- Before PR synthesis (apply mode): reconcile **Changes** / **Deferred** with `git diff --name-only`
- Architecture Phase A: use survey shape + **Architecture Proposal**; no file edits
- Do not claim validation passed when commands failed or were not run

## Error handling

- Nothing actionable after survey → Outcome `no-op`, empty Changes, stop
- Validation fails for one candidate → revert that candidate; Deferred; continue batch
- Missing validation tooling named in Instructions → note in Session Metrics; watch affected candidates
