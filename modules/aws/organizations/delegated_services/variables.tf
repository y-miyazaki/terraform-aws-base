#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "account_id" {
  type        = string
  description = "AWS account ID to check for delegated service principals."
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
