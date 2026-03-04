<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.bounce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.complaint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.reject](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.reputation_bouncerate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.reputation_complaintrate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.send](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of SES. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in SES. | <pre>object({<br/>    # Bounce threshold (unit=Count)<br/>    enabled_bounce = bool<br/>    bounce         = number<br/>    # Complaint threshold (unit=Count)<br/>    enabled_complaint = bool<br/>    complaint         = number<br/>    # Delivery threshold (unit=Count)<br/>    enabled_delivery = bool<br/>    delivery         = number<br/>    # Reject threshold (unit=Count)<br/>    enabled_reject = bool<br/>    reject         = number<br/>    # Reputation.BounceRate threshold (unit=Percent)<br/>    enabled_reputation_bouncerate = bool<br/>    reputation_bouncerate         = number<br/>    # Reputation.ComplaintRate threshold (unit=Percent)<br/>    enabled_reputation_complaintrate = bool<br/>    reputation_complaintrate         = number<br/>    # Send threshold (unit=Count)<br/>    enabled_send = bool<br/>    send         = number<br/>    }<br/>  )</pre> | <pre>{<br/>  "bounce": 100,<br/>  "complaint": 10,<br/>  "delivery": 1000,<br/>  "enabled_bounce": false,<br/>  "enabled_complaint": false,<br/>  "enabled_delivery": false,<br/>  "enabled_reject": false,<br/>  "enabled_reputation_bouncerate": true,<br/>  "enabled_reputation_complaintrate": true,<br/>  "enabled_send": false,<br/>  "reject": 100,<br/>  "reputation_bouncerate": 5,<br/>  "reputation_complaintrate": 0.1,<br/>  "send": 10000<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
