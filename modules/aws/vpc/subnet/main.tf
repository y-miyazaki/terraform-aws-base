#--------------------------------------------------------------
# Module: aws/vpc/subnet
# Purpose: Provision multiple VPC subnets and associate them with specified route tables.
# Notes: Uses try() for optional attributes; unified tagging applied; future improvement: add IPv6 CIDR handling and subnet type tagging.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}
locals {
  name_prefix = trimsuffix(var.name_prefix, "-")
  # Keyed by cidr_block so reordering var.aws_subnet does not recreate subnets. index keeps the legacy "<prefix>-subnet-<n>" Name tag.
  subnets = { for i, s in var.aws_subnet : s.cidr_block => { index = i + 1, subnet = s } }
}

#--------------------------------------------------------------
# Provides an VPC subnet resource.
#--------------------------------------------------------------
resource "aws_subnet" "this" {
  for_each = local.subnets

  region                  = local.region
  availability_zone       = try(each.value.subnet.availability_zone)
  cidr_block              = each.key
  map_public_ip_on_launch = try(each.value.subnet.map_public_ip_on_launch, false)
  outpost_arn             = try(each.value.subnet.outpost_arn, null)
  vpc_id                  = try(each.value.subnet.vpc_id, null)

  tags = merge(var.tags, { "Name" = format("%v-subnet-%d", local.name_prefix, each.value.index) })
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
