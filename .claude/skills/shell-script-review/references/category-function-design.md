## Function Design (FUNC)

**FUNC-01 (SHOULD): parse_arguments uses while+case with -h/--help**

Check: Is parse_arguments standardized with while + case statements when the script accepts options?
Why: Duplicated and inconsistent argument parsing makes adding options difficult and introduces bugs
Fix: Use while [[ $# -gt 0 ]] + case pattern, support -h|--help and long options

**FUNC-02 (SHOULD): Entry scripts implement show_usage (Usage/Options/Examples)**

Check: Does show_usage include Usage/Options/Examples and exit 0 when the script is an executable entry point with options?
Why: Missing help implementation reduces usability, increases support requests, causes misuse
Fix: Implement show_usage function with Usage/Options/Examples, exit 0

**FUNC-03 (SHOULD): Executable scripts use main + BASH_SOURCE entry guard**

Check: Is main implemented with minimized global-scope processing and an entry guard for executable scripts?
Why: Global-scope processing and missing main hinder testing and make side effects hard to reason about
Fix: Put orchestration in `main`; use `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`
