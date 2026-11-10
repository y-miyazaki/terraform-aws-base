#--------------------------------------------------------------
# Module: aws/lambda/vpc
# Purpose: Provision subnets, security group, and IAM role/policy resources for Lambda functions requiring VPC access.
# Notes: Simplified networking constructs; future improvement: optional NACLs and SG ingress/egress customization via variables.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an VPC subnet resource.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

resource "aws_subnet" "this" {
  # Keyed by cidr_block so reordering var.aws_subnet does not recreate subnets.
  for_each = { for s in var.aws_subnet : s.cidr_block => s }

  region                  = local.region
  availability_zone       = try(each.value.availability_zone)
  cidr_block              = each.key
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)
  outpost_arn             = try(each.value.outpost_arn, null)
  vpc_id                  = try(each.value.vpc_id, null)

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
#--------------------------------------------------------------
resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  region         = local.region
  route_table_id = try(var.aws_route_table_association.route_table_id)
  subnet_id      = each.value.id
}

#--------------------------------------------------------------
# Security Group
#--------------------------------------------------------------
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "this" {
  region      = local.region
  description = "Allow inbound/outbound traffic"
  name        = try(var.aws_security_group.name)
  vpc_id      = try(var.aws_subnet[0].vpc_id)

  ingress {
    description = "from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.this : s.cidr_block]
  }
  egress {
    description = "Allow outbound all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  assume_role_policy = try(var.aws_iam_role.assume_role_policy)

  description           = try(var.aws_iam_role.description, null)
  force_detach_policies = true
  name                  = try(var.aws_iam_role.name)
  path                  = try(var.aws_iam_role.path, "/")

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  description = try(var.aws_iam_policy.description, null)
  name        = try(var.aws_iam_policy.name)
  path        = try(var.aws_iam_policy.path, "/")
  policy      = try(var.aws_iam_policy.policy)

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
