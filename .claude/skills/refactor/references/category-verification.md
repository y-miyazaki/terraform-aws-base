# Verification

## Gate procedure

1. **Before apply:** read the target area; note existing tests and validation the repository already uses
2. **Run gates** from the highest-priority source available — user instructions, session `## Instructions`, repository agent rules, or obvious project entrypoints (for example `Makefile`, package scripts, CI workflow definitions)
3. **Characterization:** capture **existing** behavior only — do not expand into feature specs
4. **Red-green:** when tests or checks exist (or context requires them), establish green on current behavior before the structural edit; re-run gates after the edit
5. **Architecture Phase A:** skip apply and verification — proposal only

## Downgrade

- If the gate is insufficient for a same-package move (O2) → apply **local-only (O1)** or watch
- Record the choice under Verification **Downgrade** using plain labels (`same-package move → local structure` or watch reason)
- Lint/SAST findings must **not** become the primary reason to select or expand a target

## After Phase B

- Re-run applicable gates on all touched areas before synthesis
- Report commands actually run and their outcomes — do not claim validation passed when commands failed or were not run

## When no gate is available

- Mark the candidate **watch** or defer — do not invent tests for an unfamiliar stack without user or context direction
