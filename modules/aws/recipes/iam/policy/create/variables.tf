#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "template" {
  type        = string
  description = "(Optional) The contents of the template, as a string using Terraform template syntax. Use the file function to load the template source from a separate file on disk."
  default     = null
}
variable "vars" {
  type        = map(any)
  description = "(Optional) Variables for interpolation within the template. Note that variables must all be primitives. Direct references to lists or maps will cause a validation error."
  default     = null
}
variable "policy_id" {
  type        = string
  description = "(Optional) - An ID for the policy document."
  default     = null
}
# variable "source_json" {
#   type        = string
#   description = "(Optional) - An IAM policy document to import as a base for the current policy document. Statements with non-blank sids in the current policy document will overwrite statements with the same sid in the source json. Statements without an sid cannot be overwritten."
#   default     = null
# }
# variable "override_json" {
#   type        = string
#   description = "(Optional) - An IAM policy document to import and override the current policy document. Statements with non-blank sids in the override document will overwrite statements with the same sid in the current document. Statements without an sid cannot be overwritten."
#   default     = null
# }
variable "statement" {
  type        = list(any)
  description = "(Optional) - A nested configuration block (described below) configuring one statement to be included in the policy document."
  default     = []
}
variable "ver" {
  type        = string
  description = "(Optional) - IAM policy document version. Valid values: 2008-10-17, 2012-10-17. Defaults to 2012-10-17. For more information, see the AWS IAM User Guide."
  default     = "2012-10-17"
}
#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "description" {
  type        = string
  description = "(Optional, Forces new resource) Description of the IAM policy."
  default     = null
}
variable "name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name."
  default     = null
}
# variable "name_prefix" {
#   type        = string
#   description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
#   default     = null
# }
variable "path" {
  type        = string
  description = "(Optional, default  / ) Path in which to create the policy. See IAM Identifiers for more information."
  default     = "/"
}
# variable "policy" {
#   type        = string
#   description = "(Required) The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide"
#   default     = null
# }
#--------------------------------------------------------------
# Other
#--------------------------------------------------------------
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
