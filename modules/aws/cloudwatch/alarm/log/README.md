<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.47.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_filter"></a> [filter](#module\_filter) | ../../../_internal/auto_discovery_filter | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_metric_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_log_groups.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_groups) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_log_group_names_exclude_list"></a> [auto\_log\_group\_names\_exclude\_list](#input\_auto\_log\_group\_names\_exclude\_list) | (Optional) If create\_auto\_log\_group\_names is set to true, a list of log group name will be automatically registered, but at that time, specify the log group name you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_log_group_names_include_list"></a> [auto\_log\_group\_names\_include\_list](#input\_auto\_log\_group\_names\_include\_list) | (Optional) If create\_auto\_log\_group\_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included. | `list(string)` | `[]` | no |
| <a name="input_aws_cloudwatch_log_metric_filter"></a> [aws\_cloudwatch\_log\_metric\_filter](#input\_aws\_cloudwatch\_log\_metric\_filter) | (Required) aws\_cloudwatch\_log\_metric\_filter. | `any` | n/a | yes |
| <a name="input_aws_cloudwatch_metric_alarm"></a> [aws\_cloudwatch\_metric\_alarm](#input\_aws\_cloudwatch\_metric\_alarm) | (Required) aws\_cloudwatch\_metric\_alarm. | `any` | n/a | yes |
| <a name="input_create_auto_log_group_names"></a> [create\_auto\_log\_group\_names](#input\_create\_auto\_log\_group\_names) | (Optional) Builds a list of log group name to automatically set log\_group\_names. If this is true, the log\_group\_names setting will be ignored. | `bool` | `false` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of CloudWatch Logs metric filters and alarms. Defaults true. | `bool` | `true` | no |
| <a name="input_log_group_names"></a> [log\_group\_names](#input\_log\_group\_names) | (Optional) If create\_auto\_log\_group\_names is set to false, The log\_group\_names for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(string)` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_metric_alarm_arns"></a> [metric\_alarm\_arns](#output\_metric\_alarm\_arns) | List of created CloudWatch Metric Alarm ARNs. |
| <a name="output_metric_alarm_names"></a> [metric\_alarm\_names](#output\_metric\_alarm\_names) | List of created CloudWatch Metric Alarm names. |
| <a name="output_metric_filter_names"></a> [metric\_filter\_names](#output\_metric\_filter\_names) | List of created CloudWatch Log Metric Filter names. |
<!-- END_TF_DOCS -->
