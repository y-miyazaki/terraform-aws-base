## design-decisions

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Design Decisions

<!-- Answer: What major decisions does this document record? Source: read git log, PR descriptions, existing ADRs. -->

Focus on:
- why a decision exists
- tradeoffs accepted
- rejected alternatives with reasons
- long-term operational implications

Avoid:
- obvious decisions requiring no rationale
- implementation-only details without architectural impact
- decisions already documented elsewhere

## <Decision Title>

<!-- Use a descriptive title that captures the choice made. -->

### Context

<!-- Answer: What problem or constraint existed? What triggered this decision? Source: read related issues, PRs, or incident reports. -->

### Decision

<!-- Answer: What was chosen? State the decision clearly in 1-2 sentences. -->

### Rationale

<!-- Answer: Why this approach over alternatives? What constraints influenced it? Source: read discussion threads, review comments. -->

### Alternatives Rejected

<!-- Answer: What else was considered? Why was it rejected? -->

| Alternative | Reason Rejected |
| ----------- | --------------- |

### Consequences

<!-- Answer: What tradeoffs were accepted? What future limitations does this create? -->

## Decision Prompts

Consider:
- What future flexibility was sacrificed?
- Which assumptions could become invalid later?
- What operational burden does this introduce?
- Which alternatives may become viable later?
```
