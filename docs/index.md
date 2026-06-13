# Documentation Index

Directory layout follows Diataxis.

## Tutorials

_Learning-oriented walkthroughs._

- [baseline-quickstart.md](tutorials/baseline-quickstart.md) - Bootstrap the base Terraform stack from a clean checkout

## How-To

_Task-oriented guides for specific goals._

- [initial-setup.md](how-to/initial-setup.md) - Common prerequisites (S3 state bucket, IAM user, first apply)
- [configure-base-tfvars.md](how-to/configure-base-tfvars.md) - Base stack configuration (security, IAM, integrations)
- [configure-monitor-tfvars.md](how-to/configure-monitor-tfvars.md) - Monitor stack configuration (metrics, logs, events)
- [configure-management-audit-tfvars.md](how-to/configure-management-audit-tfvars.md) - Audit account configuration
- [configure-management-root-tfvars.md](how-to/configure-management-root-tfvars.md) - Root account configuration
- [configure-development-environment.md](how-to/configure-development-environment.md) - Local development environment (devcontainer)
- [troubleshooting.md](how-to/troubleshooting.md) - Common issues, diagnostics, and recovery steps

## Reference

_Information-oriented technical descriptions._

- [cis-benchmark.md](reference/cis-benchmark.md) - CIS AWS Foundations Benchmark compliance matrix
- [features-base.md](reference/features-base.md) - Detailed descriptions for base stack features (security, IAM, cost)
- [features-monitor.md](reference/features-monitor.md) - Detailed descriptions for monitor stack features (logs, metrics, events)
- [jit-access-specification.md](reference/jit-access-specification.md) - JIT privileged access system with Slack integration, approval workflow, and auto-revocation
- [module-catalog.md](reference/module-catalog.md) - Reusable Terraform module catalog with purpose and location
- [monitoring.md](reference/monitoring.md) - Alert configuration, dashboards, and operational runbooks
- [performance.md](reference/performance.md) - Performance-sensitive settings, bottlenecks, and tuning guidance
- [security-coverage.md](reference/security-coverage.md) - AWS security services coverage matrix and implementation gaps
- [specification.md](reference/specification.md) - Infrastructure intent, lifecycle design, security, and operational expectations

## Explanation

_Understanding-oriented discussion of concepts and decisions._

- [architecture.md](explanation/architecture.md) - AWS Organization structure, multi-account design, and Terraform directory layout
- [design.md](explanation/design.md) - Module-level structural conventions, variable design patterns, and naming rules
- [design-decisions.md](explanation/design-decisions.md) - Key design decisions, rejected alternatives, and rationale for major patterns

## Agents

_Operational policies for AI agents working in this repository._

- [code-modification.md](agents/code-modification.md) - Standards for safe and minimal code changes
- [error-handling.md](agents/error-handling.md) - Error handling expectations and fallback behavior
- [execution-protocol.md](agents/execution-protocol.md) - Task execution, classification, and stop-and-ask criteria
- [external-knowledge.md](agents/external-knowledge.md) - Rules for introducing external dependencies and references
- [review-standards.md](agents/review-standards.md) - Code and documentation review standards
- [verification.md](agents/verification.md) - Validation requirements before completion
