#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "cidr_block" {
  type        = string
  description = "(Required) The CIDR block for the VPC."
  default     = null
}
variable "availability_zone" {
  type        = list(any)
  description = "(Required) The AZ for the subnet."
  default     = null
}
variable "nat_cidr_block" {
  type        = list(any)
  description = "(Required) The CIDR block for the nat gateway subnet."
  default     = null
}
variable "igw_cidr_block" {
  type        = list(any)
  description = "(Required) The CIDR block for the internet gateway subnet."
  default     = null
}
variable "flow_log" {
  description = "(Optional) need to flow log, true. flow log saves cloudwatch logs."
  default = {
    enabled           = true
    retention_in_days = 30
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
