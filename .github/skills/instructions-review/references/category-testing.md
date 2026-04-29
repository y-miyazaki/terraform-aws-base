## Testing and Validation Chapter Review Checks

This file contains review checks specific to the Testing and Validation chapter of instructions files.

## Testing and Validation Chapter (TEST)

**TEST-01: Validation Commands**

Check: Executable validation commands are documented
Why: Missing commands prevent automation and compromise quality assurance
Fix: Document executable validation commands with examples

**TEST-02: Command Count**

Check: At least 3 validation commands are documented
Why: Too few commands reduce test coverage and compromise quality assurance
Fix: Add minimum 3 validation commands

**TEST-03: Code Block**

Check: Examples are in \`\`\`bash code block format
Why: Non-code-block examples are difficult to execute and cannot be copy-pasted
Fix: Use \`\`\`bash format for execution examples

**TEST-04: Validation Items**

Check: Validation items list is comprehensive
Why: Incomplete list causes missed checks and incomplete validation
Fix: Enrich validation items and cross-reference with aqua.yaml

**TEST-05: Tool Coverage**

Check: All tools in aqua.yaml are covered in validation commands
Why: Missing tools cause gaps in validation and underutilization of available tools
Fix: Cross-reference with aqua.yaml and add all tools

**TEST-06: Real Commands**

Check: Examples are concrete and actually executable
Why: Missing examples make validation difficult and cause command errors
Fix: Provide concrete examples and verify they execute correctly
