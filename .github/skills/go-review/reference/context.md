### 2. Context Handling (CTX)

**CTX-01: Accept context in public APIs**

Check: Do public functions and methods accept context.Context as first argument?
Why: Missing context prevents timeout control, cancellation propagation, difficult testing
Fix: Add context.Context as first argument to all public APIs, unify ctx variable name

**CTX-02: Avoid context.Background()/TODO() Overuse**

Check: Are there no excessive context.Background() uses or lingering context.TODO()?
Why: Background overuse prevents timeout and cancellation propagation, no graceful shutdown
Fix: Avoid Background outside main/init, propagate received context, use TODO temporarily only

**CTX-03: Propagate context to goroutines**

Check: Is context passed when launching goroutines?
Why: Missing context causes goroutine leaks, no cancellation propagation, resource exhaustion
Fix: Always pass context when launching goroutines, monitor context.Done()

**CTX-04: Appropriate cancel Invocation**

Check: Is cancel from WithCancel/WithTimeout called with defer?
Why: Uncalled cancel causes resource leaks, goroutine leaks, memory growth
Fix: Mandatory defer cancel(), recommend defer even with WithTimeout
