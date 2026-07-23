## Technique selection

Pick **one** Fowler-style transformation **per candidate** during Phase B apply ([category-operations.md](category-operations.md) O1/O2 cap). Re-run stack gates after the full apply batch ([category-verification.md](category-verification.md)).

### Core rules

- One transformation per candidate; do not batch unrelated edits into one candidate row
- If verification fails for one candidate, revert or shrink that step — continue other candidates
- Prefer the smallest technique that addresses the evidence (80/20)
- O2 (same-package move) only when extract/rename requires relocating a symbol within the same package/module
- If branches are near-duplicates but not identical, prefer **Duplicate Before Unifying** only when a single candidate step is safe; split near-duplicates into separate candidate rows when needed

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

| Technique                                     | Use when                                        | Verify via                                     |
| --------------------------------------------- | ----------------------------------------------- | ---------------------------------------------- |
| Extract Method/Function                       | Reusable block, section comments, loop body     | Compiler + tests; extracted code is copy-paste |
| Inline Method/Function                        | Body is as clear as name; prelude to re-extract | Compiler + tests                               |
| Extract Variable                              | Long or repeated expression                     | Visual equivalence + tests when present        |
| Inline Variable                               | Name adds no meaning                            | Visual equivalence                             |
| Rename                                        | Name mismatches purpose                         | Compiler/linter references                     |
| Replace Nested Conditional with Guard Clauses | Else ladder obscures main path                  | Tests; same outcomes                           |
| Split Loop                                    | Loop performs unrelated accumulations           | Tests; same iteration semantics                |
| Remove Dead Code                              | Unreachable branch proven dead                  | Tests + compiler                               |

**Out of scope for apply:** Introduce Polymorphism, Extract Interface, GoF patterns, cross-package redesign — route to architecture Phase A ([category-operations.md](category-operations.md) O3).

## O2 extensions

| Technique                           | Use when                                                | Gate required                                                                          |
| ----------------------------------- | ------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Move Method/Function (same package) | Extracted helper belongs in sibling file in same module | Stack gate for touched packages ([category-verification.md](category-verification.md)) |
| Move Module within package          | Wiring cleanup after Move Method                        | Same as above                                                                          |

Downgrade to O1 if the gate is insufficient (V4).

## When not to refactor

- Comment-only or formatting-only overlap
- Rarely changed code with no structural evidence
- Mission is lint/style-only or feature/API change
- Cannot verify equivalence with the available stack gate
- Architecture boundary change — Phase A proposal only, not technique apply
