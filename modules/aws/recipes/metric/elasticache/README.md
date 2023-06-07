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
| [aws_cloudwatch_metric_alarm.authentication_failures](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cache_hit_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.command_authorization_failures](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.curr_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.database_memory_usage_percentage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.engine_cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.key_authorization_failures](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.new_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.swap_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of ElastiCache. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Center for Internet Security CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in ElastiCache. | <pre>object({<br>    # AuthenticationFailures threshold (unit=Count)<br>    enabled_authentication_failures = bool<br>    authentication_failures         = number<br>    # CacheHitRate threshold (unit=Percent)<br>    enabled_cache_hit_rate = bool<br>    cache_hit_rate         = number<br>    # CommandAuthorizationFailures threshold (unit=Count)<br>    enabled_command_authorization_failures = bool<br>    command_authorization_failures         = number<br>    # CurrConnections threshold (unit=Count)<br>    enabled_curr_connections = bool<br>    curr_connections         = number<br>    # DatabaseMemoryUsagePercentage threshold (unit=Percent)<br>    enabled_database_memory_usage_percentage = bool<br>    database_memory_usage_percentage         = number<br>    # EngineCPUUtilization threshold (unit=Percent)<br>    enabled_engine_cpu_utilization = bool<br>    engine_cpu_utilization         = number<br>    # KeyAuthorizationFailures threshold (unit=Count)<br>    enabled_key_authorization_failures = bool<br>    key_authorization_failures         = number<br>    # NewConnections threshold (unit=Count)<br>    enabled_new_connections = bool<br>    new_connections         = number<br>    # SwapUsage threshold (unit=Bytes)<br>    enabled_swap_usage = bool<br>    swap_usage         = number<br>    }<br>  )</pre> | <pre>{<br>  "authentication_failures": 1,<br>  "cache_hit_rate": 10,<br>  "command_authorization_failures": 1,<br>  "curr_connections": 50,<br>  "database_memory_usage_percentage": 80,<br>  "enabled_authentication_failures": true,<br>  "enabled_cache_hit_rate": true,<br>  "enabled_command_authorization_failures": true,<br>  "enabled_curr_connections": true,<br>  "enabled_database_memory_usage_percentage": true,<br>  "enabled_engine_cpu_utilization": true,<br>  "enabled_key_authorization_failures": true,<br>  "enabled_new_connections": true,<br>  "enabled_swap_usage": true,<br>  "engine_cpu_utilization": 90,<br>  "key_authorization_failures": 1,<br>  "new_connections": 100,<br>  "swap_usage": 52428800<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
