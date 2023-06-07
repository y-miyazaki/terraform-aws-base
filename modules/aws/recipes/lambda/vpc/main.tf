#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an VPC subnet resource.
#--------------------------------------------------------------
resource "aws_subnet" "this" {
  count                   = length(var.aws_subnet)
  availability_zone       = lookup(var.aws_subnet[count.index], "availability_zone")
  cidr_block              = lookup(var.aws_subnet[count.index], "cidr_block")
  map_public_ip_on_launch = lookup(var.aws_subnet[count.index], "map_public_ip_on_launch", false)
  outpost_arn             = lookup(var.aws_subnet[count.index], "outpost_arn", null)
  vpc_id                  = lookup(var.aws_subnet[count.index], "vpc_id", null)
  tags                    = local.tags
}
#--------------------------------------------------------------
# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
#--------------------------------------------------------------
resource "aws_route_table_association" "this" {
  count          = length(var.aws_subnet)
  subnet_id      = element(aws_subnet.this.*.id, count.index)
  route_table_id = lookup(var.aws_route_table_association, "route_table_id")
}

#--------------------------------------------------------------
# Security Group
#--------------------------------------------------------------
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "this" {
  name        = lookup(var.aws_security_group, "name")
  vpc_id      = lookup(var.aws_subnet[0], "vpc_id")
  description = "Allow inbound/outbound traffic"
  ingress {
    description = "from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = aws_subnet.this.*.cidr_block
  }
  egress {
    description = "Allow outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
  lifecycle {
    create_before_destroy = true
  }
}
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = lookup(var.aws_iam_role, "assume_role_policy")
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role, "path", "/")
  tags                  = local.tags
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = lookup(var.aws_iam_policy, "policy")
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
