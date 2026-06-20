---
paths:
  - "**/instructions/*.instructions.md,**/.cursor/rules/*.mdc,**/.kiro/steering/*.md,**/.claude/**/*.md"
---

# AI Assistant Instructions for Instruction Files

## Scope

- Scope is limited to creating and updating instruction/rule files (`**/instructions/*.instructions.md`, `.cursor/rules/*.mdc`, `.kiro/steering/*.md`, `.claude/**/*.md`).

## Standards

### Naming Conventions

| Component | Rule                                       | Example                              |
| --------- | ------------------------------------------ | ------------------------------------ |
| File      | `<target>.instructions.md`                 | `go.instructions.md`                 |
| Title     | `# AI Assistant Instructions for <target>` | `# AI Assistant Instructions for Go` |

### Standards Content

- **STD-01 (MUST)**: A Naming Conventions table exists - without it, component naming becomes inconsistent.
- **STD-02 (SHOULD)**: Tool-specific standards are documented when applicable.
- **STD-03 (MUST)**: The documentation level matches other instruction files - inconsistent granularity makes cross-file comparison difficult.

### Structure

- **G-01 (MUST)**: Include `applyTo` and `description` in Front Matter - missing fields prevent automatic application.
- **G-02 (MUST)**: Use H1 title format `# AI Assistant Instructions for <target>` - this preserves discoverability and consistency.
- **STRUCT-01 (MUST)**: Keep the five-chapter structure (Scope -> Standards -> Guidelines -> Testing and Validation -> Security Guidelines) - missing chapters create information gaps.
- **STRUCT-02 (MUST)**: Keep chapter order strict - inconsistent ordering makes file-to-file comparison harder.
- **STRUCT-03 (MUST)**: Use H2 for chapters and H3 for subsections; minimize H4 and deeper levels - deep hierarchies degrade AI structural recognition.
- **STRUCT-04 (MUST)**: Start the Standards chapter with `### Naming Conventions` - this is the unified starting point across files.
- **STRUCT-05 (MUST)**: Order Guidelines as domain rules -> Anti-Patterns -> Code Modification Guidelines - this keeps priority order clear.
- **STRUCT-06 (MUST)**: In the Guidelines chapter, use H3 heading format `### Name (LEVEL)` for rule sections or `### Name` for declaration/process sections - do not include ID ranges in headings.
- **STRUCT-07 (MUST)**: Keep `## Testing and Validation` and `## Security Guidelines` concise with operational procedures and essential guardrails only; keep detailed review criteria (`TEST-*`, `SEC-*`) in Guidelines - duplicate definitions hurt maintainability and consistency.

## Guidelines

### General (G)

- G-01 (MUST): Front Matter
  - Check: Front Matter contains applyTo and description fields
- G-02 (MUST): Title
  - Check: Title clearly indicates purpose

### Structure (STRUCT)

- STRUCT-01 (MUST): Five Required Chapters Exist
  - Check: Scope, Standards, Guidelines, Testing and Validation, and Security Guidelines chapters exist
- STRUCT-02 (MUST): Chapter Order Unified
  - Check: Chapters follow Scope → Standards → Guidelines → Testing and Validation → Security Guidelines order
- STRUCT-03 (MUST): Heading Levels Appropriate
  - Check: Heading hierarchy properly uses H2 (chapters) → H3 (subsections)
- STRUCT-04 (MUST): Standards Chapter Subsections
  - Check: Does the Standards chapter have Naming Conventions subsection first, followed by tool-specific standards?
- STRUCT-05 (MUST): Guidelines Chapter Subsections
  - Check: Does the Guidelines chapter have domain rules first, followed by Anti-Patterns, then Code Modification Guidelines?
- STRUCT-06 (MUST): H3 Heading Format in Guidelines
  - Check: In the Guidelines chapter, do H3 headings use `### Name (LEVEL)` format for rule sections, and `### Name` for process/declaration sections?

### Guidelines Chapter (GUIDE)

- GUIDE-01 (SHOULD): Code Modification Guidelines
  - Check: Modification procedures and validation methods are clearly documented
- GUIDE-02 (SHOULD): Tool Usage
  - Check: MCP Tool usage examples are documented
- GUIDE-03 (SHOULD): Anti-Patterns
  - Check: Common anti-patterns and pitfalls are documented
- GUIDE-04 (SHOULD): No ID-less Bullet Rules in Guidelines
  - Check: Are there no ID-less bullet rules in the Guidelines chapter?

### Content Quality (QUAL)

- QUAL-01 (SHOULD): Practical Examples
  - Check: Practical code examples are included
- QUAL-02 (SHOULD): No Redundancy
  - Check: No duplicate content
- QUAL-03 (SHOULD): Token Efficiency
  - Check: Large code examples are avoided for high token efficiency

### Consistency (CONS)

- CONS-01 (SHOULD): Section Names
  - Check: Section names are consistent with other instructions files
- CONS-02 (SHOULD): Format
  - Check: Table and list formats are consistent with other instructions files

### Completeness (COMP)

- COMP-01 (SHOULD): No Missing Commands
  - Check: Executable validation commands are comprehensive
- COMP-02 (SHOULD): Real Commands
  - Check: Examples are concrete and comprehensive

### Security Guidelines Chapter (SEC)

- SEC-01 (MUST): Tool-Undetectable Risks Documented
  - Check: Are security practices that automated tools (gitleaks, detect-secrets) cannot detect documented (e.g., destructive command defaults, untrusted link sources)?
- SEC-02 (MUST): Secrets Management
  - Check: Is a policy against embedding secrets in instruction files documented?
- SEC-03 (MUST): Scope Limited to Document Safety
  - Check: Are security items limited to documentation-specific risks rather than duplicating what CI/pre-commit tools enforce?
- SEC-04 (SHOULD): Examples
  - Check: YAML/code examples are included (where applicable)

### Standards Chapter (STD)

- STD-01 (MUST): Naming Conventions
  - Check: Naming conventions are documented per component
- STD-02 (SHOULD): Tool Standards
  - Check: Tool conventions are documented

### Testing and Validation Chapter (TEST)

- TEST-01 (MUST): Validation Commands
  - Check: Executable validation commands are documented
- TEST-02 (MUST): Code Block Format
  - Check: Examples are in \`\`\`bash code block format
- TEST-03 (SHOULD): Validation Items
  - Check: Validation items list is comprehensive
- TEST-04 (SHOULD): Real Commands
  - Check: Examples are concrete and actually executable

### Code Modification Guidelines

- After changes, prioritize running validate.sh from instructions-review skill.
- When instruction files are updated, always run an instruction quality re-evaluation.
- Use individual commands only for debugging.

## Testing and Validation

**Entry point (recommended)**:

```bash
bash <agent-root>/skills/instructions-review/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
markdownlint-cli2 ".apm/instructions/**"
textlint .apm/instructions/
```

**Detailed guide**: See instructions-review skill SKILL.md.

## Security Guidelines

- Do not include real secrets (tokens, keys, credentials) in instruction files.
- Do not make destructive operations the default in command examples; add explicit warnings when needed.
