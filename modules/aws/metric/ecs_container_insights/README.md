<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_rx_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_tx_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.storage_read_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.storage_write_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Lambda. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in ECS Container Insights. | <pre>object({<br/>    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)<br/>    enabled_cpu_utilization = bool<br/>    cpu_utilization         = number<br/>    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)<br/>    enabled_memory_utilization = bool<br/>    memory_utilization         = number<br/>    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)<br/>    enabled_network_rx_bytes = bool<br/>    network_rx_bytes         = number<br/>    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)<br/>    enabled_network_tx_bytes = bool<br/>    network_tx_bytes         = number<br/>    # (Optional) StorageReadBytes threshold (unit=Bytes)<br/>    enabled_storage_read_bytes = bool<br/>    storage_read_bytes         = number<br/>    # (Optional) StorageWriteBytes threshold (unit=Bytes)<br/>    enabled_storage_write_bytes = bool<br/>    storage_write_bytes         = number<br/>    }<br/>  )</pre> | <pre>{<br/>  "cpu_utilization": 80,<br/>  "enabled_cpu_utilization": true,<br/>  "enabled_memory_utilization": true,<br/>  "enabled_network_rx_bytes": false,<br/>  "enabled_network_tx_bytes": false,<br/>  "enabled_storage_read_bytes": false,<br/>  "enabled_storage_write_bytes": false,<br/>  "memory_utilization": 80,<br/>  "network_rx_bytes": 10485760,<br/>  "network_tx_bytes": 10485760,<br/>  "storage_read_bytes": 104857600,<br/>  "storage_write_bytes": 104857600<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
