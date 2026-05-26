## Testing and Validation Chapter Review Checks

This file contains review checks specific to the Testing and Validation chapter of instructions files.

## Testing and Validation Chapter (TEST)

**TEST-01 (MUST): Validation Commands**

Check: Executable validation commands are documented
Why: Missing commands prevent automation and compromise quality assurance
Fix: Document executable validation commands with examples

**TEST-02 (MUST): Command Count**

Check: At least 3 validation commands are documented
Why: Too few commands reduce test coverage and compromise quality assurance
Fix: Add minimum 3 validation commands

**TEST-03 (MUST): Code Block**

Check: Examples are in \`\`\`bash code block format
Why: Non-code-block examples are difficult to execute and cannot be copy-pasted
Fix: Use \`\`\`bash format for execution examples

**TEST-04 (SHOULD): Validation Items**

Check: Validation items list is comprehensive
Why: Incomplete list causes missed checks and incomplete validation
Fix: Enrich validation items

**TEST-05 (SHOULD): Real Commands**

Check: Examples are concrete and actually executable
Why: Missing examples make validation difficult and cause command errors
Fix: Provide concrete examples and verify they execute correctly
