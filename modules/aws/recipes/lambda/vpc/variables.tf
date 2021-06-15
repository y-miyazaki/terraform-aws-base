#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_subnet" {
  type = list(object({
    # The AZ for the subnet.
    availability_zone = string
    # The CIDR block for the subnet.
    cidr_block = string
    # Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
    map_public_ip_on_launch = bool
    # The Amazon Resource Name (ARN) of the Outpost.
    outpost_arn = string
    # The VPC ID.
    vpc_id = string
    }
    )
  )
  description = "(Required) Provides an VPC subnet resource."
}
variable "aws_route_table_association" {
  type = object({
    # The ID of the routing table to associate with.
    route_table_id = string
    }
  )
  description = "(Required) Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway."
}
variable "aws_security_group" {
  type = object(
    {
      # The name of the security group. If omitted, Terraform will assign a random, unique name.
      name = string
    }
  )
  description = "(Required) Provides a security group resource."
}
variable "aws_iam_role" {
  type = object(
    {
      # Policy that grants an entity permission to assume the role.
      assume_role_policy = string
      # Description of the role.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) The resource of aws_iam_role."
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = string
      # The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      policy = string
    }
  )
  description = "(Required) The resource of aws_iam_policy."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
