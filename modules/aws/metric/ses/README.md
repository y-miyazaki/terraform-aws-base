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
| [aws_cloudwatch_metric_alarm.bounce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.complaint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.reject](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.reputation_bouncerate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.reputation_complaintrate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.send](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of SES. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in SES. | <pre>object({<br/>    # Bounce threshold (unit=Count)<br/>    bounce = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Complaint threshold (unit=Count)<br/>    complaint = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Delivery threshold (unit=Count)<br/>    delivery = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Reject threshold (unit=Count)<br/>    reject = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Reputation.BounceRate threshold (unit=Percent)<br/>    reputation_bouncerate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Reputation.ComplaintRate threshold (unit=Percent)<br/>    reputation_complaintrate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>    # Send threshold (unit=Count)<br/>    send = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })<br/>  })</pre> | <pre>{<br/>  "bounce": {<br/>    "enabled": false,<br/>    "value": 100<br/>  },<br/>  "complaint": {<br/>    "enabled": false,<br/>    "value": 10<br/>  },<br/>  "delivery": {<br/>    "enabled": false,<br/>    "value": 1000<br/>  },<br/>  "reject": {<br/>    "enabled": false,<br/>    "value": 100<br/>  },<br/>  "reputation_bouncerate": {<br/>    "enabled": true,<br/>    "value": 5<br/>  },<br/>  "reputation_complaintrate": {<br/>    "enabled": true,<br/>    "value": 0.1<br/>  },<br/>  "send": {<br/>    "enabled": false,<br/>    "value": 10000<br/>  }<br/>}</pre> | no |
| <a name="input_threshold_override"></a> [threshold\_override](#input\_threshold\_override) | (Optional) Per-resource threshold overrides. Key is ConfigurationSetName (exact match), or the reserved key "default" when dimensions is empty (account-level alarms). NOTE: do not use "default" as an actual ConfigurationSetName in dimensions; it would be indistinguishable from the reserved key. Value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints\_to\_alarm and evaluation\_periods. | <pre>map(object({<br/>    # Bounce threshold (unit=Count)<br/>    bounce = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Complaint threshold (unit=Count)<br/>    complaint = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Delivery threshold (unit=Count)<br/>    delivery = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Reject threshold (unit=Count)<br/>    reject = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Reputation.BounceRate threshold (unit=Percent)<br/>    reputation_bouncerate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Reputation.ComplaintRate threshold (unit=Percent)<br/>    reputation_complaintrate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>    # Send threshold (unit=Count)<br/>    send = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
