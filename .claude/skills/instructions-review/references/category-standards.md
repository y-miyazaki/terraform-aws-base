## Standards Chapter Review Checks

This file contains review checks specific to the Standards chapter of instructions files.

## Standards Chapter (STD)

**STD-01 (MUST): Naming Conventions**

Check: Naming conventions are documented per component
Why: Missing conventions cause code inconsistency and unclear review criteria
Fix: Add per-component naming table (functions, variables, files, etc.)

**STD-02 (SHOULD): Tool Standards**

Check: Tool conventions are documented
Why: Missing tool standards prevent automation and cause implementation inconsistencies
Fix: Add standard conventions for relevant tools (formatters, linters, etc.)

**STD-03 (MUST): Consistency**

Check: Documentation level matches other instructions files
Why: Cross-file inconsistency increases learning cost and hampers standardization
Fix: Unify documentation level, verify against reference files

**STD-04 (MUST): Distribution Naming Documented**

Check: When instructions are APM-distributed, does Naming Conventions document source stem → Cursor `.mdc` / Claude `.md` / Kiro steering mapping?
Why: Agents cannot resolve companion rules if only the package source filename is documented
Fix: Add rows for package source, Cursor, Claude, and Kiro paths using the shared stem
