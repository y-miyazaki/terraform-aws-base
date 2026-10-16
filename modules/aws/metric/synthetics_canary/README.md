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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.4.2 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_helper"></a> [helper](#module\_helper) | ../../_internal/metric_helper | n/a |

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
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
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
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in Synthetics. | <pre>object({<br/>    # (Required) 2xx threshold (unit=Count)<br/>    http_2xx = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) 4xx threshold (unit=Count)<br/>    http_4xx = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) 5xx threshold (unit=Count)<br/>    http_5xx = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) Duration threshold (unit=Milliseconds)<br/>    duration = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) DurationDryRun threshold (unit=Milliseconds)<br/>    duration_dry_run = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) Failed threshold (unit=Count)<br/>    failed = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) FailedRequests threshold (unit=Count)<br/>    failed_requests = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) SuccessPercent threshold (unit=Percent)<br/>    success_percent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) SuccessPercentDryRun threshold (unit=Percent)<br/>    success_percent_dry_run = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) SuccessPercentWithRetries threshold (unit=Percent)<br/>    success_percent_with_retries = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)<br/>    visual_monitoring_success_percent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>  })</pre> | <pre>{<br/>  "duration": {<br/>    "enabled": true,<br/>    "value": 30000<br/>  },<br/>  "duration_dry_run": {<br/>    "enabled": false,<br/>    "value": 30000<br/>  },<br/>  "failed": {<br/>    "enabled": true,<br/>    "value": 1<br/>  },<br/>  "failed_requests": {<br/>    "enabled": false,<br/>    "value": 1<br/>  },<br/>  "http_2xx": {<br/>    "enabled": false,<br/>    "value": 100<br/>  },<br/>  "http_4xx": {<br/>    "enabled": true,<br/>    "value": 1<br/>  },<br/>  "http_5xx": {<br/>    "enabled": true,<br/>    "value": 1<br/>  },<br/>  "success_percent": {<br/>    "enabled": true,<br/>    "value": 99<br/>  },<br/>  "success_percent_dry_run": {<br/>    "enabled": false,<br/>    "value": 99<br/>  },<br/>  "success_percent_with_retries": {<br/>    "enabled": false,<br/>    "value": 99<br/>  },<br/>  "visual_monitoring_success_percent": {<br/>    "enabled": false,<br/>    "value": 99<br/>  }<br/>}</pre> | no |
| <a name="input_threshold_override"></a> [threshold\_override](#input\_threshold\_override) | (Optional) Map of resource name to threshold overrides. Key is CanaryName (exact match), value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints\_to\_alarm and evaluation\_periods. | <pre>map(object({<br/>    # 2xx threshold (unit=Count)<br/>    http_2xx = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # 4xx threshold (unit=Count)<br/>    http_4xx = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # 5xx threshold (unit=Count)<br/>    http_5xx = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Duration threshold (unit=Milliseconds)<br/>    duration = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # DurationDryRun threshold (unit=Milliseconds)<br/>    duration_dry_run = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Failed threshold (unit=Count)<br/>    failed = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # FailedRequests threshold (unit=Count)<br/>    failed_requests = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # SuccessPercent threshold (unit=Percent)<br/>    success_percent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # SuccessPercentDryRun threshold (unit=Percent)<br/>    success_percent_dry_run = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # SuccessPercentWithRetries threshold (unit=Percent)<br/>    success_percent_with_retries = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # VisualMonitoringSuccessPercent threshold (unit=Percent)<br/>    visual_monitoring_success_percent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | Map of alarm ARNs by canary name and metric type |
| <a name="output_alarm_arns_list"></a> [alarm\_arns\_list](#output\_alarm\_arns\_list) | Flattened list of all alarm ARNs |
| <a name="output_monitored_canaries"></a> [monitored\_canaries](#output\_monitored\_canaries) | List of canary names being monitored |
<!-- END_TF_DOCS -->
