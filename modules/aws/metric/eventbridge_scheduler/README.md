<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.4.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_metric_helper"></a> [metric\_helper](#module\_metric\_helper) | ../../_internal/metric_helper | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.invocation_attempt_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.invocation_dropped_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.invocation_throttle_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_error_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_error_throttled_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [external_external.list](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_dimensions_exclude_list"></a> [auto\_dimensions\_exclude\_list](#input\_auto\_dimensions\_exclude\_list) | (Optional) List of schedule group names to exclude from auto-discovered dimensions. | `list(string)` | `[]` | no |
| <a name="input_auto_dimensions_include_list"></a> [auto\_dimensions\_include\_list](#input\_auto\_dimensions\_include\_list) | (Optional) List of schedule group names to include in auto-discovered dimensions. If empty, all discovered schedule groups are included. | `list(string)` | `[]` | no |
| <a name="input_create_auto_dimensions"></a> [create\_auto\_dimensions](#input\_create\_auto\_dimensions) | (Optional) Create dimensions automatically from EventBridge Scheduler schedule groups. | `bool` | `false` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of EventBridge Scheduler. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in EventBridge Scheduler. | <pre>object({<br/>    # InvocationAttemptCount threshold (unit=Count)<br/>    # Monitor total invocation attempts (typically disabled for regular monitoring)<br/>    enabled_invocation_attempt_count = bool<br/>    invocation_attempt_count         = number<br/>    # TargetErrorCount threshold (unit=Count)<br/>    # Alert on target execution errors (recommended: 1 for immediate notification)<br/>    enabled_target_error_count = bool<br/>    target_error_count         = number<br/>    # TargetErrorThrottledCount threshold (unit=Count)<br/>    # Alert on throttling errors from target services<br/>    enabled_target_error_throttled_count = bool<br/>    target_error_throttled_count         = number<br/>    # InvocationThrottleCount threshold (unit=Count)<br/>    # Alert on scheduler throttling due to rate limits<br/>    enabled_invocation_throttle_count = bool<br/>    invocation_throttle_count         = number<br/>    # InvocationDroppedCount threshold (unit=Count)<br/>    # Alert on dropped invocations due to system issues<br/>    enabled_invocation_dropped_count = bool<br/>    invocation_dropped_count         = number<br/>    }<br/>  )</pre> | <pre>{<br/>  "enabled_invocation_attempt_count": false,<br/>  "enabled_invocation_dropped_count": true,<br/>  "enabled_invocation_throttle_count": true,<br/>  "enabled_target_error_count": true,<br/>  "enabled_target_error_throttled_count": true,<br/>  "invocation_attempt_count": 0,<br/>  "invocation_dropped_count": 1,<br/>  "invocation_throttle_count": 1,<br/>  "target_error_count": 10,<br/>  "target_error_throttled_count": 1<br/>}</pre> | no |
| <a name="input_threshold_override"></a> [threshold\_override](#input\_threshold\_override) | (Optional) Per-schedule-group threshold overrides. Key is the schedule group name. | <pre>map(object({<br/>    enabled_invocation_attempt_count     = optional(bool)<br/>    invocation_attempt_count             = optional(number)<br/>    enabled_target_error_count           = optional(bool)<br/>    target_error_count                   = optional(number)<br/>    enabled_target_error_throttled_count = optional(bool)<br/>    target_error_throttled_count         = optional(number)<br/>    enabled_invocation_throttle_count    = optional(bool)<br/>    invocation_throttle_count            = optional(number)<br/>    enabled_invocation_dropped_count     = optional(bool)<br/>    invocation_dropped_count             = optional(number)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
