#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "bucket" {
  type        = string
  description = "(Required) The S3 bucket name."
}
variable "policy" {
  type        = string
  description = "(Required) The text of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
}
