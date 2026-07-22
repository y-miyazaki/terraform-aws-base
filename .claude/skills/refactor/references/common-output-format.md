# Refactor Result Format

Use this structure for every interactive run. **Survey-only** and **apply** modes use **different** Summary shapes — do not mix them.

Internal depth tiers (`O1`/`O2`), intent labels, and Fowler technique names are for agent workflow only ([category-operations.md](category-operations.md), [category-techniques.md](category-techniques.md)). **Do not put them in user-facing output.**

Loop PR bodies: [common-output-format-loop.md](common-output-format-loop.md). Platform contract: repository `docs/explanation/loop-engineering/loop-pr-body-skill-contract.md`.

## Survey-only result (`mode: survey`, loop `L1`, architecture Phase A)

No file edits. **Do not emit `### Changes`, `### Deferred`, or a Verification table.**

```markdown
# Refactor Result

## Overview

<scope surveyed → candidate count → no edits applied; 1–2 sentences>

## Summary

### Candidates

| Target | Evidence | Suggested approach | Priority |
| ------ | -------- | ------------------ | -------- |
| `path/to/file.sh` `symbol()` | <plain-language evidence> | <plain-language fix direction> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
| `path` | <plain-language evidence> | <plain-language reason> |

### Architecture Proposal

<problem, candidate slices, phased plan, risks — architecture Phase A only; omit otherwise>
```

### Survey — section rules

| Section | Rule |
| ------- | ---- |
| Overview | State scope, candidate count, and that **no edits** were applied |
| `### Candidates` | **Required** when any apply-worthy candidate exists; one row per candidate |
| `### Watch` | Optional; out-of-scope, lint-only, cross-boundary, or weak-gate items |
| `### Changes` | **MUST NOT** appear in survey-only output |
| `### Deferred` | **MUST NOT** appear in survey-only output |
| `## Verification` | **MUST NOT** appear — no apply-phase checks ran |
| Zero candidates | Overview explains no-op; omit empty `### Candidates` |

**Candidates columns:** **Suggested approach** = plain-language fix direction (not internal technique names). **Priority** = `high` \| `medium` \| `low` for human triage.

## Apply result (`mode: apply`, loop `L2`/`L3`)

Survey runs internally first; final output uses the **apply** shape. **Do not emit `### Candidates`** in the final report — reconcile into Changes and Deferred.

```markdown
# Refactor Result

## Overview

<candidates found → how many applied → 1–2 sentences>

## Summary

### Changes

| Target | What was wrong | What changed |
| ------ | -------------- | ------------ |
| `path/to/file.sh` `symbol()` | <plain-language evidence> | <minimal behavior-preserving summary> |

### Deferred

| Target | Why deferred |
| ------ | ------------ |
| `path` | <plain-language reason> |

## Verification

| Check | Result |
| ----- | ------ |
| <command or skill name> | <pass \| fail \| skip \| blocked> |
```

### Apply — section rules

| Section | Rule |
| ------- | ---- |
| Overview | State candidates found and how many were applied (or why none) |
| `### Changes` | **Required** when `git diff` is non-empty; one row per applied fix |
| `### Deferred` | Watch rows from survey plus apply-phase failures; omit when empty |
| `### Candidates` | **MUST NOT** appear in final apply output |
| `### Watch` | **MUST NOT** appear — fold watch items into **Deferred** |
| Verification | **Required** when Phase B ran; list checks the agent already ran |

### Apply — consistency

| Rule | Requirement |
| ---- | ----------- |
| Mutual exclusion | A path MUST NOT appear in both **Changes** and **Deferred** |
| Git alignment | Every path in `git diff` MUST have a **Changes** row |
| Deferred = no edit | Revert edits to deferred paths before the final report |

Before emitting the result, run `git diff --name-only` and reconcile **Changes** and **Deferred**.

## No-op (both modes)

```markdown
# Refactor Result

## Overview

<why nothing actionable was found; 1–2 sentences>

## Summary

<no subsections, or a single sentence under Summary>

## Verification
```

- Survey no-op: omit Verification (same as survey-only).
- Apply no-op after survey: Verification may be `None` when no edits were attempted.

## Rules (both modes)

- Always emit `## Overview` and `## Summary`.
- Do not emit Outcome lines, Suggested next action, Session Metrics, or internal tier labels.
- Do not claim verification passed when commands failed or were not run.
- Pick **one** result shape per run — survey-only **or** apply — never combine both shapes in one report.
