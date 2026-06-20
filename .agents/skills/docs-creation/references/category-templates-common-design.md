## design

Templates are guidance and review rubrics, not rigid prose generators.
Adapt structure and depth to the repository and context.
Remove sections that cannot be populated with concrete information.

```markdown
# Design Document

<!-- Answer: What module/component is this about? What problem does it solve? Source: read the target module's README or package doc. -->

Focus on:
- component interactions and ownership
- state management and lifecycle
- interface contracts
- design constraints and tradeoffs

Avoid:
- documenting every internal detail equally
- duplicating source code structure without rationale
- generic design principles not specific to this module

## Overview

<!-- Answer: What is the purpose and scope of this design? What triggered it? Source: read the module's main files and any related issues/PRs. -->

## Component Design

<!-- Answer: What are the key components? What does each own? How do they interact? Source: read struct/class definitions, constructors, and dependency injection. -->

## State and Data Flow

<!-- Answer: Who owns mutable state? What are the synchronization boundaries? Source: read storage layers, caches, and concurrent access patterns. -->

## Interfaces and Contracts

<!-- Answer: What interfaces are externally consumed? What are the compatibility guarantees? Source: read exported interfaces, API types, and version constraints. -->

## Constraints and Tradeoffs

<!-- Answer: What limitations are intentional? What was traded off and why? Source: read comments, commit messages, and related design-decisions. -->

## Decision Prompts

Consider:
- Which components own mutable state?
- Which interfaces are externally consumed?
- Which failures are hardest to recover from?
- Which implementation details are intentionally hidden?
```
