#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of config name."
  default     = ""
}
# variable "api_gw_endpoint_type_check" {
#   type = object(
#     {
#       input_parameters = map(any)
#     }
#   )
#   default = {
#     input_parameters = {
#       endpointConfigurationTypes = ["REGIONAL", "PRIVATE"]
#     }
#   }
# }
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
