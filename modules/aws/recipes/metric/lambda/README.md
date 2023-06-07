<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.concurrent_executions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.duration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.throttles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Lambda. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Center for Internet Security CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in Lambda. | <pre>object({<br>    # ConcurrentExecutions threshold (unit=Count)<br>    enabled_concurrent_executions = bool<br>    concurrent_executions         = number<br>    # Duration threshold (unit=Milliseconds)<br>    enabled_duration = bool<br>    duration         = number<br>    # Errors threshold (unit=Count)<br>    enabled_errors = bool<br>    errors         = number<br>    # Throttles threshold (unit=Count)<br>    enabled_throttles = bool<br>    throttles         = number<br>    }<br>  )</pre> | <pre>{<br>  "concurrent_executions": 500,<br>  "duration": 10000,<br>  "enabled_concurrent_executions": true,<br>  "enabled_duration": true,<br>  "enabled_errors": true,<br>  "enabled_throttles": true,<br>  "errors": 1,<br>  "throttles": 10<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
