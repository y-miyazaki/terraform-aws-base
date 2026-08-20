# Agent Skills Review Checklist

## Best Practice Checks (BP)

- BP-01 (SHOULD): Description states what the skill does and when to use it
- BP-02 (SHOULD): Reference Files Guide states when each reference is read
- BP-03 (SHOULD): SKILL.md avoids redundant prose already in references
- BP-04 (SHOULD): Do not over-compress below sibling skill depth
- BP-05 (SHOULD): Checklist ItemID layout is one style per file

## Pattern Checks (P)

- P-01 (SHOULD): Workflow matches the skill family pattern (not ad-hoc steps)
- P-02 (SHOULD): Output matches common-output-format contract
- P-03 (SHOULD): Gather required context before emitting the final report

## Quality Checks (Q)

- Q-01 (SHOULD): Output format is implementable (schema or Markdown sections)
- Q-02 (SHOULD): Execution Scope splits Does vs Out of Scope
- Q-03 (SHOULD): Execution path is single/canonical or branches are explicit
- Q-04 (SHOULD): Inputs/outputs name concrete shapes with examples
- Q-05 (SHOULD): Constraints list only non-obvious project rules
- Q-06 (MUST): Instructions are imperative; no "appropriately"/"as needed"
- Q-07 (SHOULD): SKILL.md depth aligns with package siblings
- Q-08 (SHOULD): References/ includes common-checklist and common-output-format
- Q-09 (SHOULD): Record waza token evidence; over-budget is advisory
- Q-10 (SHOULD): Workflow defines failure severity and actions
- Q-11 (SHOULD): Required params have no silent defaults; defaults are optional
- Q-12 (SHOULD): Input/Output/Workflow/References do not contradict each other

## Structural Checks (S)

- S-01 (MUST): SKILL.md has the five required ## sections
- S-02 (MUST): Frontmatter has name, description, license (+ version metadata)
- S-03 (MUST): References/ start with H1 and use consistent heading hierarchy
- S-04 (MUST): Links stay in-skill or https:// (no ../docs escapes)
- S-05 (MUST): Use <agent-root> for install paths; do not hardcode .github/skills
