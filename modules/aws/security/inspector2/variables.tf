#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS region where Inspector2 will be enabled"
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Inspector2 account configuration. Defaults true."
  default     = true
}

variable "resource_types" {
  type        = list(string)
  description = "(Required) Type of resources to scan. Valid values are EC2, ECR, LAMBDA, LAMBDA_CODE, CODE_REPOSITORY."
  default     = ["EC2", "ECR", "LAMBDA", "LAMBDA_CODE"]
}
