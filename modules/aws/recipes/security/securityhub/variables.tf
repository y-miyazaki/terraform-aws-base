#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable SecurityHub. Defaults true."
  default     = true
}
variable "aws_securityhub_member" {
  type        = map(any)
  description = "(Optional) list of Security Hub member resource."
  default     = null
}
variable "aws_securityhub_product_subscription" {
  type        = map(any)
  description = "(Optional) The ARN of the product that generates findings that you want to import into Security Hub - see below."
  default     = null
}
variable "region" {
  type        = string
  description = "(Optional) The region name."
  default     = null
}
variable "enabled_cis_aws_foundations_benchmark" {
  type        = bool
  description = "(Optional) CIS AWS Foundations Benchmark is valid, set it to true. default is true."
  default     = true
}
variable "cis_aws_foundations_benchmark_version" {
  type        = string
  description = "(Optional) CIS AWS Foundations Benchmark version. Please check https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-cis1.4-vs-cis1.2.html"
  default     = "1.4.0"
}
variable "enabled_pci_dss" {
  type        = bool
  description = "(Optional) PCI DSS is valid, set it to true. default is true."
  default     = true
}
variable "pci_dss_version" {
  type        = string
  description = "(Optional) PCI DSS version. Please check https://aws.amazon.com/compliance/pci-dss-level-1-faqs/"
  default     = "3.2.1"
}
variable "aws_securityhub_action_target" {
  type = object({
    name        = string
    identifier  = string
    description = string
  })
  description = "(Optional) Creates Security Hub custom action."
  default = {
    name        = "Send notification"
    identifier  = "SendToEvent"
    description = "This is custom action sends selected findings to event"
  }
}
# variable "aws_cloudwatch_event_rule" {
#   type = object(
#     {
#       # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
#       name = string
#       # (Optional) The description of the rule.
#       description = string
#     }
#   )
#   description = "(Optional) Provides an EventBridge Rule resource."
#   default = {
#     name        = "security-securityhub-cloudwatch-event-rule"
#     description = "This cloudwatch event used for SecurityHub."
#   }
# }
# variable "aws_cloudwatch_event_target" {
#   type = object(
#     {
#       # (Required) The Amazon Resource Name (ARN) associated of the target.
#       arn = string
#     }
#   )
#   description = "(Optional) Provides an EventBridge Target resource."
#   default = {
#     arn = null
#   }
# }
# variable "tags" {
#   type        = map(any)
#   description = "(Optional) Key-value map of resource tags."
#   default     = null
# }
