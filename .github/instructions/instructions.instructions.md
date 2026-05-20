---
applyTo: "**/instructions/*.instructions.md"
description: "AI Assistant Instructions for Writing Instruction Files"
---

# AI Assistant Instructions for Instruction Files

## Scope

- Scope is limited to creating and updating `**/instructions/*.instructions.md` files.

## Standards

### Naming Conventions

| Component | Rule                                     | Example                              |
| --------- | ---------------------------------------- | ------------------------------------ |
| File      | `<target>.instructions.md`               | `go.instructions.md`                 |
| Title     | `# AI Assistant Instructions for <target>` | `# AI Assistant Instructions for Go` |

### Standards Content

- **STD-01 (MUST)**: A Naming Conventions table exists - without it, component naming becomes inconsistent.
- **STD-02 (SHOULD)**: Tool-specific standards are documented when applicable.
- **STD-03 (MUST)**: The documentation level matches other instruction files - inconsistent granularity makes cross-file comparison difficult.

### Structure

- **G-01 (MUST)**: Include `applyTo` and `description` in Front Matter - missing fields prevent automatic application.
- **G-02 (MUST)**: Use English consistently in body text, code examples, table headers, Front Matter, and Rule IDs - mixed language rules reduce consistency.
- **G-03 (MUST)**: Use H1 title format `# AI Assistant Instructions for <target>` - this preserves discoverability and consistency.
- **STRUCT-01 (MUST)**: Keep the five-chapter structure (Scope -> Standards -> Guidelines -> Testing and Validation -> Security Guidelines) - missing chapters create information gaps.
- **STRUCT-02 (MUST)**: Keep chapter order strict - inconsistent ordering makes file-to-file comparison harder.
- **STRUCT-03 (MUST)**: Use H2 for chapters and H3 for subsections; minimize H4 and deeper levels - deep hierarchies degrade AI structural recognition.
- **STRUCT-04 (MUST)**: Start the Standards chapter with `### Naming Conventions` - this is the unified starting point across files.
- **STRUCT-05 (MUST)**: Order Guidelines as domain rules -> Anti-Patterns -> Code Modification Guidelines - this keeps priority order clear.
- **STRUCT-06 (MUST)**: Use H3 heading format `### Name (LEVEL)` for rule sections or `### Name` for declaration/process sections - do not include ID ranges in headings.
- **STRUCT-07 (MUST)**: Keep only operational procedures in `## Testing and Validation` and `## Security Guidelines`; keep review criteria (`TEST-*`, `SEC-*`) only in Guidelines - duplicate definitions hurt maintainability and consistency.

## Guidelines

### General (G)
- G-01 (MUST): Front Matter
  - Check: Front Matter contains applyTo and description fields
- G-02 (MUST): Language Policy
  - Check: Language policy is documented
- G-03 (MUST): Title
  - Check: Title clearly indicates purpose

### Structure (STRUCT)
- STRUCT-01 (MUST): Four Required Chapters Exist
  - Check: Standards, Guidelines, Testing and Validation, and Security Guidelines chapters exist
- STRUCT-02 (MUST): Chapter Order Unified
  - Check: Chapters follow Standards → Guidelines → Testing → Security order
- STRUCT-03 (MUST): Heading Levels Appropriate
  - Check: Heading hierarchy properly uses H2 (chapters) → H3 (subsections)
- STRUCT-04 (MUST): Standards Chapter Subsections
  - Check: Does the Standards chapter have Naming Conventions subsection first, followed by tool-specific standards?
- STRUCT-05 (MUST): Guidelines Chapter Subsections
  - Check: Does the Guidelines chapter have domain rules first, followed by Anti-Patterns, then Code Modification Guidelines?
- STRUCT-06 (MUST): H3 Heading Format
  - Check: Do H3 headings use `### Name（LEVEL）` format for rule sections, and `### Name` for process/declaration sections?

### Guidelines Chapter (GUIDE)
- GUIDE-01 (SHOULD): Documentation and Comments
  - Check: Comment and documentation conventions are documented
- GUIDE-02 (SHOULD): Code Modification Guidelines
  - Check: Modification procedures and validation methods are clearly documented
- GUIDE-03 (SHOULD): Tool Usage
  - Check: MCP Tool usage examples are documented
- GUIDE-04 (SHOULD): Error Handling
  - Check: Error handling policy is documented
- GUIDE-05 (SHOULD): Performance Considerations
  - Check: Performance guidelines are documented where applicable
- GUIDE-06 (SHOULD): Best Practices
  - Check: Best practices specific to the technology are documented
- GUIDE-07 (SHOULD): Common Patterns
  - Check: Common code patterns and idioms are documented
- GUIDE-08 (SHOULD): Anti-Patterns
  - Check: Common anti-patterns and pitfalls are documented
- GUIDE-09 (SHOULD): No ID-less Bullet Rules in Guidelines
  - Check: Are there no ID-less bullet rules in the Guidelines chapter?

### Content Quality (QUAL)
- QUAL-01 (SHOULD): Conciseness
  - Check: Content is concise without redundant expressions
- QUAL-02 (SHOULD): Practical Examples
  - Check: Practical code examples are included
- QUAL-03 (SHOULD): No Redundancy
  - Check: No duplicate content
- QUAL-04 (SHOULD): Token Efficiency
  - Check: Large code examples are avoided for high token efficiency

### Consistency (CONS)
- CONS-01 (SHOULD): Chapter Order
  - Check: Chapter order is consistent across all instructions files
- CONS-02 (SHOULD): Section Names
  - Check: Section names are consistent with other instructions files
- CONS-03 (SHOULD): Detail Level
  - Check: Documentation detail level matches other instructions files
- CONS-04 (SHOULD): Format
  - Check: Table and list formats are consistent with other instructions files

### Completeness (COMP)
- COMP-01 (SHOULD): All Required Sections
  - Check: All required sections exist
- COMP-02 (SHOULD): No Missing Commands
  - Check: Executable validation commands are comprehensive
- COMP-03 (SHOULD): Tool Coverage
  - Check: All tools in aqua.yaml are documented
- COMP-04 (SHOULD): Real Commands
  - Check: Examples are concrete and comprehensive

### Security Guidelines Chapter (SEC)
- SEC-01 (MUST): Security Items
  - Check: Security items are documented
- SEC-02 (MUST): Secrets Management
  - Check: Secrets management policy is documented
- SEC-03 (MUST): Best Practices
  - Check: Concrete security best practices are documented
- SEC-04 (SHOULD): Examples
  - Check: YAML/code examples are included (where applicable)

### Standards Chapter (STD)
- STD-01 (MUST): Naming Conventions
  - Check: Naming conventions are documented per component
- STD-02 (SHOULD): Tool Standards
  - Check: Tool conventions are documented
- STD-03 (MUST): Consistency
  - Check: Documentation level matches other instructions files

### Testing and Validation Chapter (TEST)
- TEST-01 (MUST): Validation Commands
  - Check: Executable validation commands are documented
- TEST-02 (MUST): Command Count
  - Check: At least 3 validation commands are documented
- TEST-03 (MUST): Code Block
  - Check: Examples are in \`\`\`bash code block format
- TEST-04 (SHOULD): Validation Items
  - Check: Validation items list is comprehensive
- TEST-05 (SHOULD): Tool Coverage
  - Check: All tools in aqua.yaml are covered in validation commands
- TEST-06 (SHOULD): Real Commands
  - Check: Examples are concrete and actually executable

### Code Modification Guidelines

- After changes, prioritize running validate.sh from [instructions-review Skill](../../apm_modules/y-miyazaki/config/.apm/packages/common/.apm/skills/instructions-review/SKILL.md).
- When instruction files are updated, always run an instruction quality re-evaluation.
- Use individual commands only for debugging.


## Testing and Validation

- This chapter should contain only execution procedures (entry point, individual runs, reference links), while review criteria (TEST-*) are consolidated in Guidelines.

**Entry point (recommended)**:

```bash
bash <agent-root>/skills/instructions-review/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
markdownlint .apm/instructions/
textlint .apm/instructions/
```

**Detailed guide**: See [instructions-review Skill](../../apm_modules/y-miyazaki/config/.apm/packages/common/.apm/skills/instructions-review/SKILL.md).

## Security Guidelines

- This chapter should contain only operational security practices, while security review criteria (SEC-*) are consolidated in Guidelines.
- Do not include real secrets (tokens, keys, credentials) in instruction files.
- Do not make destructive operations the default in command examples; add explicit warnings when needed.
