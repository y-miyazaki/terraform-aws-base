## Function Design (FUNC)

**FUNC-01 (SHOULD): Functions Under 50 Lines Recommended**

Check: Are functions 50 lines or less?
Why: Functions over 100 lines reduce readability, make testing difficult, hinder maintenance
Fix: Extract helper functions, apply single responsibility principle, aim for under 50 lines

**FUNC-02 (SHOULD): Standardize parse_arguments**

Check: Is parse_arguments standardized with getopts and case statements?
Why: Duplicated and inconsistent argument parsing makes adding options difficult and introduces bugs
Fix: Use getopts, standard case statement pattern, support -h|--help

**FUNC-03 (SHOULD): Implement show_usage**

Check: Does show_usage function include Usage/Options/Examples and exit 0?
Why: Missing help implementation reduces usability, increases support requests, causes misuse
Fix: Implement show_usage function with Usage/Options/Examples, exit 0

**FUNC-04 (SHOULD): Return Value Design**

Check: Do functions properly set return values via return codes or echo output?
Why: Missing return values prevent error handling, conditional branching, failure detection
Fix: Set return 0/1, use echo output

**FUNC-05 (SHOULD): Implement main Function**

Check: Is main function implemented with minimized global scope processing?
Why: Global scope processing makes structure unclear, debugging difficult, unit testing impossible
Fix: Implement main function, call `main "$@"`, structure code properly
