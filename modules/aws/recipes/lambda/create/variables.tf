#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_log_group" {
  type = object(
    {
      retention_in_days = number
      kms_key_id        = string
    }
  )
  description = "(Required) The aws_cloudwatch_log_group."
  default     = null
}
variable "aws_lambda_function" {
  type = object(
    {
      filename                       = string
      s3_bucket                      = string
      s3_key                         = string
      s3_object_version              = string
      function_name                  = string
      dead_letter_config             = list(any)
      handler                        = string
      role                           = string
      description                    = string
      layers                         = list(any)
      memory_size                    = number
      runtime                        = string
      timeout                        = number
      reserved_concurrent_executions = string
      publish                        = bool
      vpc_config                     = list(any)
      environment                    = map(any)
      kms_key_arn                    = string
      source_code_hash               = string
    }
  )
  description = "(Required) The aws_lambda_function."
  default     = null
}
variable "aws_lambda_permission" {
  type = object(
    {
      action             = string
      event_source_token = string
      # function_name       = string
      principal           = string
      qualifier           = string
      source_account      = string
      source_arn          = string
      statement_id        = string
      statement_id_prefix = string
    }
  )
  description = "(Required) The aws_lambda_permission."
  default     = null
}
#--------------------------------------------------------------
# Other
#--------------------------------------------------------------
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
