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
| <a name="provider_external"></a> [external](#provider\_external) | 2.4.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_filter"></a> [filter](#module\_filter) | ../../_internal/auto_discovery_filter | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.duration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.duration_dry_run](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.failed_requests](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.http_2xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.http_4xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.http_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.success_percent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.success_percent_dry_run](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.success_percent_with_retries](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.visual_monitoring_success_percent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [external_external.list](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_dimensions_exclude_list"></a> [auto\_dimensions\_exclude\_list](#input\_auto\_dimensions\_exclude\_list) | (Optional) If create\_auto\_dimensions is set to true, specify the canary names you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_dimensions_include_list"></a> [auto\_dimensions\_include\_list](#input\_auto\_dimensions\_include\_list) | (Optional) If create\_auto\_dimensions is set to true, specify the canary names you want to include using partial match. If empty, all canaries will be included (except excluded ones). | `list(string)` | `[]` | no |
| <a name="input_create_auto_dimensions"></a> [create\_auto\_dimensions](#input\_create\_auto\_dimensions) | (Optional) Builds a list of Synthetics Canaries to automatically set dimensions. If this is true, the dimensions setting will be ignored. | `bool` | `false` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) If create\_auto\_dimensions is set to false, the dimensions for the alarm's associated metric. Required when create\_auto\_dimensions=false. | `list(map(any))` | `[]` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Synthetics Canary. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in Synthetics. | <pre>object({<br/>    # (Required) 2xx threshold (unit=Count)<br/>    enabled_2xx = bool<br/>    http_2xx    = number<br/>    # (Required) 4xx threshold (unit=Count)<br/>    enabled_4xx = bool<br/>    http_4xx    = number<br/>    # (Required) 5xx threshold (unit=Count)<br/>    enabled_5xx = bool<br/>    http_5xx    = number<br/>    # (Required) Duration threshold (unit=Milliseconds)<br/>    enabled_duration = bool<br/>    duration         = number<br/>    # (Required) DurationDryRun threshold (unit=Milliseconds)<br/>    enabled_duration_dry_run = bool<br/>    duration_dry_run         = number<br/>    # (Required) Failed threshold (unit=Count)<br/>    enabled_failed = bool<br/>    failed         = number<br/>    # (Required) FailedRequests threshold (unit=Count)<br/>    enabled_failed_requests = bool<br/>    failed_requests         = number<br/>    # (Required) SuccessPercent threshold (unit=Percent)<br/>    enabled_success_percent = bool<br/>    success_percent         = number<br/>    # (Required) SuccessPercentDryRun threshold (unit=Percent)<br/>    enabled_success_percent_dry_run = bool<br/>    success_percent_dry_run         = number<br/>    # (Required) SuccessPercentWithRetries threshold (unit=Percent)<br/>    enabled_success_percent_with_retries = bool<br/>    success_percent_with_retries         = number<br/>    # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)<br/>    enabled_visual_monitoring_success_percent = bool<br/>    visual_monitoring_success_percent         = number<br/>  })</pre> | <pre>{<br/>  "duration": 30000,<br/>  "duration_dry_run": 30000,<br/>  "enabled_2xx": false,<br/>  "enabled_4xx": true,<br/>  "enabled_5xx": true,<br/>  "enabled_duration": true,<br/>  "enabled_duration_dry_run": false,<br/>  "enabled_failed": true,<br/>  "enabled_failed_requests": false,<br/>  "enabled_success_percent": true,<br/>  "enabled_success_percent_dry_run": false,<br/>  "enabled_success_percent_with_retries": false,<br/>  "enabled_visual_monitoring_success_percent": false,<br/>  "failed": 1,<br/>  "failed_requests": 1,<br/>  "http_2xx": 100,<br/>  "http_4xx": 1,<br/>  "http_5xx": 1,<br/>  "success_percent": 99,<br/>  "success_percent_dry_run": 99,<br/>  "success_percent_with_retries": 99,<br/>  "visual_monitoring_success_percent": 99<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | Map of alarm ARNs by canary name and metric type |
| <a name="output_alarm_arns_list"></a> [alarm\_arns\_list](#output\_alarm\_arns\_list) | Flattened list of all alarm ARNs |
| <a name="output_monitored_canaries"></a> [monitored\_canaries](#output\_monitored\_canaries) | List of canary names being monitored |
<!-- END_TF_DOCS -->
