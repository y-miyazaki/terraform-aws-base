#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_log_metric_filter" {
  type        = list(any)
  description = "(Required) aws_cloudwatch_log_metric_filter."
}
variable "aws_cloudwatch_metric_alarm" {
  type        = list(any)
  description = "(Required) aws_cloudwatch_metric_alarm."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
