#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "region" {
  type        = string
  description = "(Required) The region name, in the form com.amazonaws.region.service for AWS services."
}
variable "vpc_id" {
  type        = string
  description = "(Required) The ID of the VPC in which the endpoint will be used."
}
variable "auto_accept" {
  type        = bool
  description = "(Optional) Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account)."
  default     = true
}
variable "policy" {
  type        = string
  description = "(Optional) A policy to attach to the endpoint that controls access to the service. Defaults to full access. All Gateway and some Interface endpoints support policies - see the relevant AWS documentation for more details. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  default     = null
}
variable "private_dns_enabled" {
  type        = bool
  description = "(Optional; AWS services and AWS Marketplace partner services only) Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface. Defaults to false."
  default     = false
}
variable "route_table_ids" {
  type        = list(any)
  description = "(Optional) One or more route table IDs. Applicable for endpoints of type Gateway."
  default     = []
}
# variable "subnet_ids" {
#   type        = list(any)
#   description = "(Optional) The ID of one or more subnets in which to create a network interface for the endpoint. Applicable for endpoints of type Interface."
#   default     = []
# }
# variable "security_group_ids" {
#   type        = list(any)
#   description = "(Optional) The ID of one or more security groups to associate with the network interface. Required for endpoints of type Interface."
#   default     = []
# }
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}

# variable "vpc_endpoint_type" {
#  type        = string
#  description = "(Optional) The VPC endpoint type, Gateway or Interface. Defaults to Gateway."
#  # ex) default = {Gateway|Interface}
#  default = "Gateway"
#}
