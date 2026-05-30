## Documentation (DOC)

**DOC-01 (SHOULD): Package Documentation Exists**

Check: Are package doc comments, package purpose, and usage documented?
Why: Missing package doc comments make API understanding difficult, increase misuse, delay onboarding
Fix: Add package doc comments, document purpose, responsibility, usage examples

**DOC-02 (MUST): godoc for Public Functions**

Check: Are all public APIs documented with godoc, arguments, return values, and error conditions specified?
Why: Missing or insufficient public function comments make API usage unclear, cause misuse
Fix: Document all public APIs with godoc, specify arguments, return values, error conditions

**DOC-03 (SHOULD): Complex Logic Comments**

Check: Are Why-focused comments, algorithm explanations, and preconditions documented?
Why: Missing algorithm explanations and unclear preconditions make understanding difficult, introduce bugs
Fix: Why-focused comments, algorithm explanations, document preconditions

**DOC-04 (SHOULD): Struct Field Comments**

Check: Are each field commented with constraints, default values, and required status?
Why: Unclear field purpose and constraints cause misuse, validation omissions
Fix: Comment each field, specify constraints, default values, required status

**DOC-05 (SHOULD): Constant and Variable Descriptions**

Check: Are constants/variables commented with units, constraints, and reasons?
Why: Magic numbers and unclear constant purposes make intent unclear, change impact unknown
Fix: Comment constants/variables, document units, constraints, reasons

**DOC-06 (SHOULD): English Comment Consistency**

Check: Are comments unified in English, grammar-checked, and concise?
Why: Mixed languages and grammar errors reduce readability, make internationalization difficult
Fix: Unify in English, check grammar, write concisely and clearly

**DOC-07 (SHOULD): README.md Maintenance**

Check: Are purpose, prerequisites, setup, usage examples, and contribution methods documented?
Why: Insufficient README and unclear setup procedures delay onboarding, cause incorrect usage
Fix: Document purpose, prerequisites, setup, usage examples, contribution methods

**DOC-08 (SHOULD): API Specification (OpenAPI)**

Check: Are OpenAPI 3.0 descriptions, swag usage, and auto-generation verification present?
Why: Missing API specs and unclear endpoints make frontend development difficult, cause API misuse
Fix: Describe with OpenAPI 3.0, use swag, auto-generate and verify

**DOC-09 (SHOULD): Operations Documentation**

Check: Are deployment procedures, monitoring items, incident response procedures, and log analysis methods documented?
Why: Unclear operations procedures and missing troubleshooting info make operations difficult, delay incident response
Fix: Maintain operations documentation, document deployment, monitoring, incident response, log analysis

**DOC-10 (SHOULD): CHANGELOG**

Check: Are Keep a Changelog format, semantic versioning, and breaking changes documented?
Why: Missing change history and unclear breaking changes make impact scope unknown, upgrades difficult
Fix: Keep a Changelog format, semantic versioning, document breaking changes
