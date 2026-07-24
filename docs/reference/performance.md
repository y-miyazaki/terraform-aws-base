# Performance Tuning

This document records the performance-sensitive settings in this repository. It is for operators tuning control-plane behavior, alert latency, and resource growth rather than application runtime performance.

## Performance Goals

- Keep notification and cleanup paths predictable even when multiple stacks are enabled.
- Avoid unnecessary resource duplication when a service is enabled in both the default region and `us-east-1`.
- Keep CloudWatch log retention aligned with the audit horizon so storage growth stays intentional.
- Keep stale privileged access exposure bounded by the cleanup schedule in the JIT access workflow.

## Known Bottlenecks

### CloudWatch log retention growth

#### Impact

Longer retention increases CloudWatch Logs storage volume and can make operational review slower when many services write to the same account.

#### Cause

The base and monitor stacks centralize log retention in `cloudwatch_log_group`, with per-service overrides when needed.

#### Mitigation

Prefer a common retention value from [Base Terraform Configuration Guide](../how-to/configure-base-tfvars.md) and only add per-service overrides when there is a concrete retention requirement.

### Multi-region resource duplication

#### Impact

When `var.region.targets` includes many regions, plan and apply time increase proportionally for regional services.

#### Cause

Regional services (`main_regional_*.tf`) deploy to every region in `var.region.targets`. Global services (`main_central_*.tf`) deploy once to `var.region.global`.

#### Mitigation

Only include regions in `var.region.targets` that genuinely need the service. Account-wide services (Budgets, Trusted Advisor) are already limited to a single deployment via `region = var.region.global`.

### JIT access revocation latency

#### Impact

Privileged access remains active until the cleanup schedule runs, so the schedule interval defines the longest stale-access window.

#### Cause

The cleanup checker in the JIT access module is scheduled through EventBridge and defaults to a 15 minute rate.

#### Mitigation

Adjust `cleanup_schedule_expression` in [modules/aws/jit_access/variables.tf](https://github.com/y-miyazaki/terraform-aws-base/blob/main/modules/aws/jit_access/variables.tf) if a shorter revocation window is required.

### Redshift monitoring fan-out

#### Impact

A large threshold matrix creates more alarms and more operational noise, which makes it harder to spot the metrics that matter.

#### Cause

The Redshift metric module exposes many thresholds, including maintenance mode, queue depth, latency, and throughput checks.

#### Mitigation

Enable only the thresholds that are meaningful for the cluster class and workload. See [modules/aws/metric/redshift/variables.tf](https://github.com/y-miyazaki/terraform-aws-base/blob/main/modules/aws/metric/redshift/variables.tf) for the available switches.

## Tuning Guidance

| Parameter                                                   | Impact                                                                   | Tradeoff                                                                       |
| ----------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| `cloudwatch_log_group.retention_in_days`                    | Controls the default log retention period for all services               | Longer retention increases storage cost and review volume                      |
| `cloudwatch_log_group.override.<service>.retention_in_days` | Tunes retention for a single service without changing the global default | Adds configuration complexity and per-service drift risk                       |
| `region.targets`                                            | Controls which regions receive regional resources                        | More regions increase plan/apply time and resource count                       |
| `cleanup_schedule_expression`                               | Controls how often stale JIT assignments are checked                     | Shorter intervals reduce stale access time but increase scheduler activity     |
| `enabled_*` threshold flags in Redshift monitoring          | Controls which alarms exist for each cluster                             | More enabled checks improve visibility but increase noise and maintenance cost |

## Related Documents

- [Monitoring](../reference/monitoring.md) - Alert definitions and operational runbooks.
- [Terraform Specification](../reference/specification.md) - Repository-wide lifecycle and safety expectations.
- [Design Decisions](../explanation/design-decisions.md) - Why some settings are intentionally conservative.
