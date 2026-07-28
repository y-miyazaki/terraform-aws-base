## Code Standards (CODE)

**CODE-01 (SHOULD): Prefer local over globals inside functions**

Check: Are local declarations used within functions?
Why: Excessive global variables cause variable pollution, unexpected behavior, difficult debugging
Fix: Use local declarations in functions, readonly constants, minimize globals

**CODE-02 (SHOULD): One responsibility per function; pass args explicitly**

Check: Do functions have single responsibility and accept arguments explicitly?
Why: Mixed responsibilities and global variable dependencies make testing difficult and prevent reuse
Fix: Split into single responsibilities, accept input via arguments, minimize global dependencies
