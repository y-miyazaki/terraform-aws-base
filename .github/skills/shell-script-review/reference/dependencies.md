### 9. Dependencies (DEP)

**DEP-01: Leverage lib/all.sh**

Check: Is lib/all.sh sourced and common functions utilized?
Why: Not using common library causes code duplication, increased maintenance cost, quality inconsistency
Fix: Source lib/all.sh, use common functions like error_exit/log_message

**DEP-02: Use validate_dependencies**

Check: Is validate_dependencies function called?
Why: Not checking required commands causes mid-script failures and user confusion
Fix: Call validate_dependencies, explicitly list required commands

**DEP-03: Document Required Commands**

Check: Are dependent commands documented in README?
Why: Unclear dependencies cause execution failures, difficult environment setup, delayed onboarding
Fix: Document dependencies in README, implement validate_dependencies

**DEP-04: Command Existence Check**

Check: Are commands verified with command -v with clear error messages?
Why: Missing command checks cause runtime errors with unclear messages
Fix: Use command -v checks, provide clear error messages, show installation instructions
