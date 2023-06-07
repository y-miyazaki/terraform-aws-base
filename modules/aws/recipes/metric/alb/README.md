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
| [aws_cloudwatch_metric_alarm.active_connection_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.client_tls_negotiation_error_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.consumed_lcus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.httpcode_4xx_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.httpcode_5xx_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.httpcode_elb_4xx_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.httpcode_elb_5xx_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_tls_negotiation_error_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_host_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of ALB. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Center for Internet Security CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in ALB. | <pre>object({<br>    # ActiveConnectionCount threshold (unit=Count)<br>    enabled_active_connection_count = bool<br>    active_connection_count         = number<br>    # ClientTLSNegotiationErrorCount threshold (unit=Count)<br>    enabled_client_tls_negotiation_error_count = bool<br>    client_tls_negotiation_error_count         = number<br>    # ConsumedLCUs threshold (unit=Count)<br>    enabled_consumed_lcus = bool<br>    consumed_lcus         = number<br>    # HTTPCode_4XX_Count	threshold (unit=Count)<br>    enabled_httpcode_4xx_count = bool<br>    httpcode_4xx_count         = number<br>    # HTTPCode_5XX_Count	threshold (unit=Count)<br>    enabled_httpcode_5xx_count = bool<br>    httpcode_5xx_count         = number<br>    # HTTPCode_ELB_4XX_Count	threshold (unit=Count)<br>    enabled_httpcode_elb_4xx_count = bool<br>    httpcode_elb_4xx_count         = number<br>    # HTTPCode_ELB_5XX_Count	threshold (unit=Count)<br>    enabled_httpcode_elb_5xx_count = bool<br>    httpcode_elb_5xx_count         = number<br>    # TargetResponseTime	threshold (unit=)<br>    enabled_target_response_time = bool<br>    target_response_time         = number<br>    # TargetTLSNegotiationErrorCount	threshold (unit=Count)<br>    enabled_target_tls_negotiation_error_count = bool<br>    target_tls_negotiation_error_count         = number<br>    # UnHealthyHostCount	threshold (unit=Count)<br>    enabled_unhealthy_host_count = bool<br>    unhealthy_host_count         = number<br>    }<br>  )</pre> | <pre>{<br>  "active_connection_count": 10000,<br>  "client_tls_negotiation_error_count": 10,<br>  "consumed_lcus": 5,<br>  "enabled_active_connection_count": true,<br>  "enabled_client_tls_negotiation_error_count": true,<br>  "enabled_consumed_lcus": true,<br>  "enabled_httpcode_4xx_count": true,<br>  "enabled_httpcode_5xx_count": true,<br>  "enabled_httpcode_elb_4xx_count": true,<br>  "enabled_httpcode_elb_5xx_count": true,<br>  "enabled_target_response_time": true,<br>  "enabled_target_tls_negotiation_error_count": true,<br>  "enabled_unhealthy_host_count": true,<br>  "httpcode_4xx_count": 1,<br>  "httpcode_5xx_count": 1,<br>  "httpcode_elb_4xx_count": 1,<br>  "httpcode_elb_5xx_count": 1,<br>  "target_response_time": 10,<br>  "target_tls_negotiation_error_count": 10,<br>  "unhealthy_host_count": 1<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
