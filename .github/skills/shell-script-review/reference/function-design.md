### 3. Function Design (FUNC)

**FUNC-01: Functions Under 50 Lines Recommended**

Check: Are functions 50 lines or less?
Why: Functions over 100 lines reduce readability, make testing difficult, hinder maintenance
Fix: Extract helper functions, apply single responsibility principle, aim for under 50 lines

**FUNC-02: Standardize parse_arguments**

Check: Is parse_arguments standardized with getopts and case statements?
Why: Duplicated and inconsistent argument parsing makes adding options difficult and introduces bugs
Fix: Use getopts, standard case statement pattern, support -h|--help

**FUNC-03: Implement show_usage**

Check: Does show_usage function include Usage/Options/Examples and exit 0?
Why: Missing help implementation reduces usability, increases support requests, causes misuse
Fix: Implement show_usage function with Usage/Options/Examples, exit 0

**FUNC-04: Return Value Design**

Check: Do functions properly set return values via return codes or echo output?
Why: Missing return values prevent error handling, conditional branching, failure detection
Fix: Set return 0/1, use echo output, leverage `|| error_exit`

**FUNC-05: Leverage Common Library**

Check: Are common functions from lib/all.sh utilized?
Why: Code duplication and inconsistent error handling increase maintenance cost, cause inconsistencies, reduce quality
Fix: Use lib/all.sh functions, follow project standards

**FUNC-06: validate_dependencies Function**

Check: Is required command existence check implemented in validate_dependencies function?
Why: Not checking required commands causes mid-script failures and user confusion
Fix: Implement validate_dependencies, use command -v checks, provide clear errors

**FUNC-07: Implement main Function**

Check: Is main function implemented with minimized global scope processing?
Why: Global scope processing makes structure unclear, debugging difficult, unit testing impossible
Fix: Implement main function, call `main "$@"`, structure code properly
