#--------------------------------------------------------------
# module variables(aws_cloudwatch_event_rule)
#--------------------------------------------------------------
variable "aws_cloudwatch_log_metric_filter" {
  type        = list(any)
  description = "(Required) aws_cloudwatch_log_metric_filter."
  default     = null
}
variable "aws_cloudwatch_metric_alarm" {
  type        = list(any)
  description = "(Required) aws_cloudwatch_metric_alarm."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
