## Principles

Behavior-preserving structural refactor contract. Consumer context (`AGENTS.md`, steering rules, user prompt) takes precedence when it sets repository norms.

### Preserve behavior

- Do not change observable behavior, public API semantics, or feature outputs
- Feature changes, dependency upgrades, and CVE-driven edits are out of scope

### Enhance clarity

- Reduce unnecessary complexity and nesting when behavior is unchanged
- Prefer explicit code over overly compact solutions; clarity over brevity

### Minimal change

- One transformation per candidate; smallest edit that addresses the evidence
- Do not expand into repo-wide cleanup beyond resolved scope

### Maintain balance

- Do not over-simplify: avoid clever solutions, combining too many concerns, or removing helpful abstractions
- Do not prioritize fewer lines over readability or debuggability

### When not to apply (watch)

- Lint/style-only or formatting-only overlap
- Feature/API or behavior-changing mission
- Comment-only template duplication
- Cannot verify equivalence with available gates
- Cross-boundary or architecture boundary change without an approved slice

Technique selection for structural apply: [category-techniques.md](category-techniques.md).

## Depth tiers (O1 / O2 / O3)

Short labels for how deep a change may go — only this skill's depth tiers. Classify **intent** from natural language; users do not select tiers by name.

| Label  | Plain meaning                          | Typical edits                                                                                         |
| ------ | -------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| **O1** | Local structure, same behavior         | Deduplicate; clarify expression; extract/inline in place; remove dead code when equivalence is proven |
| **O2** | O1 + shallow same-package move         | Move within one package/module; fix imports/wiring for that move                                      |
| **O3** | Architecture improvement (interactive) | Phase A proposal; Phase B one approved O2 slice — not one-shot cross-boundary apply                   |

Closed set for apply: O1/O2 only. O3 is proposal-first, then O2 slices after user approval.

## Execution phases and modes

| Phase | Name   | When                                     | Edits |
| ----- | ------ | ---------------------------------------- | ----- |
| A     | Survey | Every run                                | No    |
| B     | Apply  | `may_edit: true` and `write_target: fix` | Yes   |

| Mode     | Phase A | Phase B                           | Maps to           |
| -------- | ------- | --------------------------------- | ----------------- |
| `survey` | Yes     | No                                | `may_edit: false` |
| `apply`  | Yes     | Yes only when `write_target: fix` | `may_edit: true`  |

Survey discovers candidates in scope (architecture Phase B: `approved_slice` only). Apply fixes **every** candidate marked apply in survey order when `may_edit` is `true` and `write_target` is `fix`. Do not stop after the first candidate. How `may_edit` / `write_target` are resolved: SKILL.md Workflow.

## Intent classification (before edits)

| Intent           | When to use                                                                                        | Path                                                                                                      |
| ---------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **structural**   | Dedupe, extract, clarify, shallow move; default when ambiguous                                     | Survey → when `may_edit` + `write_target: fix`, apply all O1/O2 candidates marked apply; else survey only |
| **architecture** | User mission is module boundary, deep module, redesign, responsibility split, testability at seams | Phase A proposal → approval → Phase B one O2 slice (`may_edit` + `write_target: fix` + `approved_slice`)  |

### Architecture-improvement triggers (examples)

- architecture improvement, redesign, module boundary, deep module, consolidate modules, improve testability at seams, responsibility split

When triggers are mixed with structural work, prefer **structural** unless architecture language is the primary mission.

### O1 — local structure (same behavior)

Allowed: everything in the O1 typical-edits row above, within existing boundaries.

Forbidden: anything that violates **Preserve behavior** (feature, public API semantics, dependency/CVE mission).

### O2 — same-package move (plus O1)

Allowed: O1 plus shallow move within the **same** package/module and import/wiring cleanup for that move.

Forbidden for apply (always — not automation-only): cross-package redesign, GoF / deep-module redesign, large boundary splits. Those require the architecture path (O3).

### O3 — architecture improvement (interactive only)

**Phase A (default for architecture intent):**

- Explore the target area; emit a deepening proposal in the session report
- Include: problem, candidate slices, phased plan, risks, suggested verification
- Outcome `proposal` — no cross-boundary apply; no multi-file redesign in one run

**Phase B (after explicit user approval of one slice):**

- User names **one** approved slice from the proposal
- Run survey + apply for that slice only — **O2 cap** — only when `may_edit` is `true` and `write_target` is `fix`
- Same verification gates as structural intent

**Never on automation path:** detect hints stay structural (O1/O2) only.
