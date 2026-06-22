# Documentation Index

Directory layout follows Diataxis.

## Tutorials

_Learning-oriented walkthroughs._

- [Bootstrap the Base Terraform Stack](tutorials/baseline-quickstart.md) - Bootstrap the base Terraform stack from a clean checkout

## How-To

_Task-oriented guides for specific goals._

- [Initial Setup (Common)](how-to/initial-setup.md) - Common prerequisites (S3 state bucket, IAM user, first apply)
- [Base Terraform Configuration Guide](how-to/configure-base-tfvars.md) - Base stack configuration (security, IAM, integrations)
- [Monitor Terraform Configuration Guide](how-to/configure-monitor-tfvars.md) - Monitor stack configuration (metrics, logs, events)
- [Management Audit Terraform Configuration Guide](how-to/configure-management-audit-tfvars.md) - Audit account configuration
- [Management Root Terraform Configuration Guide](how-to/configure-management-root-tfvars.md) - Root account configuration
- [Terraform for Infrastructure](how-to/configure-development-environment.md) - Local development environment (devcontainer)
- [Troubleshooting](how-to/troubleshooting.md) - Common issues, diagnostics, and recovery steps

## Reference

_Information-oriented technical descriptions._

- [CIS AWS Foundations Benchmark Compliance Matrix](reference/cis-benchmark.md) - CIS AWS Foundations Benchmark compliance matrix
- [Base Features Detail](reference/features-base.md) - Detailed descriptions for base stack features (security, IAM, cost)
- [Monitor Features Detail](reference/features-monitor.md) - Detailed descriptions for monitor stack features (logs, metrics, events)
- [JIT Access System Specification](reference/jit-access-specification.md) - JIT privileged access system with Slack integration, approval workflow, and auto-revocation
- [Module Catalog](reference/module-catalog.md) - Reusable Terraform module catalog with purpose and location
- [Monitoring](reference/monitoring.md) - Alert configuration, dashboards, and operational runbooks
- [Performance Tuning](reference/performance.md) - Performance-sensitive settings, bottlenecks, and tuning guidance
- [AWS Security Services Coverage](reference/security-coverage.md) - AWS security services coverage matrix and implementation gaps
- [Terraform Specification](reference/specification.md) - Infrastructure intent, lifecycle design, security, and operational expectations

## Explanation

_Understanding-oriented discussion of concepts and decisions._

- [Architecture Overview](explanation/architecture.md) - AWS Organization structure, multi-account design, and Terraform directory layout
- [Design Document — Terraform Modules and Root Configurations](explanation/design.md) - Module-level structural conventions, variable design patterns, and naming rules
- [Design Decisions](explanation/design-decisions.md) - Key design decisions, rejected alternatives, and rationale for major patterns
