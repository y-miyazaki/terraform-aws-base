#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "aws_config_config_rule" {
  type = list(object(
    {
      # (Required) The name of the rule
      name = string
      # (Optional) Description of the rule
      description = string
      # (Optional) A string in JSON format that is passed to the AWS Config rule Lambda function.
      input_parameters = string
      # (Optional) The maximum frequency with which AWS Config runs evaluations for a rule.
      maximum_execution_frequency = string
      # (Optional) Scope defines which resources can trigger an evaluation for the rule as documented below.
      scope = any
      # (Required) Source specifies the rule owner, the rule identifier, and the notifications that cause the function to evaluate your AWS resources as documented below.
      source = any
    }
    )
  )
  description = "(Required) Provides an AWS Config Rule."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
