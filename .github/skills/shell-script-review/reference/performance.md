### 6. Performance (PERF)

**PERF-01: Minimize External Commands**

Check: Are external commands in loops minimized and Bash built-ins prioritized?
Why: External commands in loops increase execution time, CPU load, script delays
Fix: Prioritize Bash built-ins, move outside loops, batch processing

**PERF-02: Reduce Subshells**

Check: Are unnecessary `()` reduced and `{}` used instead?
Why: Unnecessary subshells increase memory consumption, execution time, waste resources
Fix: Use `{}`, manipulate variables directly, avoid subshells

**PERF-03: Optimize File I/O**

Check: Are files read in bulk and buffering utilized?
Why: Multiple file reads and line-by-line I/O cause I/O wait time, execution delays
Fix: Bulk reading, optimize while read, leverage buffering

**PERF-04: Efficient Loops**

Check: Is `while IFS= read -r` used and inefficient loops avoided?
Why: `for in $(cat)` causes memory consumption, processing delays, cannot handle large files
Fix: Use `while IFS= read -r`, efficient loops

**PERF-05: Optimize String Processing**

Check: Is Bash parameter expansion utilized and sed/awk overuse avoided?
Why: Overusing sed/awk increases process creation cost, execution time
Fix: Leverage Bash parameter expansion, prioritize built-ins

**PERF-06: Optimize Conditional Branching**

Check: Are early return and short-circuit evaluation used with shallow nesting?
Why: Deep nesting and duplicate checks reduce readability, increase execution time
Fix: Early return, `&&`/`||` short-circuit evaluation, leverage case statements

**PERF-07: Leverage Parallel Execution**

Check: Are `&` and `xargs -P` utilized for parallelizable processing?
Why: Sequential processing causes long execution time, underutilized resources, low throughput
Fix: Background execution, `xargs -P`, wait management

**PERF-08: Caching Strategy**

Check: Are identical processing results stored in variables and cached?
Why: Repeating identical processing wastes processing, increases execution time, wastes resources
Fix: Store results in variables, conditional caching, reduce duplication

**PERF-09: Resource Limits (ulimit)**

Check: Are resource limits set with ulimit?
Why: Unlimited resources cause memory leaks, process runaway, system resource exhaustion
Fix: Set ulimit, resource limits, defensive programming

**PERF-10: Profiling**

Check: Are performance bottlenecks identified with set -x and time?
Why: Unknown bottlenecks lead to ineffective optimization, resource waste
Fix: `set -x` trace, time measurement, identify bottlenecks
