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
| [aws_cloudwatch_metric_alarm.error_4xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.integration_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [external_external.list](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_dimensions_exclude_list"></a> [auto\_dimensions\_exclude\_list](#input\_auto\_dimensions\_exclude\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of API Gateways will be automatically registered, but at that time, specify the API Gateway name you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_dimensions_include_list"></a> [auto\_dimensions\_include\_list](#input\_auto\_dimensions\_include\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of API Gateways will be automatically registered, but at that time, specify the API Gateway name you want to include using partial match. If empty, all API Gateways will be included (except excluded ones). | `list(string)` | `[]` | no |
| <a name="input_create_auto_dimensions"></a> [create\_auto\_dimensions](#input\_create\_auto\_dimensions) | (Optional) Builds a list of API Gateways to automatically set dimensions. If this is true, the dimensions setting will be ignored. | `bool` | `false` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) If create\_auto\_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of API Gateway. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in API Gateway. | <pre>object({<br/>    # 4XXerror threshold (unit=%)<br/>    error4XX = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # 5XXerror threshold (unit=%)<br/>    error5XX = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # IntegrationLatency threshold (unit=Milliseconds)<br/>    integration_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Latency threshold (unit=Milliseconds)<br/>    latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>  })</pre> | <pre>{<br/>  "error4XX": {<br/>    "enabled": true,<br/>    "value": 1<br/>  },<br/>  "error5XX": {<br/>    "enabled": true,<br/>    "value": 1<br/>  },<br/>  "integration_latency": {<br/>    "enabled": true,<br/>    "value": 10000<br/>  },<br/>  "latency": {<br/>    "enabled": true,<br/>    "value": 10000<br/>  }<br/>}</pre> | no |
| <a name="input_threshold_override"></a> [threshold\_override](#input\_threshold\_override) | (Optional) Override thresholds for specific resources. Key is the ApiName. Each metric accepts enabled, value, datapoints\_to\_alarm and evaluation\_periods. | <pre>map(object({<br/>    # 4XXerror threshold (unit=%)<br/>    error4XX = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # 5XXerror threshold (unit=%)<br/>    error5XX = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # IntegrationLatency threshold (unit=Milliseconds)<br/>    integration_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Latency threshold (unit=Milliseconds)<br/>    latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
