## Dependencies (DEP)

**DEP-01 (SHOULD): Document Required Commands**

Check: Are dependent commands documented in README?
Why: Unclear dependencies cause execution failures, difficult environment setup, delayed onboarding
Fix: Document dependencies in README

**DEP-02 (SHOULD): Command Existence Check**

Check: Are commands verified with command -v with clear error messages?
Why: Missing command checks cause runtime errors with unclear messages
Fix: Use command -v checks, provide clear error messages, show installation instructions
