# AGENTS.md

Operational constitution for AI-assisted development agents.
This file is the always-loaded kernel. Detailed standards are in [docs/agents/](docs/agents/).

---

## Core Principles

- Prefer minimal, surgical diffs. Do NOT rewrite or touch unrelated code.
- Never fabricate APIs, commands, paths, or behavior. If uncertain, state "unknown".
- Preserve existing architecture and conventions unless explicitly instructed to change.
- Evidence-First: Use repository code, docs, and tests as the primary source of truth.
- Control scope. Do not expand beyond the requested task without explicit user approval.
- Provide honest, critical feedback. State trade-offs and risks clearly.

## Safety

- Stop and Ask: Explicitly request user confirmation before destructive operations (data deletion, force-push, irreversible migrations, production changes).
- Do not expose secrets, credentials, or sensitive tokens in outputs, logs, or commits.
- Do not repeatedly retry failed destructive operations without understanding failure causes.
- Write temporary artifacts only to ignored locations. Clean up completely when done.

## Completion Requirements

You MUST explicitly state the following in your final response to complete the task:
1. **Implementation:** Overview of changes made.
2. **Verification:** Proof of verification performed (or an explicit statement of inability to verify).
3. **Risks:** Assumptions made and residual risks.

## Extended Standards (Dynamic Loading)

You MUST load and read the relevant file using your file-viewing tool BEFORE starting the corresponding task:

- [execution-protocol.md](docs/agents/execution-protocol.md) — Load before planning, task classification, or budget allocation.
- [verification.md](docs/agents/verification.md) — Load before running tests or performing verification.
- [code-modification.md](docs/agents/code-modification.md) — Load before modifying any existing code.
- [review-standards.md](docs/agents/review-standards.md) — Load before preparing comparative analysis or decision traces.
- [error-handling.md](docs/agents/error-handling.md) — Load immediately when encountering unexpected errors or system failures.
- [external-knowledge.md](docs/agents/external-knowledge.md) — Load when introducing external libraries or analyzing ecosystem impacts.
