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

Prefer a common retention value from [README-base-tfvars.md](../how-to/configure-base-tfvars.md) and only add per-service overrides when there is a concrete retention requirement.

### Multi-region resource duplication

#### Impact

When a feature is enabled in the primary region and again in `us-east-1`, plan and apply time increase and the account accumulates duplicate resources.

#### Cause

The architecture uses a dual-module pattern for some services with a `us_east_1` toggle and a guard that skips the secondary copy when the primary region is already `us-east-1`.

#### Mitigation

Set `us_east_1.is_enabled` only for services that truly need the secondary region, and verify the guard logic described in [docs/architecture.md](../explanation/architecture.md).

### JIT access revocation latency

#### Impact

Privileged access remains active until the cleanup schedule runs, so the schedule interval defines the longest stale-access window.

#### Cause

The cleanup checker in the JIT access module is scheduled through EventBridge and defaults to a 15 minute rate.

#### Mitigation

Adjust `cleanup_schedule_expression` in [modules/aws/jit_access/variables.tf](../../modules/aws/jit_access/variables.tf) if a shorter revocation window is required.

### Redshift monitoring fan-out

#### Impact

A large threshold matrix creates more alarms and more operational noise, which makes it harder to spot the metrics that matter.

#### Cause

The Redshift metric module exposes many thresholds, including maintenance mode, queue depth, latency, and throughput checks.

#### Mitigation

Enable only the thresholds that are meaningful for the cluster class and workload. See [modules/aws/metric/redshift/variables.tf](../../modules/aws/metric/redshift/variables.tf) for the available switches.

## Tuning Guidance

| Parameter | Impact | Tradeoff |
| --------- | ------ | -------- |
| `cloudwatch_log_group.retention_in_days` | Controls the default log retention period for all services | Longer retention increases storage cost and review volume |
| `cloudwatch_log_group.override.<service>.retention_in_days` | Tunes retention for a single service without changing the global default | Adds configuration complexity and per-service drift risk |
| `us_east_1.is_enabled` | Controls whether the secondary region resources are created | Broader coverage increases plan/apply time and resource count |
| `cleanup_schedule_expression` | Controls how often stale JIT assignments are checked | Shorter intervals reduce stale access time but increase scheduler activity |
| `enabled_*` threshold flags in Redshift monitoring | Controls which alarms exist for each cluster | More enabled checks improve visibility but increase noise and maintenance cost |

## Related Documents

- [monitoring.md](../reference/monitoring.md) - Alert definitions and operational runbooks.
- [specification.md](../reference/specification.md) - Repository-wide lifecycle and safety expectations.
- [design-decisions.md](../explanation/design-decisions.md) - Why some settings are intentionally conservative.
