### 8. Documentation (DOC)

**DOC-01: Standard Header Format**

Check: Does file header contain Description/Usage/Design Rules?
Why: Missing header makes script purpose unclear, usage unknown, delays onboarding
Fix: Add standard header with Description/Usage/Design Rules

**DOC-02: show_usage Required**

Check: Is show_usage function implemented?
Why: Missing -h/--help option reduces usability and increases support requests
Fix: Implement show_usage function with Usage/Options/Examples, exit 0

**DOC-03: Function Separators and Comments**

Check: Do functions have `#######` separator and purpose/arguments/return comments?
Why: Unclear function boundaries reduce review efficiency and hinder maintenance
Fix: Add `#######` separator before functions, document purpose/arguments/return values

**DOC-04: Complex Logic Comments**

Check: Do complex algorithms have Why comments?
Why: Missing algorithm explanations make understanding difficult, hinder maintenance, introduce bugs
Fix: Focus on Why comments, explain complex processing, document assumptions

**DOC-05: Variable Documentation**

Check: Do global variables have purpose/unit/constraint comments?
Why: Unclear variable purpose causes misuse, bugs, difficult maintenance
Fix: Comment global variables with unit/default value/constraints

**DOC-06: English Comment Consistency**

Check: Are all comments consistently in English?
Why: Mixed languages reduce readability, lack consistency, appear unprofessional
Fix: Standardize on English comments, write concisely and clearly

**DOC-07: README.md Maintenance**

Check: Does README.md document purpose/prerequisites/setup/usage examples?
Why: Insufficient README delays onboarding, causes incorrect execution, increases questions
Fix: Document purpose/prerequisites/setup/usage examples/troubleshooting

**DOC-08: Error Message Documentation**

Check: Are error codes and resolution methods documented?
Why: Undefined error codes make troubleshooting difficult and confuse users
Fix: List error codes with causes and solutions

**DOC-09: CHANGELOG History**

Check: Is CHANGELOG.md maintained with breaking changes documented?
Why: Missing change history makes tracking difficult, impact unclear, confuses users
Fix: Create CHANGELOG.md in Keep a Changelog format, document breaking changes
