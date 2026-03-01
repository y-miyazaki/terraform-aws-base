### 8. Performance (PERF)

**PERF-01: Memory Optimization**

Check: Are slice capacity pre-allocated, map initial capacity specified, and sync.Pool utilized?
Why: Frequent reallocations and unspecified initial capacity increase GC load, memory usage
Fix: Pre-allocate with make([]T, 0, cap), utilize sync.Pool, analyze with pprof

**PERF-02: CPU Optimization**

Check: Are there no O(n²) algorithms, unnecessary calculations, or duplicate processing in loops?
Why: Inefficient algorithms cause response delays, high CPU usage, reduced throughput
Fix: Review algorithms, cache calculation results, measure with benchmarks

**PERF-03: I/O Optimization**

Check: Are bufio used, connection pools implemented, and buffer sizes appropriate?
Why: Unbuffered I/O and per-request connections increase I/O wait time, latency
Fix: Use bufio, implement connection pools, appropriate buffer sizes

**PERF-04: Appropriate Data Structure Selection**

Check: Are map/set utilized, appropriate indexes, and data structures optimized?
Why: Inappropriate data structures and excessive linear searches increase search time, reduce processing speed
Fix: Utilize map/set, appropriate indexes, optimize data structures

**PERF-05: GC Consideration**

Check: Are allocations reduced, value types utilized, and sync.Pool used?
Why: Massive allocations and pointer overuse increase GC pauses, worsen latency
Fix: Reduce allocations, utilize value types, use sync.Pool, analyze pprof heap

**PERF-06: String Processing Optimization**

Check: Are strings.Builder used, bytes.Buffer utilized, and string concatenation minimized?
Why: String concatenation (+ operator) and frequent bytes conversion increase memory usage, reduce processing speed
Fix: Use strings.Builder, utilize bytes.Buffer, minimize string concatenation

**PERF-07: Parallel Processing Optimization**

Check: Are worker pools implemented, GOMAXPROCS considered, and buffered channels used?
Why: Unlimited goroutine creation and unadjusted parallelism increase context switches, memory exhaustion
Fix: Implement worker pools, consider GOMAXPROCS, use buffered channels

**PERF-08: Caching Strategy**

Check: Are caches implemented, TTL set, and LRU/LFU strategies present?
Why: Missing cache implementation and unset TTL cause high DB load, reduced scalability
Fix: Implement Redis/in-memory cache, set TTL, LRU/LFU strategies

**PERF-09: Leverage pprof**

Check: Are regular pprof measurements and CPU/memory/goroutine profile analyses performed?
Why: Missing profiling makes bottlenecks unclear, speculative optimization, missed issues
Fix: Regular pprof measurements, profile analysis, continuous monitoring

**PERF-10: Hot Path Optimization**

Check: Are critical paths identified, high-frequency processing optimized, and before/after measured?
Why: Unidentified hot paths and insufficient high-frequency optimization degrade overall performance
Fix: Identify hot paths, prioritize optimization, measure before/after
