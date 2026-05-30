#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Required) Prefix for all resource names."
}
variable "lambda_zip_base_path" {
  type        = string
  description = "(Required) Base path to Lambda zip files (e.g., ../../lambda/outputs)."
}
variable "slack" {
  type = object({
    # (Required) Slack signing secret for request verification.
    signing_secret = string
    # (Required) Slack bot OAuth token.
    bot_token = string
    # (Required) Slack channel ID for approval notifications.
    approver_channel_id = string
    # (Optional) Shared secret for authenticating Slack Workflow Builder webhook requests via x-workflow-secret header. When null, the /workflow/request endpoint is not created.
    workflow_secret = optional(string)
    # (Optional) Slack User ID → Identity Center User ID mapping. Required only for users whose Slack email does not match Identity Center UserName.
    user_mappings = optional(map(string), {})
  })
  description = "(Required) Slack App credentials and configuration."
}
variable "ssm_parameter_prefix" {
  type        = string
  description = "(Optional) SSM Parameter Store prefix for JIT access configuration."
  default     = "/jit-access"
}
variable "profiles" {
  type = map(object({
    # (Required) AWS account ID for the permission set assignment.
    account_id = string
    # (Required) Permission Set ARN to assign.
    permission_set_arn = string
    # (Required) Maximum allowed duration in minutes.
    max_duration_minutes = number
    # (Required) List of Slack user IDs who can approve requests for this profile.
    approvers = list(string)
    # (Optional) Human-readable description of this profile.
    description = optional(string, "")
  }))
  description = "(Required) Map of JIT access profiles. Key is the profile name."
}
variable "cleanup_schedule_expression" {
  type        = string
  description = "(Optional) EventBridge schedule expression for the cleanup checker."
  default     = "rate(15 minutes)"
}
variable "lambda_log_retention_days" {
  type        = number
  description = "(Optional) CloudWatch Logs retention in days for Lambda functions."
  default     = 30
}
variable "lambda_memory_size" {
  type        = number
  description = "(Optional) Memory size in MB for Lambda functions."
  default     = 128
}
variable "lambda_timeout" {
  type        = number
  description = "(Optional) Timeout in seconds for Lambda functions."
  default     = 300
}
variable "kms_key_arn" {
  type        = string
  description = "(Optional) KMS key ARN for encrypting CloudWatch Logs and DynamoDB."
  default     = null
}
variable "vpc_config" {
  type = object({
    # (Required) List of subnet IDs for Lambda VPC configuration.
    subnet_ids = list(string)
    # (Required) List of security group IDs for Lambda VPC configuration.
    security_group_ids = list(string)
  })
  description = "(Optional) VPC configuration for Lambda functions. Set to null to disable VPC."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
