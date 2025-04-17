#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix of all resources."
  default     = ""
}
variable "name" {
  type        = string
  description = "(Optional) Name of all resources."
  default     = ""
}

variable "slack_channel_id" {
  type        = string
  description = "(Required) Set the Slack channel ID."
}

variable "slack_workspace_id" {
  type        = string
  description = "(Required) Set the Slack workspace ID."
}

variable "logging_level" {
  type        = string
  description = "(Optional) Specifies the logging level for this configuration:ERROR,INFO or NONE. This property affects the log entries pushed to Amazon CloudWatch logs."
  default     = "ERROR"
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "(Required) Specify the SNS topic ARN to notify Chatbot."
}
