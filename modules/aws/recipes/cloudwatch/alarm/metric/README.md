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
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_metric_alarm"></a> [aws\_cloudwatch\_metric\_alarm](#input\_aws\_cloudwatch\_metric\_alarm) | (Optional) aws\_cloudwatch\_metric\_alarm. | <pre>list(object(<br>    {<br>      # The descriptive name for the alarm. This name must be unique within the user's AWS account<br>      alarm_name = string<br>      # The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. Additionally, the values LessThanLowerOrGreaterThanUpperThreshold, LessThanLowerThreshold, and GreaterThanUpperThreshold are used only for alarms based on anomaly detection models.<br>      comparison_operator = string<br>      # The number of periods over which data is compared to the specified threshold.<br>      evaluation_periods = string<br>      # The name for the alarm's associated metric. See docs for supported metrics.<br>      metric_name = string<br>      # The namespace for the alarm's associated metric. See docs for the list of namespaces. See docs for supported metrics.<br>      namespace = string<br>      # The period in seconds over which the specified statistic is applied.<br>      period = number<br>      # The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum<br>      statistic = string<br>      # The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models.<br>      threshold = string<br>      # If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY_DETECTION_BAND function.<br>      threshold_metric_id = string<br>      # Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true.<br>      actions_enabled = bool<br>      # The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN).<br>      alarm_actions = list(string)<br>      # The description for the alarm.<br>      alarm_description = string<br>      # The number of datapoints that must be breaching to trigger the alarm.<br>      datapoints_to_alarm = string<br>      # The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here.<br>      dimensions = map(any)<br>      # The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN).<br>      insufficient_data_actions = list(string)<br>      # The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN).<br>      ok_actions = list(string)<br>      # The unit for the alarm's associated metric.<br>      unit = string<br>      # The percentile statistic for the metric associated with the alarm. Specify a value between p0.0 and p100.<br>      extended_statistic = string<br>      # Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing.<br>      treat_missing_data = string<br>      # Used only for alarms based on percentiles. If you specify ignore, the alarm state will not change during periods with too few data points to be statistically significant. If you specify evaluate or omit this parameter, the alarm will always be evaluated and possibly change state no matter how many data points are available. The following values are supported: ignore, and evaluate.<br>      evaluate_low_sample_count_percentiles = string<br>      # Enables you to create an alarm based on a metric math expression. You may specify at most 20.<br>      metric_query = list(any)<br>    }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
