### 2. Code Standards (CODE)

**CODE-01: Proper Array Usage**

Check: Are paths with spaces and multiple values managed with arrays?
Why: String splitting and missing quotes cause filename splitting and unexpected argument expansion
Fix: Manage multiple values with arrays, use `"${array[@]}"` expansion

**CODE-02: Minimize Global Variables**

Check: Are local declarations used within functions?
Why: Excessive global variables cause variable pollution, unexpected behavior, difficult debugging
Fix: Use local declarations in functions, readonly constants, minimize globals

**CODE-03: Proper Here Document Usage**

Check: Are here documents used for multi-line strings?
Why: Repeated echo complicates escaping, reduces readability, hinders maintenance
Fix: Use `cat <<'EOF'`, leverage here documents

**CODE-04: Proper Process Substitution Usage**

Check: Is process substitution used where temporary files are unnecessary?
Why: Unnecessary temporary file generation increases file I/O and complicates cleanup
Fix: Use `<(command)` and `>(command)`

**CODE-05: Single Responsibility Functions with Explicit Arguments**

Check: Do functions have single responsibility and accept arguments explicitly?
Why: Mixed responsibilities and global variable dependencies make testing difficult and prevent reuse
Fix: Split into single responsibilities, accept input via arguments, minimize global dependencies
