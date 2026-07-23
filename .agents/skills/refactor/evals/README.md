# refactor skill evals

- `evals.json` — skill-creator prompts + expectations (behavioral regression).
- `tasks/refactor-noop.yaml` — waza/mock eval (empty-input no-op contract).

## Harness rules (avoid overfit)

When spawning executor agents:

- Point them at the skill path; do **not** paste `common-output-format.md` into the task prompt.
- Refusal cases (empty input, lint-primary, feature/API): ask the natural user ask only; require writing `outputs/session-report.md` as the artifact path, not a template dump.
- Fixtures for local runs live under repo-ignored `tmp/refactor-skill-eval/fixtures/` (keeps shellcheck hooks off bait files).

## Re-running skill-creator benchmarks

Iteration artifacts live under `tmp/refactor-skill-eval/`.

- iteration-1: with_skill vs without_skill — with_skill 100%
- iteration-2: with_skill (v1.0.3) vs old_skill (v1.0.0) — plain-language Tier gloss; 100% / ~95%
- iteration-3: residual risks — O2 same-package move (eval-6), de-coached refusal prompts, synced install trees
- iteration-4: v2.1.0 — SKILL token trim, plain-language tiers in body, architecture Phase A eval (eval-7)

Viewer: `tmp/refactor-skill-eval/iteration-3/review.html` (fallback: iteration-2)
