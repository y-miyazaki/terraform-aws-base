variable "kms_key_arn" {
  type        = string
  description = "(Optional) KMS key ARN used to encrypt the CloudWatch Logs for API Gateway. When set, kms:Decrypt and kms:GenerateDataKey on the key are granted to the CloudWatch role."
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "(Required) Prefix for resource names."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to assign to resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
