### 3. Concurrency (CON)

**CON-01: Avoid goroutine Leaks**

Check: Do goroutines terminate properly and monitor context.Done()?
Why: Unterminated goroutines cause memory leaks, resource exhaustion, performance degradation
Fix: Clarify termination conditions, monitor context.Done(), use WaitGroup, verify with pprof

**CON-02: Clarify channel close Responsibility**

Check: Is channel close responsibility on the sender side?
Why: Receiver-side close, multiple closes, or forgotten close cause panics, goroutine leaks, deadlocks
Fix: Sender has close responsibility, prohibit receiver close, defer close, only once

**CON-03: Appropriate buffered/unbuffered channel Selection**

Check: Is buffered/unbuffered selection appropriate with justified size?
Why: Inappropriate size causes deadlocks, performance degradation, goroutine blocking
Fix: Select based on use case, justify buffered size, recommend buffered for async

**CON-04: Appropriate sync primitives Usage**

Check: Are sync.Mutex/RWMutex/WaitGroup/atomic used appropriately?
Why: Mutex copying, misuse, negative WaitGroup cause race conditions, deadlocks, data races
Fix: Pass Mutex by pointer, use RWMutex for read-heavy, match WaitGroup, leverage atomic

**CON-05: for+goroutine Variable Capture Issue**

Check: Are loop variables not directly referenced in goroutines?
Why: Uncaptured variables cause all goroutines to reference same value, unexpected behavior
Fix: Local copy of loop variable, pass as function argument (verify Go 1.22+ auto-resolution)

**CON-06: data race Detection and Prevention**

Check: Is go test -race executed and shared memory protected with sync?
Why: Undetected data races cause data corruption, unexpected behavior, production-only bugs
Fix: Mandatory go test -race in CI/CD, protect shared state with sync, use channels when possible
