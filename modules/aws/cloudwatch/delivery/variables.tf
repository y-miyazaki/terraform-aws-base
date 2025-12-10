#--------------------------------------------------------------
# Module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Required) Enable or disable the log delivery resources."
  default     = true
}

variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for all resources."
}

variable "create_auto_log_group_names" {
  type        = bool
  description = "(Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored."
  default     = false
}

variable "auto_log_group_names_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_log_group_names is set to true, a list of log group name will be automatically registered, but at that time, specify the log group name you want to exclude using partial match."
  default     = []
}

variable "auto_log_group_names_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included."
  default     = []
}

variable "log_group_names" {
  type        = list(string)
  description = "(Optional) If create_auto_log_group_names is set to false, List of CloudWatch Log Group names to subscribe."
  default     = []
}

variable "filter_pattern" {
  type        = string
  description = "(Optional) Filter pattern for the CloudWatch Logs subscription filter."
  default     = ""
}

variable "distribution" {
  type        = string
  description = "(Optional) Distribution method for the subscription filter."
  default     = "Random"
}

variable "s3_bucket_arn" {
  type        = string
  description = "(Required) ARN of the S3 bucket where logs will be delivered."
}

variable "lambda_processor_arn" {
  type        = string
  description = "(Optional) ARN of the Lambda function for processing logs in Kinesis Firehose. If null, processing is disabled."
  default     = null
}

variable "aws_kinesis_firehose_delivery_stream" {
  type        = any
  description = "(Required) Configuration for Kinesis Firehose delivery stream."
}

variable "aws_iam_role_cloudwatch_logs" {
  type        = any
  description = "(Required) IAM role configuration for CloudWatch Logs."
}

variable "aws_iam_policy_cloudwatch_logs" {
  type        = any
  description = "(Required) IAM policy configuration for CloudWatch Logs."
}

variable "aws_iam_role_kinesis_firehose" {
  type        = any
  description = "(Required) IAM role configuration for Kinesis Firehose."
}

variable "aws_iam_policy_kinesis_firehose" {
  type        = any
  description = "(Required) IAM policy configuration for Kinesis Firehose."
}

variable "account_id" {
  type        = string
  description = "(Required) AWS account ID."
}

variable "region" {
  type        = string
  description = "(Required) AWS region."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resources."
  default     = {}
}
