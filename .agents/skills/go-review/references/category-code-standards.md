## Code Standards (CODE)

**CODE-01 (MUST): Appropriate Interface Design**

Check: Are interfaces kept small (1-3 methods) and defined on the consumer side?
Why: Too many methods and provider-side definitions make mocking difficult, increase test burden, reduce flexibility
Fix: Split interfaces with 5+ methods into focused roles, define interfaces where they are consumed

**CODE-02 (SHOULD): API/Package Boundary Design**

Check: Are there no excessive exports, unclear package name responsibilities, or unused internal/?
Why: Excessive exports increase API surface area, make maintenance difficult, increase breaking change risk
Fix: Minimize public APIs, express responsibility in package names, hide internal implementation with internal/

**CODE-03 (SHOULD): Appropriate Struct Design**

Check: Are fields with invariants unexported and protected by methods? Are mutexes unexported? Are structs with 20+ fields split?
Why: Exposing fields that maintain invariants breaks encapsulation and causes race conditions; exported mutexes leak synchronization details
Fix: Unexport fields that enforce invariants and provide accessor methods. Keep exported fields for DTOs, config structs, and serialization targets. Split large structs by responsibility

**CODE-04 (SHOULD): Safe Type Assertions**

Check: Do type assertions have ok checks (v, ok := i.(string) format)?
Why: Missing ok checks cause panics, application stops
Fix: Use v, ok := i.(string); if !ok {...} format

**CODE-05 (SHOULD): Appropriate defer Usage**

Check: Are there no defer in loops and is resource release appropriate?
Why: defer in loops causes memory leaks, file descriptor exhaustion
Fix: defer outside loops, immediate Close(), value copying

**CODE-06 (SHOULD): Appropriate slice/map Operations**

Check: Are nil checks, out-of-bounds prevention, and map race condition measures present?
Why: Missing nil checks and out-of-bounds access cause panics, map races cause data corruption
Fix: len checks, nil checks, use sync.Map or sync.RWMutex

**CODE-07 (SHOULD): Error String Format**

Check: Do error strings start with a lowercase letter and have no trailing punctuation?
Why: Error strings are often concatenated (e.g., fmt.Errorf("context: %w", err)), so starting with a capital letter or ending with punctuation produces awkward messages like "context: Connection refused."
Fix: Use lowercase start and no trailing period/exclamation: errors.New("connection refused") not errors.New("Connection refused.")

**CODE-08 (SHOULD): Import Grouping**

Check: Are imports organized into 3 groups: stdlib / external packages / internal packages, separated by blank lines?
Why: Mixed import groups reduce readability and make dependency classification unclear at a glance
Fix: Use goimports or manually split into stdlib, external, internal groups separated by blank lines

**CODE-09 (SHOULD): Avoid Naked Returns in Long Functions**

Check: Are naked returns (bare return statements with named return values) avoided in functions longer than ~10 lines?
Why: Naked returns in long functions make it difficult to trace what values are being returned, hurting readability
Fix: Use explicit return values in functions longer than ~10 lines; named returns are acceptable only in short functions or defer-based error-annotation patterns
