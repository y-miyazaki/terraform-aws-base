#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable Lambda. Defaults true."
  default     = true
}
variable "aws_lambda_permission" {
  type = object(
    {
      action              = string
      event_source_token  = string
      function_name       = string
      principal           = string
      qualifier           = string
      source_account      = string
      source_arn          = string
      statement_id        = string
      statement_id_prefix = string
    }
  )
  description = "(Required) The aws_lambda_permission."
}
