#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable SecurityHub. Defaults true."
  default     = true
}
variable "securityhub_member" {
  type        = map(any)
  description = "(Optional) list of Security Hub member resource."
  default     = null
}
variable "product_subscription" {
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
variable "enabled_pci_dss" {
  type        = bool
  description = "(Optional) PCI DSS is valid, set it to true. default is true."
  default     = true
}
