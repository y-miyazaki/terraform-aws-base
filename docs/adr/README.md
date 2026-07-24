# Architecture Decision Records (ADR)

This directory contains Architecture Decision Records (ADRs) that document important architectural decisions made for this project.

## Format

We follow the [MADR (Markdown Any Decision Record)](https://adr.github.io/madr/) format, which provides:

- Status (Proposed, Accepted, Deprecated, Superseded)
- Context (Problem statement, constraints)
- Decision (What was decided and why)
- Consequences (Positive and negative outcomes)
- Alternatives Considered

## Active Decisions

### ADR-0001: Multi-Region Terraform Architecture Using AWS Provider v6 Region Attribute

**Status**: ✅ ACCEPTED (2026-06-18, updated 2026-06-19)

**Summary**: Adopted AWS Provider v6's resource-level `region` attribute with a unified `region` object variable (`global`, `primary`, `targets`). All resources explicitly declare their region. No provider aliases are used.

**Key Benefits**:

- Single `region` object replaces three separate variables
- Every resource declares its region explicitly — no silent fallback
- Scalable: add a region with a one-line change to `region.targets`
- No provider alias misrouting risk

**Region Tiers**:

- `main_regional_*.tf` — `for_each = toset(var.region.targets)`
- `main_central_*.tf` — `region = var.region.global`
- `main_common_*.tf` — `region = var.region.primary`
- `main_central_iam*.tf` — regionless (IAM, OIDC)

**Impact**: High

- Affects: All resource deployments in `terraform/base`
- Risk: Low (explicit region on every resource)

**See**: [ADR-0001: Multi-Region Terraform Architecture Using AWS Provider v6 Region Attribute](./0001-multi-region-terraform-architecture.md)

### ADR-0002: Global vs Regional Resource Classification

**Status**: ✅ ACCEPTED (2026-06-18, updated 2026-06-19)

**Summary**: Classifies resources into Regional, Global, Common, and Regionless tiers based on AWS service behavior. Prevents data duplication by ensuring account-wide services (Budgets, Trusted Advisor) run once from `var.region.global`.

**See**: [ADR-0002: Global vs Regional Resource Classification](./0002-global-vs-regional-resource-classification.md)

---

## Proposed Decisions

(None currently)

---

## Deprecated Decisions

(None currently)

---

## How to Add a New ADR

1. Create a new markdown file: `000X-short-title.md`
2. Use the MADR template (see ADR-0001)
3. Fill in all sections: Status, Context, Decision, Consequences, Alternatives
4. Get approval from team leads
5. Update this index
6. Commit with message: `docs(adr): Add ADR-000X - <title>`

## Guidelines

- **Keep it concise**: Aim for 1-2 pages
- **Document rationale**: Explain WHY, not just WHAT
- **Consider alternatives**: Show that options were evaluated
- **Record date**: When the decision was made
- **Link related docs**: Reference implementation, related ADRs

## Resources

- [ADR GitHub Organization](https://adr.github.io/)
- [MADR Format](https://adr.github.io/madr/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/recommended-practices)

---

**Last Updated**: 2026-06-19
