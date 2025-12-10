#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) Base name prefix for all Chatbot related resources."
}

variable "slack_channel_id" {
  type        = string
  description = "(Required) Set the Slack channel ID."
}

variable "slack_team_id" {
  type        = string
  description = "(Required) Set the Slack workspace ID."
}

variable "logging_level" {
  type        = string
  description = "(Optional) Specifies the logging level for this configuration: ERROR, INFO or NONE."
  default     = "ERROR"
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "(Required) Specify the SNS topic ARNs to notify Chatbot."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
