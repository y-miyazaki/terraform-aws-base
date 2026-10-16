#--------------------------------------------------------------
# Module: aws/security/default_vpc
# Purpose: Manage default VPC baseline resources (VPC, route table, network ACL, security group, subnets, optional EC2 interface endpoint) for governance or transitional hardening.
# Notes: Uses default VPC constructs which are generally discouraged in production; future improvement: optionally skip creation and enforce deletion, plus parameterize endpoint services.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

data "aws_availability_zones" "this" {
  region = local.region
  state  = "available"
}

#--------------------------------------------------------------
# Check if a default VPC exists in this region.
# If no default VPC exists, all resources in this module are skipped.
#--------------------------------------------------------------
data "aws_vpcs" "default" {
  count = var.is_enabled ? 1 : 0

  region = local.region

  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

locals {
  default_vpc_exists = var.is_enabled && length(try(data.aws_vpcs.default[0].ids, [])) > 0
  is_active          = var.is_enabled && local.default_vpc_exists
}

#--------------------------------------------------------------
# Provides a resource to manage the default AWS VPC in the current region.
#--------------------------------------------------------------
#tfsec:ignore:AWS082 tfsec:ignore:aws-ec2-no-default-vpc
resource "aws_default_vpc" "this" {
  count = local.is_active ? 1 : 0

  region = local.region

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource to manage a default route table of a VPC. This resource can manage the default route table of the default or a non-default VPC.
#--------------------------------------------------------------
resource "aws_default_route_table" "this" {
  count = local.is_active ? 1 : 0

  region                 = local.region
  default_route_table_id = aws_default_vpc.this[0].default_route_table_id

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource to manage a VPC's default network ACL. This resource can manage the default network ACL of the default or a non-default VPC.
#--------------------------------------------------------------
resource "aws_default_network_acl" "this" {
  count = local.is_active ? 1 : 0

  region                 = local.region
  default_network_acl_id = aws_default_vpc.this[0].default_network_acl_id

  lifecycle {
    ignore_changes = [subnet_ids]
  }

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource to manage a default security group. This resource can manage the default security group of the default or a non-default VPC.
#--------------------------------------------------------------
resource "aws_default_security_group" "this" {
  count = local.is_active ? 1 : 0

  region = local.region
  vpc_id = aws_default_vpc.this[0].id

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource to manage a default AWS VPC subnet in the current region.
# EC2-10: Ensure VPC subnets are not publicly accessible
#--------------------------------------------------------------
resource "aws_default_subnet" "this" {
  count = local.is_active ? length(data.aws_availability_zones.this.names) : 0

  region                  = local.region
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = false

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a VPC Endpoint resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#ec2-10-remediation
#--------------------------------------------------------------
resource "aws_vpc_endpoint" "this" {
  count = local.is_active && var.is_enabled_vpc_end_point ? 1 : 0

  region = local.region
  #  auto_accept         = var.auto_accept
  #  policy              = var.policy
  private_dns_enabled = true
  security_group_ids  = [aws_default_security_group.this[0].id]
  service_name        = "com.amazonaws.${local.region}.ec2"
  # route_table_ids     = [aws_default_route_table.this[0].id]
  subnet_ids        = aws_default_subnet.this[*].id
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_default_vpc.this[0].id
}
