### 4. Code Standards (CODE)

**CODE-01: Appropriate Interface Design**

Check: Are interface method counts (5+) and consumer-side definitions appropriate?
Why: Too many methods and provider-side definitions make mocking difficult, increase test burden, reduce flexibility
Fix: Small interfaces (1-3 methods), consumer-side interfaces

**CODE-02: API/Package Boundary Design**

Check: Are there no excessive exports, unclear package name responsibilities, or unused internal/?
Why: Excessive exports increase API surface area, make maintenance difficult, increase breaking change risk
Fix: Minimize public APIs, express responsibility in package names, hide internal implementation with internal/

**CODE-03: Appropriate Struct Design**

Check: Are there no public fields, exposed mutexes, or excessive field counts (20+)?
Why: Public fields break encapsulation, cause race conditions, reduce readability
Fix: Make fields private, add getters/setters, split structs

**CODE-04: Safe Type Assertions**

Check: Do type assertions have ok checks (v, ok := i.(string) format)?
Why: Missing ok checks cause panics, application stops
Fix: Use v, ok := i.(string); if !ok {...} format

**CODE-05: Appropriate defer Usage**

Check: Are there no defer in loops and is resource release appropriate?
Why: defer in loops causes memory leaks, file descriptor exhaustion
Fix: defer outside loops, immediate Close(), value copying

**CODE-06: Appropriate slice/map Operations**

Check: Are nil checks, out-of-bounds prevention, and map race condition measures present?
Why: Missing nil checks and out-of-bounds access cause panics, map races cause data corruption
Fix: len checks, nil checks, use sync.Map or sync.RWMutex
