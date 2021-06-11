#--------------------------------------------------------------
# module variables(aws_cloudwatch_event_rule)
#--------------------------------------------------------------
variable "aws_cloudwatch_metric_alarm" {
  type = list(object(
    {
      # (Required) The descriptive name for the alarm. This name must be unique within the user's AWS account
      alarm_name = string
      # (Required) The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. Additionally, the values LessThanLowerOrGreaterThanUpperThreshold, LessThanLowerThreshold, and GreaterThanUpperThreshold are used only for alarms based on anomaly detection models.
      comparison_operator = string
      # (Required) The number of periods over which data is compared to the specified threshold.
      evaluation_periods = string
      # (Optional) The name for the alarm's associated metric. See docs for supported metrics.
      metric_name = string
      # (Optional) The namespace for the alarm's associated metric. See docs for the list of namespaces. See docs for supported metrics.
      namespace = string
      # (Optional) The period in seconds over which the specified statistic is applied.
      period = number
      # (Optional) The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum
      statistic = string
      # (Optional) The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds, but should not be used for alarms based on anomaly detection models.
      threshold = string
      # (Optional) If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY_DETECTION_BAND function.
      threshold_metric_id = string
      # (Optional) Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true.
      actions_enabled = bool
      # (Optional) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN).
      alarm_actions = string
      # (Optional) The description for the alarm.
      alarm_description = string
      # (Optional) The number of datapoints that must be breaching to trigger the alarm.
      datapoints_to_alarm = string
      # (Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here.
      dimensions = map(any)
      # (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN).
      insufficient_data_actions = string
      # (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN).
      ok_actions = string
      # (Optional) The unit for the alarm's associated metric.
      unit = string
      # (Optional) The percentile statistic for the metric associated with the alarm. Specify a value between p0.0 and p100.
      extended_statistic = string
      # (Optional) Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing.
      treat_missing_data = string
      # (Optional) Used only for alarms based on percentiles. If you specify ignore, the alarm state will not change during periods with too few data points to be statistically significant. If you specify evaluate or omit this parameter, the alarm will always be evaluated and possibly change state no matter how many data points are available. The following values are supported: ignore, and evaluate.
      evaluate_low_sample_count_percentiles = string
      # (Optional) Enables you to create an alarm based on a metric math expression. You may specify at most 20.
      metric_query = list(any)
    }
    )
  )
  description = "(Required) aws_cloudwatch_metric_alarm."
  default     = []
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
