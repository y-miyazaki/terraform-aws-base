## Standards Chapter Review Checks

This file contains review checks specific to the Standards chapter of instructions files.

## Standards Chapter (STD)

**STD-01 (MUST): Standards Chapter Non-Obvious Content**

Check: Does Standards omit language/ecosystem defaults and general practices models already know? Are only non-obvious, project- or distribution-specific rules present? Omit `### Naming Conventions` when it would only restate defaults.
Why: Restating ubiquitous conventions (snake_case, kebab-case, generic style guides) wastes tokens and dilutes project-specific rules
Fix: Keep Standards minimal; document only distribution layout, repo-specific contracts, and naming paths agents cannot infer

**STD-02 (SHOULD): Tool Standards**

Check: Are non-obvious tool conventions documented when this project or distribution layout requires them?
Why: Missing project-specific tool standards prevent automation; restating formatter/linter defaults models already know wastes tokens
Fix: Document tool conventions only when non-default for this repo or package layout

**STD-03 (MUST): Consistency**

Check: Documentation level matches other instructions files
Why: Cross-file inconsistency increases learning cost and hampers standardization
Fix: Unify documentation level, verify against reference files

**STD-04 (MUST): Distribution Naming Documented**

Check: When instructions are distributed to agent rule paths, does Naming Conventions document source stem → Cursor `.mdc` / Claude `.md` / Kiro steering mapping?
Why: Agents cannot resolve companion rules if only the package source filename is documented
Fix: Add rows for package source, Cursor, Claude, and Kiro paths using the shared stem — required in the meta instructions authoring file; domain instruction files need not repeat the mapping

**STD-05 (MUST): No Guidelines Checklist Duplication in Standards**

Check: Does Standards avoid repeating rule IDs and normative bullets that already appear in Guidelines (synced checklist ItemID titles)? Standards should hold only tables, distribution maps, and authoring detail not captured by those ItemIDs. Full Check/Why/Fix remain in `*-review` `category-*.md`, not in always-on Guidelines.
Why: Duplicate rule IDs in Standards and Guidelines waste tokens, drift on sync, and contradict STRUCT-07
Fix: Move review criteria to Guidelines only; keep Standards minimal (naming tables, path maps, extra authoring detail)
