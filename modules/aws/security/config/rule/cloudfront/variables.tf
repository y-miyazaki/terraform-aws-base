#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of config name."
  default     = ""
}
variable "ssm_automation_assume_role_arn" {
  type        = string
  description = "(Required) AssumeRole arn in SSM Automation"
}
variable "is_enable_cloudfront_viewer_policy_https" {
  type        = bool
  description = "(Optional) If true, it will change the viewer protocol policy to redirect-to-https."
  default     = false
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
