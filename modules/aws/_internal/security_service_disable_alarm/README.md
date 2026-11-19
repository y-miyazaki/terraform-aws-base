# security_service_disable_alarm

Internal helper that creates the CloudTrail metric filter and alarm for security service tampering: disabling, deleting or detaching GuardDuty, Security Hub, Macie, Inspector or Access Analyzer. Used by `security/cloudtrail/cloudtrail` and `security/cloudtrail/controltower`; not intended for direct use.

- The alarm fires on a single matching call (5-minute period) and has no recovery (OK) notification. Denied attempts are matched too.
- Disable calls are matched by name instead of `Disable*`, so that benign calls such as `DisableImportFindingsForProduct` and `DisableSecurityControl` do not raise the alarm. `UpdateDetector` matches only with `enable = false`.
- The pattern must stay within the 1024-character limit of CloudWatch Logs metric filters (checked by the tests).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.73.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_metric_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) ARNs notified when the alarm fires. | `list(string)` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable the filter and alarm. Defaults true. | `bool` | `true` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | (Required) Name of the CloudTrail log group the metric filter reads. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Prefix of the filter, metric and alarm names. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS region of the log group and the alarm. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_name"></a> [alarm\_name](#output\_alarm\_name) | The name of the alarm. Null when the module is disabled. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | The log group the metric filter reads. Null when the module is disabled. |
| <a name="output_pattern"></a> [pattern](#output\_pattern) | The metric filter pattern. Exposed so that callers and tests can inspect it. |
<!-- END_TF_DOCS -->
