#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      name = string
      #   name_prefix         = string
      schedule_expression = string
      #   event_bus_name      = string
      event_pattern = string
      description   = string
      role_arn      = string
      is_enabled    = bool
    }
  )
  description = "(Required) aws_cloudwatch_event_rule."
  default     = null
}
variable "aws_cloudwatch_event_target" {
  type = object(
    {
      #   rule                = string
      event_bus_name      = string
      target_id           = string
      arn                 = string
      input               = string
      input_path          = string
      role_arn            = string
      run_command_targets = list(any)
      ecs_target          = list(any)
      batch_target        = list(any)
      kinesis_target      = list(any)
      sqs_target          = list(any)
      input_transformer   = list(any)
      retry_policy        = list(any)
      dead_letter_config  = list(any)
    }
  )
  description = "(Required) aws_cloudwatch_event_target."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "tags - (Optional) A mapping of tags to assign to the resource."
  default     = null
}
