#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
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
variable "aws_security_group" {
  type = object(
    {
      # (Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name.
      name = string
    }
  )
  description = "(Required) Provides a security group resource."
  default     = null

}
variable "aws_iam_role" {
  type = object(
    {
      # (Required) Policy that grants an entity permission to assume the role.
      assume_role_policy = string
      # (Optional) Description of the role.
      description = string
      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # (Optional) Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) The resource of aws_iam_role."
}
variable "aws_iam_policy" {
  type = object(
    {
      # (Optional, Forces new resource) Description of the IAM policy.
      description = string
      # (Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # (Optional, default "/") Path in which to create the policy. See IAM Identifiers for more information.
      path = string
      #  (Required) The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
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
