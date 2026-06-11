## Global / Base (G)

**G-01 (SHOULD): No Hardcoded Secrets**

Check: Are API keys, passwords, and tokens not embedded in source code?
Why: Embedded secrets cause security breaches, credential leakage, audit violations
Fix: Use environment variables or AWS Secrets Manager, remove constants

**G-02 (SHOULD): Appropriate Function Signatures**

Check: Are argument count (4+), return types, and bool return overuse appropriate?
Why: Too many arguments and unclear return values cause API misuse, reduced readability, increased maintenance cost
Fix: Use argument structs, avoid named returns, place error return last

**G-03 (SHOULD): Leverage Standard Library**

Check: Are external dependencies avoided for features implementable with standard library?
Why: Unnecessary external dependencies increase vulnerability risk, dependency count, maintenance burden
Fix: Prioritize standard library like net/http, encoding/json

**G-04 (SHOULD): Appropriate Log Levels**

Check: Are Debug/Info/Warn/Error levels appropriate and structured logging used?
Why: Mixed log levels and unstructured logs make troubleshooting difficult, monitoring inadequate
Fix: Use structured logging libraries (zap/zerolog), unify levels, mask sensitive information

**G-05 (SHOULD): Restrict init() Complexity**

Check: Does init() avoid panics, external I/O, and non-trivial side effects? Is it minimal and deterministic?
Why: Complex init() hides initialization failures, causes unpredictable startup order across packages, and makes unit testing difficult
Fix: Limit init() to simple variable assignments; move complex initialization to explicit constructors or main()

**G-06 (SHOULD): Zero Value Design**

Check: Are types designed so their zero value is a valid and useful state where possible? (Types requiring mandatory initialization such as DB clients or config structs are exempt when documented.)
Why: Types with unusable zero values require mandatory initialization guards and cause subtle nil-dereference bugs when forgotten
Fix: Design structs so the zero value represents a valid empty state (e.g., sync.Mutex zero value is an unlocked mutex); document when zero value is not valid

**G-07 (SHOULD): Defensive Copy at Boundaries**

Check: Are slices and maps copied when accepting from or returning to external callers?
Why: Shared references to slices/maps allow external callers to mutate internal state, violating encapsulation and causing hard-to-reproduce data corruption
Fix: Copy incoming slices/maps before storing in structs; return copies rather than direct internal references to callers
