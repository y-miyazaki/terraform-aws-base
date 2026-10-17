<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_helper"></a> [helper](#module\_helper) | ../../_internal/metric_helper | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_rx_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_tx_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.storage_read_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.storage_write_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Lambda. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in ECS Container Insights. | <pre>object({<br/>    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)<br/>    cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)<br/>    memory_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)<br/>    network_rx_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)<br/>    network_tx_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Optional) StorageReadBytes threshold (unit=Bytes)<br/>    storage_read_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # (Optional) StorageWriteBytes threshold (unit=Bytes)<br/>    storage_write_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>  })</pre> | <pre>{<br/>  "cpu_utilization": {<br/>    "enabled": true,<br/>    "value": 80<br/>  },<br/>  "memory_utilization": {<br/>    "enabled": true,<br/>    "value": 80<br/>  },<br/>  "network_rx_bytes": {<br/>    "enabled": false,<br/>    "value": 10485760<br/>  },<br/>  "network_tx_bytes": {<br/>    "enabled": false,<br/>    "value": 10485760<br/>  },<br/>  "storage_read_bytes": {<br/>    "enabled": false,<br/>    "value": 104857600<br/>  },<br/>  "storage_write_bytes": {<br/>    "enabled": false,<br/>    "value": 104857600<br/>  }<br/>}</pre> | no |
| <a name="input_threshold_override"></a> [threshold\_override](#input\_threshold\_override) | (Optional) Per-TaskDefinitionFamily threshold overrides. Key is the TaskDefinitionFamily (exact match), or the reserved key "default" when dimensions is empty. NOTE: do not use "default" as an actual TaskDefinitionFamily in dimensions; it would be indistinguishable from the reserved key. Value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints\_to\_alarm and evaluation\_periods. | <pre>map(object({<br/>    # CpuUtilized/CpuReserved threshold (unit=Percent)<br/>    cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # MemoryUtilized/MemoryReserved threshold (unit=Percent)<br/>    memory_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # NetworkRxBytes threshold (unit=Bytes/Second)<br/>    network_rx_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # NetworkTxBytes threshold (unit=Bytes/Second)<br/>    network_tx_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # StorageReadBytes threshold (unit=Bytes)<br/>    storage_read_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # StorageWriteBytes threshold (unit=Bytes)<br/>    storage_write_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
