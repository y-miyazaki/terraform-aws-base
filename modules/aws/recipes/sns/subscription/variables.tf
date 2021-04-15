#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_kms_key" {
  type = object(
    {
      description             = string
      deletion_window_in_days = number
      is_enabled              = bool
      enable_key_rotation     = bool
      alias_name              = string
    }
  )
  description = "(Required) The resource of aws_kms_key."
}
variable "aws_sns_topic" {
  type        = any
  description = "(Required) Provides an SNS topic resource."
}
variable "aws_sns_topic_subscription" {
  type        = any
  description = "(Required) Provides an SNS subscribe resource."
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "region" {
  type        = string
  description = "(Required) The region name."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
