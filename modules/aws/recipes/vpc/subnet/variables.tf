#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Required, Forces new resource) Creates a tag name beginning with the specified prefix."
  default     = null
}
variable "aws_subnet" {
  type = list(object({
    # (Optional) The AZ for the subnet.
    availability_zone = string
    # (Required) The CIDR block for the subnet.
    cidr_block = string
    # (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
    map_public_ip_on_launch = bool
    # (Optional) The Amazon Resource Name (ARN) of the Outpost.
    outpost_arn = string
    # (Required) The VPC ID.
    vpc_id = string
    }
    )
  )
  description = "(Required) Provides an VPC subnet resource."
  default     = []
}
variable "aws_route_table_association" {
  type = object({
    # (Required) The ID of the routing table to associate with.
    route_table_id = string
    }
  )
  description = "(Required) Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
