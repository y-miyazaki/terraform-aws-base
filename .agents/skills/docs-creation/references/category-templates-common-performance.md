## performance

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Performance

<!-- Answer: What are the performance-critical paths? Source: read benchmarks, profiling results, resource configs. -->

Focus on:
- operational bottlenecks and scaling boundaries
- latency/throughput constraints
- resource-sensitive behavior
- measured data over speculation

Avoid:
- micro-optimizations without operational relevance
- benchmark numbers without context
- generic performance advice

## Performance Goals

<!-- Answer: What are the latency/throughput/resource targets? Source: read SLOs, load test configs, capacity planning docs. -->

## Known Bottlenecks

<!-- Answer: What are the current bottlenecks? What is their impact? Source: read profiling results, incident reports. -->

### <Bottleneck>

#### Impact

#### Cause

#### Mitigation

## Tuning Guidance

<!-- Answer: What parameters affect performance? What are the tradeoffs? Source: read config files, resource limits. -->

| Parameter | Impact | Tradeoff |
| --------- | ------ | -------- |

## Decision Prompts

Consider:
- Which workloads scale poorly?
- Which operations are latency-sensitive?
- Which optimizations increase operational complexity?
```
