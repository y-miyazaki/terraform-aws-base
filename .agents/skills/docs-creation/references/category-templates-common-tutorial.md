## tutorial

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# <Tutorial Title>

<!-- Answer: What will the reader build or achieve? Who is this for? How long will it take? Source: read quickstart scripts, example configs, test fixtures. -->

Focus on:
- learning-by-doing (practical experience)
- a single, reliable, failure-proof path
- immediate, visible results at each step
- concrete instructions (exact commands and expected outputs)

Avoid:
- deep conceptual explanations (use explanation/ docs)
- multiple choices or alternatives
- exhaustive reference material or edge cases (use reference/ docs)

## Prerequisites

<!-- Answer: What must be installed/configured before starting? Source: read CI setup steps, Dockerfile, devcontainer config. -->

## Goal

<!-- Answer: What concrete outcomes will the reader have after completing this? List 2-3 verifiable results. -->

## Step 1: <Action-Oriented Title>

<!-- Answer: What is the first thing the reader does? What command do they run? What do they see? Source: read setup scripts, Makefile targets. -->

**Expected Output:**
```text
<!-- Paste exact successful output so reader knows they are on track -->
```

## Step 2: <Action-Oriented Title>

<!-- Continue with minimal steps. Each step should produce visible progress. -->

## Verification

<!-- Answer: How does the reader confirm everything worked? Source: read test commands, health check endpoints. -->

## Next Steps

- How-To: `<Title>` (`docs/how-to/<filename>.md`) - For specific task recipes.
- Reference: `<Title>` (`docs/reference/<filename>.md`) - To look up detailed configurations/API specs.
- Explanation: `<Title>` (`docs/explanation/<filename>.md`) - To understand the architecture and design philosophy.

## Decision Prompts

Consider:
- Is this guide 100% reliable? If a beginner follows it exactly, will it work without errors?
- Did you eliminate all alternative choices?
- Are explanations kept to the absolute minimum required to complete the task?
- Is there an explicit verification step where the user gets immediate feedback?
```
