# Technique selection

Pick **one** Fowler-style transformation **per candidate** during Phase B apply ([category-contract.md](category-contract.md) O1/O2 cap). Re-run verification gates after the full apply batch ([category-verification.md](category-verification.md)).

## Core rules

- One transformation per candidate; do not batch unrelated edits into one candidate row
- Prefer the smallest technique that addresses the evidence
- O2 (same-package move) only when extract/rename requires relocating a symbol within the same package/module
- Near-duplicate branches: unify only when a single candidate step is safe; otherwise split into separate candidate rows

Watch / out-of-scope: [category-contract.md](category-contract.md) **When not to apply**. Gate failure → revert that candidate and continue ([category-verification.md](category-verification.md)).

## Hint and smell → technique

| Evidence                                            | Primary technique                              | Fallback                                     | Skip when                                                    |
| --------------------------------------------------- | ---------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| `duplication_block` (identical logic)               | Extract Method/Function → consolidate callers  | Inline shared helper if it already exists    | Comment/doc template only; literals that differ semantically |
| `duplication_block` (near-duplicate branches)       | Extract Method after making branches identical | Parameterize differences in extracted helper | Branches differ in behavior                                  |
| `oversized_unit` (long function, multiple sections) | Extract Method per cohesive section            | Extract Variable for complex expressions     | Single cohesive algorithm; split harms readability           |
| `oversized_unit` (deep nesting >3 levels)           | Replace Nested Conditional with Guard Clauses  | Extract Method for inner block               | Guard clauses change observable error behavior               |
| `oversized_unit` (long file)                        | Extract Method to sibling in same package (O2) | Extract Variable / Rename for clarity (O1)   | Move would cross package boundary                            |
| Unclear names                                       | Rename Variable/Function                       | —                                            | Public API rename without caller update path                 |
| Complex expression                                  | Extract Variable                               | Inline Variable if name adds no value        | —                                                            |
| User: dedupe / clarify / extract                    | Match rows above                               | —                                            | Lint-only or feature/API mission                             |

## Safe O1 catalog (closed apply set)

| Technique                                     | Use when                                        |
| --------------------------------------------- | ----------------------------------------------- |
| Extract Method/Function                       | Reusable block, section comments, loop body     |
| Inline Method/Function                        | Body is as clear as name; prelude to re-extract |
| Extract Variable                              | Long or repeated expression                     |
| Inline Variable                               | Name adds no meaning                            |
| Rename                                        | Name mismatches purpose                         |
| Replace Nested Conditional with Guard Clauses | Else ladder obscures main path                  |
| Split Loop                                    | Loop performs unrelated accumulations           |
| Remove Dead Code                              | Unreachable branch proven dead                  |

**Out of scope for apply:** Introduce Polymorphism, Extract Interface, GoF patterns, cross-package redesign — route to architecture Phase A ([category-contract.md](category-contract.md) O3).

## O2 extensions

| Technique                           | Use when                                                |
| ----------------------------------- | ------------------------------------------------------- |
| Move Method/Function (same package) | Extracted helper belongs in sibling file in same module |
| Move Module within package          | Wiring cleanup after Move Method                        |

Downgrade to O1 if the gate is insufficient — see [category-verification.md](category-verification.md).
