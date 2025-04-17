<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.invocation_attempt_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.invocation_dropped_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.invocation_throttle_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_error_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_error_throttled_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of EventBridge Scheduler. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in EventBridge Scheduler. | <pre>object({<br>    # InvocationAttemptCount threshold (unit=Count)<br>    enabled_invocation_attempt_count = bool<br>    invocation_attempt_count         = number<br>    # TargetErrorCount threshold (unit=Count)<br>    enabled_target_error_count = bool<br>    target_error_count         = number<br>    # TargetErrorThrottledCount threshold (unit=Count)<br>    enabled_target_error_throttled_count = bool<br>    target_error_throttled_count         = number<br>    # InvocationThrottleCount threshold (unit=Count)<br>    enabled_invocation_throttle_count = bool<br>    invocation_throttle_count         = number<br>    # InvocationDroppedCount threshold (unit=Count)<br>    enabled_invocation_dropped_count = bool<br>    invocation_dropped_count         = number<br>    }<br>  )</pre> | <pre>{<br>  "enabled_invocation_attempt_count": false,<br>  "enabled_invocation_dropped_count": true,<br>  "enabled_invocation_throttle_count": true,<br>  "enabled_target_error_count": true,<br>  "enabled_target_error_throttled_count": true,<br>  "invocation_attempt_count": 0,<br>  "invocation_dropped_count": 1,<br>  "invocation_throttle_count": 1,<br>  "target_error_count": 10,<br>  "target_error_throttled_count": 1<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
