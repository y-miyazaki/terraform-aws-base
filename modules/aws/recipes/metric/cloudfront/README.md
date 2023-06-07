<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~>3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cache_hit_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_401_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_403_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_404_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_502_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_503_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_504_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.origin_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [null_resource.this](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of CloudFront. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Center for Internet Security CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in CloudFront. | <pre>object({<br>    # (Required) Error401Rate threshold (unit=%)<br>    enabled_error_401_rate = bool<br>    error_401_rate         = number<br>    # (Required) Error403Rate threshold (unit=%)<br>    enabled_error_403_rate = bool<br>    error_403_rate         = number<br>    # (Required) Error404Rate threshold (unit=%)<br>    enabled_error_404_rate = bool<br>    error_404_rate         = number<br>    # (Required) Error502Rate threshold (unit=%)<br>    enabled_error_502_rate = bool<br>    error_502_rate         = number<br>    # (Required) Error503Rate threshold (unit=%)<br>    enabled_error_503_rate = bool<br>    error_503_rate         = number<br>    # (Required) Error504Rate threshold (unit=%)<br>    enabled_error_504_rate = bool<br>    error_504_rate         = number<br>    # (Required) CacheHitRate threshold (unit=%)<br>    enabled_cache_hit_rate = bool<br>    cache_hit_rate         = number<br>    # (Required) OriginLatency threshold (unit=Milliseconds)<br>    enabled_origin_latency = bool<br>    origin_latency         = number<br>    }<br>  )</pre> | <pre>{<br>  "cache_hit_rate": 70,<br>  "enabled_cache_hit_rate": true,<br>  "enabled_error_401_rate": true,<br>  "enabled_error_403_rate": false,<br>  "enabled_error_404_rate": true,<br>  "enabled_error_502_rate": true,<br>  "enabled_error_503_rate": true,<br>  "enabled_error_504_rate": true,<br>  "enabled_origin_latency": true,<br>  "error_401_rate": 1,<br>  "error_403_rate": 1,<br>  "error_404_rate": 1,<br>  "error_502_rate": 1,<br>  "error_503_rate": 1,<br>  "error_504_rate": 1,<br>  "origin_latency": 10000<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
